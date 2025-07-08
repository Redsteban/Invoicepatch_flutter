import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';

abstract class DailyLogState extends Equatable {
  const DailyLogState();

  @override
  List<Object?> get props => [];
}

class DailyLogInitial extends DailyLogState {
  const DailyLogInitial();
}

class DailyLogLoading extends DailyLogState {
  const DailyLogLoading();
}

class DailyLogLoaded extends DailyLogState {
  final List<DailyLog> logs;
  final double totalAmount;

  const DailyLogLoaded({
    required this.logs,
    this.totalAmount = 0.0,
  });

  @override
  List<Object> get props => [logs, totalAmount];

  DailyLogLoaded copyWith({
    List<DailyLog>? logs,
    double? totalAmount,
  }) {
    return DailyLogLoaded(
      logs: logs ?? this.logs,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class DailyLogOperationSuccess extends DailyLogState {
  final String message;
  final List<DailyLog> logs;

  const DailyLogOperationSuccess({
    required this.message,
    required this.logs,
  });

  @override
  List<Object> get props => [message, logs];
}

class DailyLogFailure extends DailyLogState {
  final String message;

  const DailyLogFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class DailyLogTotalCalculated extends DailyLogState {
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int logCount;

  const DailyLogTotalCalculated({
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.logCount,
  });

  @override
  List<Object> get props => [totalAmount, startDate, endDate, logCount];
}

class DailyLogSaving extends DailyLogState {
  const DailyLogSaving();
}

class DailyLogSaved extends DailyLogState {
  final DailyLog savedLog;
  final String message;

  const DailyLogSaved({
    required this.savedLog,
    required this.message,
  });

  @override
  List<Object> get props => [savedLog, message];
}

class DailyLogDeleted extends DailyLogState {
  final String logId;
  final String message;

  const DailyLogDeleted({
    required this.logId,
    required this.message,
  });

  @override
  List<Object> get props => [logId, message];
} 