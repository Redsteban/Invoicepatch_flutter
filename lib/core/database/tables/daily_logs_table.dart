import 'package:drift/drift.dart';
import '../converters/enum_converters.dart';
import '../converters/map_converter.dart';

class DailyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get billingMethod => text().map(const BillingMethodConverter())();
  RealColumn get regularHours => real().nullable()();
  RealColumn get overtimeHours => real().nullable()();
  RealColumn get hourlyRate => real().nullable()();
  RealColumn get overtimeRate => real().nullable()();
  RealColumn get dayRate => real().nullable()();
  BoolColumn get isFullDay => boolean().withDefault(const Constant(false))();
  TextColumn get expenses => text().map(const ExpenseMapConverter())();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().map(const LogStatusConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 