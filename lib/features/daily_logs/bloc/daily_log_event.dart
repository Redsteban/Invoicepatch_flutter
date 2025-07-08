import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';

abstract class DailyLogEvent extends Equatable {
  const DailyLogEvent();

  @override
  List<Object?> get props => [];
}

class DailyLogLoadRequested extends DailyLogEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? clientId;

  /// Use this for loading all logs or by client only
  const DailyLogLoadRequested({this.clientId})
      : startDate = null,
        endDate = null;

  /// Use this for loading by date range (both dates required)
  const DailyLogLoadRequested.range({required this.startDate, required this.endDate, this.clientId});

  @override
  List<Object?> get props => [startDate, endDate, clientId];
}

class DailyLogCreateRequested extends DailyLogEvent {
  final DailyLog dailyLog;

  const DailyLogCreateRequested({required this.dailyLog});

  @override
  List<Object> get props => [dailyLog];
}

class DailyLogUpdateRequested extends DailyLogEvent {
  final DailyLog dailyLog;

  const DailyLogUpdateRequested({required this.dailyLog});

  @override
  List<Object> get props => [dailyLog];
}

class DailyLogDeleteRequested extends DailyLogEvent {
  final String logId;

  const DailyLogDeleteRequested({required this.logId});

  @override
  List<Object> get props => [logId];
}

class DailyLogStatusUpdateRequested extends DailyLogEvent {
  final String logId;
  final LogStatus newStatus;

  const DailyLogStatusUpdateRequested({
    required this.logId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [logId, newStatus];
}

class DailyLogCalculateTotalRequested extends DailyLogEvent {
  final DateTime startDate;
  final DateTime endDate;

  const DailyLogCalculateTotalRequested({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
} 