// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_drift.dart';

// ignore_for_file: type=lint
class $SimpleTestTable extends SimpleTest
    with TableInfo<$SimpleTestTable, SimpleTestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimpleTestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simple_test';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimpleTestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimpleTestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimpleTestData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $SimpleTestTable createAlias(String alias) {
    return $SimpleTestTable(attachedDatabase, alias);
  }
}

class SimpleTestData extends DataClass implements Insertable<SimpleTestData> {
  final int id;
  final String name;
  const SimpleTestData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SimpleTestCompanion toCompanion(bool nullToAbsent) {
    return SimpleTestCompanion(id: Value(id), name: Value(name));
  }

  factory SimpleTestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimpleTestData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  SimpleTestData copyWith({int? id, String? name}) =>
      SimpleTestData(id: id ?? this.id, name: name ?? this.name);
  SimpleTestData copyWithCompanion(SimpleTestCompanion data) {
    return SimpleTestData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimpleTestData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimpleTestData &&
          other.id == this.id &&
          other.name == this.name);
}

class SimpleTestCompanion extends UpdateCompanion<SimpleTestData> {
  final Value<int> id;
  final Value<String> name;
  const SimpleTestCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SimpleTestCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<SimpleTestData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SimpleTestCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SimpleTestCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimpleTestCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$TestDatabase extends GeneratedDatabase {
  _$TestDatabase(QueryExecutor e) : super(e);
  $TestDatabaseManager get managers => $TestDatabaseManager(this);
  late final $SimpleTestTable simpleTest = $SimpleTestTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [simpleTest];
}

typedef $$SimpleTestTableCreateCompanionBuilder =
    SimpleTestCompanion Function({Value<int> id, required String name});
typedef $$SimpleTestTableUpdateCompanionBuilder =
    SimpleTestCompanion Function({Value<int> id, Value<String> name});

class $$SimpleTestTableFilterComposer
    extends Composer<_$TestDatabase, $SimpleTestTable> {
  $$SimpleTestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SimpleTestTableOrderingComposer
    extends Composer<_$TestDatabase, $SimpleTestTable> {
  $$SimpleTestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SimpleTestTableAnnotationComposer
    extends Composer<_$TestDatabase, $SimpleTestTable> {
  $$SimpleTestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SimpleTestTableTableManager
    extends
        RootTableManager<
          _$TestDatabase,
          $SimpleTestTable,
          SimpleTestData,
          $$SimpleTestTableFilterComposer,
          $$SimpleTestTableOrderingComposer,
          $$SimpleTestTableAnnotationComposer,
          $$SimpleTestTableCreateCompanionBuilder,
          $$SimpleTestTableUpdateCompanionBuilder,
          (
            SimpleTestData,
            BaseReferences<_$TestDatabase, $SimpleTestTable, SimpleTestData>,
          ),
          SimpleTestData,
          PrefetchHooks Function()
        > {
  $$SimpleTestTableTableManager(_$TestDatabase db, $SimpleTestTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SimpleTestTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SimpleTestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SimpleTestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => SimpleTestCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  SimpleTestCompanion.insert(id: id, name: name),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SimpleTestTableProcessedTableManager =
    ProcessedTableManager<
      _$TestDatabase,
      $SimpleTestTable,
      SimpleTestData,
      $$SimpleTestTableFilterComposer,
      $$SimpleTestTableOrderingComposer,
      $$SimpleTestTableAnnotationComposer,
      $$SimpleTestTableCreateCompanionBuilder,
      $$SimpleTestTableUpdateCompanionBuilder,
      (
        SimpleTestData,
        BaseReferences<_$TestDatabase, $SimpleTestTable, SimpleTestData>,
      ),
      SimpleTestData,
      PrefetchHooks Function()
    >;

class $TestDatabaseManager {
  final _$TestDatabase _db;
  $TestDatabaseManager(this._db);
  $$SimpleTestTableTableManager get simpleTest =>
      $$SimpleTestTableTableManager(_db, _db.simpleTest);
}
