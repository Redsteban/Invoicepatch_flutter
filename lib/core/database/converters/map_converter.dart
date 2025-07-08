import 'dart:convert';
import 'package:drift/drift.dart';

class MapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const MapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    return Map<String, dynamic>.from(json.decode(fromDb));
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return json.encode(value);
  }
}

class ExpenseMapConverter extends TypeConverter<Map<String, double>, String> {
  const ExpenseMapConverter();

  @override
  Map<String, double> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    final Map<String, dynamic> decoded = json.decode(fromDb);
    return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  @override
  String toSql(Map<String, double> value) {
    return json.encode(value);
  }
} 