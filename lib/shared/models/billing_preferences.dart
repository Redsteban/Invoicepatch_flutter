import 'enums/billing_method.dart';

class BillingPreferences {
  final BillingMethod primaryMethod;
  final double? defaultHourlyRate;
  final double? defaultDayRate;
  final double? defaultOvertimeRate;
  final double overtimeMultiplier;
  final int overtimeThresholdHours;
  final bool allowRateVariationByClient;
  final Map<String, double> clientSpecificRates;

  BillingPreferences({
    required this.primaryMethod,
    this.defaultHourlyRate,
    this.defaultDayRate,
    this.defaultOvertimeRate,
    this.overtimeMultiplier = 1.5,
    this.overtimeThresholdHours = 8,
    this.allowRateVariationByClient = false,
    Map<String, double>? clientSpecificRates,
  }) : clientSpecificRates = clientSpecificRates ?? {};

  BillingPreferences.empty()
      : primaryMethod = BillingMethod.hourly,
        defaultHourlyRate = null,
        defaultDayRate = null,
        defaultOvertimeRate = null,
        overtimeMultiplier = 1.5,
        overtimeThresholdHours = 8,
        allowRateVariationByClient = false,
        clientSpecificRates = {};

  BillingPreferences copyWith({
    BillingMethod? primaryMethod,
    double? defaultHourlyRate,
    double? defaultDayRate,
    double? defaultOvertimeRate,
    double? overtimeMultiplier,
    int? overtimeThresholdHours,
    bool? allowRateVariationByClient,
    Map<String, double>? clientSpecificRates,
  }) {
    return BillingPreferences(
      primaryMethod: primaryMethod ?? this.primaryMethod,
      defaultHourlyRate: defaultHourlyRate ?? this.defaultHourlyRate,
      defaultDayRate: defaultDayRate ?? this.defaultDayRate,
      defaultOvertimeRate: defaultOvertimeRate ?? this.defaultOvertimeRate,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      overtimeThresholdHours: overtimeThresholdHours ?? this.overtimeThresholdHours,
      allowRateVariationByClient: allowRateVariationByClient ?? this.allowRateVariationByClient,
      clientSpecificRates: clientSpecificRates ?? this.clientSpecificRates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryMethod': primaryMethod.toString().split('.').last,
      'defaultHourlyRate': defaultHourlyRate,
      'defaultDayRate': defaultDayRate,
      'defaultOvertimeRate': defaultOvertimeRate,
      'clientSpecificRates': clientSpecificRates,
    };
  }

  factory BillingPreferences.fromMap(Map<String, dynamic> map) {
    return BillingPreferences(
      primaryMethod: BillingMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['primaryMethod'],
        orElse: () => BillingMethod.hourly,
      ),
      defaultHourlyRate: map['defaultHourlyRate']?.toDouble(),
      defaultDayRate: map['defaultDayRate']?.toDouble(),
      defaultOvertimeRate: map['defaultOvertimeRate']?.toDouble(),
      clientSpecificRates: Map<String, double>.from(map['clientSpecificRates'] ?? {}),
    );
  }
} 