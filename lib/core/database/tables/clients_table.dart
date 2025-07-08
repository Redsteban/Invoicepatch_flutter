import 'package:drift/drift.dart';
import '../converters/map_converter.dart';

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get company => text()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().map(const MapConverter())();
  TextColumn get billingPreferences => text().map(const MapConverter())();
  TextColumn get rateHistory => text().map(const ExpenseMapConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 