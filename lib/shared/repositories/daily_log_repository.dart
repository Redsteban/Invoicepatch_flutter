import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';
import 'package:invoicepatch_contractor/core/database/app_database.dart' as db;
import 'package:invoicepatch_contractor/core/database/daos/daily_log_dao.dart';
import 'base_repository.dart';
import 'package:drift/drift.dart' hide Column;

class DailyLogRepository extends BaseRepository<DailyLog> {
  final DailyLogDao _dailyLogDao;

  DailyLogRepository({required DailyLogDao dailyLogDao}) 
      : _dailyLogDao = dailyLogDao;

  @override
  Future<List<DailyLog>> getAll() async {
    try {
      final driftLogs = await _dailyLogDao.getAllLogs();
      return driftLogs.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get daily logs: $e');
    }
  }

  @override
  Future<DailyLog?> getById(String id) async {
    try {
      final driftLog = await _dailyLogDao.getLogById(id);
      return driftLog != null ? _convertFromDrift(driftLog) : null;
    } catch (e) {
      throw Exception('Failed to get daily log by id: $e');
    }
  }

  @override
  Future<DailyLog> create(DailyLog entity) async {
    try {
      final companion = _convertToCompanion(entity);
      await _dailyLogDao.createLog(companion);
      return entity.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create daily log: $e');
    }
  }

  @override
  Future<DailyLog> update(DailyLog entity) async {
    try {
      final updatedEntity = entity.copyWith(updatedAt: DateTime.now());
      final driftLog = _convertToDrift(updatedEntity);
      await _dailyLogDao.updateLog(driftLog);
      return updatedEntity;
    } catch (e) {
      throw Exception('Failed to update daily log: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dailyLogDao.deleteLog(id);
    } catch (e) {
      throw Exception('Failed to delete daily log: $e');
    }
  }

  // Billing-specific methods
  Future<List<DailyLog>> getLogsForDateRange(DateTime start, DateTime end) async {
    try {
      final driftLogs = await _dailyLogDao.getLogsForDateRange(start, end);
      return driftLogs.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get logs for date range: $e');
    }
  }

  Future<List<DailyLog>> getLogsByClient(String clientId) async {
    try {
      final driftLogs = await _dailyLogDao.getLogsByClient(clientId);
      return driftLogs.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get logs by client: $e');
    }
  }

  Future<double> calculateTotalForPeriod(DateTime start, DateTime end) async {
    try {
      return await _dailyLogDao.calculateTotalForPeriod(start, end);
    } catch (e) {
      throw Exception('Failed to calculate total for period: $e');
    }
  }

  Future<List<DailyLog>> getUninvoicedLogs() async {
    try {
      final driftLogs = await _dailyLogDao.getUninvoicedLogs();
      return driftLogs.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get uninvoiced logs: $e');
    }
  }

  Future<List<DailyLog>> getLogsByStatus(LogStatus status) async {
    try {
      final driftLogs = await _dailyLogDao.getLogsByStatus(status.toString().split('.').last);
      return driftLogs.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get logs by status: $e');
    }
  }

  // Conversion methods between DailyLog model and Drift entities
  DailyLog _convertFromDrift(dynamic driftLog) {
    // driftLog is a generated DailyLog (from Drift)
    return DailyLog(
      id: driftLog.id,
      clientId: driftLog.clientId,
      date: driftLog.date,
      billingMethod: driftLog.billingMethod,
      regularHours: driftLog.regularHours,
      overtimeHours: driftLog.overtimeHours,
      hourlyRate: driftLog.hourlyRate,
      overtimeRate: driftLog.overtimeRate,
      dayRate: driftLog.dayRate,
      isFullDay: driftLog.isFullDay,
      expenses: _expenseMapFromDrift(driftLog.expenses),
      description: driftLog.description,
      status: driftLog.status,
      createdAt: driftLog.createdAt,
      approvedAt: null, // Not in Drift schema, set to null or extend as needed
    );
  }

  dynamic _convertToDrift(DailyLog dailyLog) {
    // Returns a generated DailyLog (from Drift)
    return db.DailyLog(
      id: dailyLog.id,
      clientId: dailyLog.clientId,
      date: dailyLog.date,
      billingMethod: dailyLog.billingMethod,
      regularHours: dailyLog.regularHours,
      overtimeHours: dailyLog.overtimeHours,
      hourlyRate: dailyLog.hourlyRate,
      overtimeRate: dailyLog.overtimeRate,
      dayRate: dailyLog.dayRate,
      isFullDay: dailyLog.isFullDay,
      expenses: _expenseMapToDrift(dailyLog.expenses),
      description: dailyLog.description,
      status: dailyLog.status,
      createdAt: dailyLog.createdAt,
      updatedAt: dailyLog.updatedAt ?? DateTime.now(),
    );
  }

  dynamic _convertToCompanion(DailyLog dailyLog) {
    // Returns a DailyLogsCompanion for inserts
    return db.DailyLogsCompanion(
      id: Value(dailyLog.id),
      clientId: Value(dailyLog.clientId),
      date: Value(dailyLog.date),
      billingMethod: Value(dailyLog.billingMethod),
      regularHours: Value(dailyLog.regularHours),
      overtimeHours: Value(dailyLog.overtimeHours),
      hourlyRate: Value(dailyLog.hourlyRate),
      overtimeRate: Value(dailyLog.overtimeRate),
      dayRate: Value(dailyLog.dayRate),
      isFullDay: Value(dailyLog.isFullDay),
      expenses: Value(_expenseMapToDrift(dailyLog.expenses)),
      description: Value(dailyLog.description),
      status: Value(dailyLog.status),
      createdAt: Value(dailyLog.createdAt),
      updatedAt: Value(dailyLog.updatedAt ?? DateTime.now()),
    );
  }

  // Expense map conversion helpers
  Map<ExpenseCategory, double> _expenseMapFromDrift(Map<String, double> driftMap) {
    return driftMap.map((key, value) => MapEntry(_expenseCategoryFromString(key), value));
  }

  Map<String, double> _expenseMapToDrift(Map<ExpenseCategory, double> modelMap) {
    return modelMap.map((key, value) => MapEntry(key.toString().split('.').last, value));
  }

  ExpenseCategory _expenseCategoryFromString(String str) {
    return ExpenseCategory.values.firstWhere((e) => e.toString().split('.').last == str);
  }
} 