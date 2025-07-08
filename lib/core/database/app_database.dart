import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/invoice_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/payment_terms.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';

// Import all table definitions
import 'tables/users_table.dart';
import 'tables/clients_table.dart';
import 'tables/daily_logs_table.dart';
import 'tables/invoices_table.dart';
import 'tables/invoice_line_items_table.dart';
import 'tables/rate_templates_table.dart';

// Import all DAOs
import 'daos/user_dao.dart';
import 'daos/client_dao.dart';
import 'daos/daily_log_dao.dart';
import 'daos/invoice_dao.dart';
import 'daos/rate_template_dao.dart';

// Import converters
import 'converters/map_converter.dart';
import 'converters/enum_converters.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Clients,
    DailyLogs,
    Invoices,
    InvoiceLineItems,
    RateTemplates,
  ],
  daos: [
    UserDao,
    ClientDao,
    DailyLogDao,
    InvoiceDao,
    RateTemplateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'invoicepatch_db', 
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('/sqlite3.wasm'),
        driftWorker: Uri.parse('/drift_worker.js'),
      )
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Create indexes for performance
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_daily_logs_client_date 
          ON daily_logs(client_id, date);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_daily_logs_status 
          ON daily_logs(status);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_invoices_client_status 
          ON invoices(client_id, status);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_invoices_date_range 
          ON invoices(issue_date, due_date);
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migration logic
      },
    );
  }
}

// Singleton instance
final appDatabase = AppDatabase(); 