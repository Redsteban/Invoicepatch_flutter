import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/shared/repositories/daily_log_repository.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'daily_log_event.dart';
import 'daily_log_state.dart';

class DailyLogBloc extends Bloc<DailyLogEvent, DailyLogState> {
  final DailyLogRepository _dailyLogRepository;

  DailyLogBloc({required DailyLogRepository dailyLogRepository})
      : _dailyLogRepository = dailyLogRepository,
        super(const DailyLogInitial()) {
    // Register event handlers
    on<DailyLogLoadRequested>(_onDailyLogLoadRequested);
    on<DailyLogCreateRequested>(_onDailyLogCreateRequested);
    on<DailyLogUpdateRequested>(_onDailyLogUpdateRequested);
    on<DailyLogDeleteRequested>(_onDailyLogDeleteRequested);
    on<DailyLogStatusUpdateRequested>(_onDailyLogStatusUpdateRequested);
    on<DailyLogCalculateTotalRequested>(_onDailyLogCalculateTotalRequested);
  }

  Future<void> _onDailyLogLoadRequested(
    DailyLogLoadRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    emit(const DailyLogLoading());
    try {
      List<DailyLog> logs;
      if (event is DailyLogLoadRequested && event.startDate == null && event.endDate == null) {
        if (event.clientId != null) {
          logs = await _dailyLogRepository.getLogsByClient(event.clientId!);
        } else {
          logs = await _dailyLogRepository.getAll();
        }
      } else if (event is DailyLogLoadRequested && event.startDate != null && event.endDate != null) {
        logs = await _dailyLogRepository.getLogsForDateRange(event.startDate!, event.endDate!);
      } else {
        logs = await _dailyLogRepository.getAll();
      }
      final totalAmount = logs.fold<double>(
        0.0,
        (sum, log) => sum + log.totalAmount,
      );
      emit(DailyLogLoaded(
        logs: logs,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to load daily logs:  {e.toString()}'));
    }
  }

  Future<void> _onDailyLogCreateRequested(
    DailyLogCreateRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    emit(const DailyLogSaving());
    try {
      final createdLog = await _dailyLogRepository.create(event.dailyLog);
      emit(DailyLogSaved(
        savedLog: createdLog,
        message: 'Daily log created successfully',
      ));
      add(const DailyLogLoadRequested());
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to create daily log:  {e.toString()}'));
    }
  }

  Future<void> _onDailyLogUpdateRequested(
    DailyLogUpdateRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    emit(const DailyLogSaving());
    try {
      final updatedLog = await _dailyLogRepository.update(event.dailyLog);
      emit(DailyLogSaved(
        savedLog: updatedLog,
        message: 'Daily log updated successfully',
      ));
      add(const DailyLogLoadRequested());
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to update daily log:  {e.toString()}'));
    }
  }

  Future<void> _onDailyLogDeleteRequested(
    DailyLogDeleteRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      await _dailyLogRepository.delete(event.logId);
      emit(DailyLogDeleted(
        logId: event.logId,
        message: 'Daily log deleted successfully',
      ));
      add(const DailyLogLoadRequested());
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to delete daily log:  {e.toString()}'));
    }
  }

  Future<void> _onDailyLogStatusUpdateRequested(
    DailyLogStatusUpdateRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    try {
      final currentLog = await _dailyLogRepository.getById(event.logId);
      if (currentLog == null) {
        emit(const DailyLogFailure(message: 'Daily log not found'));
        return;
      }
      final updatedLog = currentLog.copyWith(
        status: event.newStatus,
        updatedAt: DateTime.now(),
      );
      await _dailyLogRepository.update(updatedLog);
      emit(DailyLogOperationSuccess(
        message: 'Status updated to  {_getStatusDisplayName(event.newStatus)}',
        logs: [],
      ));
      add(const DailyLogLoadRequested());
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to update status:  {e.toString()}'));
    }
  }

  Future<void> _onDailyLogCalculateTotalRequested(
    DailyLogCalculateTotalRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    emit(const DailyLogLoading());
    try {
      final logs = await _dailyLogRepository.getLogsForDateRange(
        event.startDate,
        event.endDate,
      );
      final totalAmount = logs.fold<double>(
        0.0,
        (sum, log) => sum + log.totalAmount,
      );
      emit(DailyLogTotalCalculated(
        totalAmount: totalAmount,
        startDate: event.startDate,
        endDate: event.endDate,
        logCount: logs.length,
      ));
    } catch (e) {
      emit(DailyLogFailure(message: 'Failed to calculate total: ￿{e.toString()}'));
    }
  }

  String _getStatusDisplayName(LogStatus status) {
    switch (status) {
      case LogStatus.draft:
        return 'Draft';
      case LogStatus.pending:
        return 'Pending Review';
      case LogStatus.approved:
        return 'Approved';
      case LogStatus.rejected:
        return 'Rejected';
    }
  }
} 