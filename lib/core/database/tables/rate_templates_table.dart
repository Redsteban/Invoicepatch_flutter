import 'package:drift/drift.dart';
import '../converters/enum_converters.dart';

class RateTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get billingMethod => text().map(const BillingMethodConverter())();
  RealColumn get hourlyRate => real().nullable()();
  RealColumn get overtimeRate => real().nullable()();
  RealColumn get dayRate => real().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 