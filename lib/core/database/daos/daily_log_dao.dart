import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/daily_logs_table.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/core/database/app_database.dart' as db;

part 'daily_log_dao.g.dart';

@DriftAccessor(tables: [DailyLogs])
class DailyLogDao extends DatabaseAccessor<AppDatabase> with _$DailyLogDaoMixin {
  DailyLogDao(AppDatabase db) : super(db);
  // ...existing methods...

  // Returns all daily logs
  Future<List<db.DailyLog>> getAllLogs() => select(dailyLogs).get();

  // Returns a single daily log by id
  Future<db.DailyLog?> getLogById(String id) {
    return (select(dailyLogs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Insert a new daily log
  Future<int> createLog(Insertable<db.DailyLog> log) => into(dailyLogs).insert(log);

  // Update an existing daily log
  Future<bool> updateLog(db.DailyLog log) => update(dailyLogs).replace(log);

  // Delete a daily log by id
  Future<int> deleteLog(String id) => (delete(dailyLogs)..where((tbl) => tbl.id.equals(id))).go();

  // Get logs for a date range
  Future<List<db.DailyLog>> getLogsForDateRange(DateTime start, DateTime end) {
    return (select(dailyLogs)
      ..where((tbl) => tbl.date.isBetweenValues(start, end)))
      .get();
  }

  // Get logs by client id
  Future<List<db.DailyLog>> getLogsByClient(String clientId) {
    return (select(dailyLogs)..where((tbl) => tbl.clientId.equals(clientId))).get();
  }

  // Calculate total for a period
  Future<double> calculateTotalForPeriod(DateTime start, DateTime end) async {
    final logs = await getLogsForDateRange(start, end);
    // Sum regularHours as a placeholder for total amount
    return logs.fold<double>(0.0, (sum, log) => sum + (log.regularHours ?? 0.0));
  }

  // Get logs that are not invoiced
  Future<List<db.DailyLog>> getUninvoicedLogs() {
    return (select(dailyLogs)..where((tbl) => tbl.status.isNotIn(['invoiced']))).get();
  }

  // Get logs by status
  Future<List<db.DailyLog>> getLogsByStatus(String status) {
    return (select(dailyLogs)..where((tbl) => tbl.status.equals(status))).get();
  }
} 