import 'package:drift/drift.dart';
import '../converters/map_converter.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get businessName => text().nullable()();
  TextColumn get province => text().nullable()();
  TextColumn get businessInfo => text().map(const MapConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 