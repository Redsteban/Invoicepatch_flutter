import 'package:drift/drift.dart';

class InvoiceLineItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get description => text()();
  RealColumn get quantity => real()();
  RealColumn get rate => real()();
  RealColumn get amount => real()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 