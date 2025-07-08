import 'package:invoicepatch_contractor/shared/models/enums/work_type.dart';

class WorkPreferences {
  final List<WorkType> workTypes;
  final List<String> industries;
  final int daysPerWeek;
  final int hoursPerDay;

  WorkPreferences({
    required this.workTypes,
    required this.industries,
    required this.daysPerWeek,
    required this.hoursPerDay,
  });
} 