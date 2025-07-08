import '../../../shared/models/enums/billing_method.dart';

class BillingPreferences {
  final BillingMethod primaryMethod;
  final double? defaultHourlyRate;
  final double? defaultDayRate;
  final double? overtimeMultiplier;
  final double? overtimeDayRate;
  final int? overtimeThresholdHours;
  final bool rateVariationByClient;

  BillingPreferences({
    required this.primaryMethod,
    this.defaultHourlyRate,
    this.defaultDayRate,
    this.overtimeMultiplier,
    this.overtimeDayRate,
    this.overtimeThresholdHours,
    this.rateVariationByClient = false,
  });
} 