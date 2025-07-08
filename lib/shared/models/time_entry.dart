class TimeEntry {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double hours;
  final String clientId;
  final String description;

  TimeEntry({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.hours,
    required this.clientId,
    required this.description,
  });
} 