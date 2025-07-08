import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'test_drift.g.dart';

class SimpleTest extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DriftDatabase(tables: [SimpleTest])
class TestDatabase extends _$TestDatabase {
  TestDatabase() : super(driftDatabase(name: 'test_db'));

  @override
  int get schemaVersion => 1;
} 