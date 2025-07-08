import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';

class RateTemplate extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BillingMethod billingMethod;
  final double? hourlyRate;
  final double? dayRate;
  final double? overtimeRate;
  final double? overtimeMultiplier;
  final Map<String, double> clientSpecificRates;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const RateTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.billingMethod,
    this.hourlyRate,
    this.dayRate,
    this.overtimeRate,
    this.overtimeMultiplier,
    this.clientSpecificRates = const {},
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.lastUsed,
  });

  double? getRateForClient(String clientId) => clientSpecificRates[clientId];
  
  bool get isValidTemplate {
    switch (billingMethod) {
      case BillingMethod.hourly:
        return hourlyRate != null && hourlyRate! > 0;
      case BillingMethod.dayRate:
        return dayRate != null && dayRate! > 0;
      case BillingMethod.mixed:
        return (dayRate != null && dayRate! > 0) || 
               (hourlyRate != null && hourlyRate! > 0);
    }
  }

  String get displayRate {
    switch (billingMethod) {
      case BillingMethod.hourly:
        return '\$${hourlyRate?.toStringAsFixed(2) ?? '0.00'}/hr';
      case BillingMethod.dayRate:
        return '\$${dayRate?.toStringAsFixed(2) ?? '0.00'}/day';
      case BillingMethod.mixed:
        final dayPart = dayRate != null ? '\$${dayRate!.toStringAsFixed(2)}/day' : '';
        final hourPart = hourlyRate != null ? '\$${hourlyRate!.toStringAsFixed(2)}/hr' : '';
        return [dayPart, hourPart].where((s) => s.isNotEmpty).join(' + ');
    }
  }

  String get billingMethodDisplay {
    switch (billingMethod) {
      case BillingMethod.hourly:
        return 'Hourly Rate';
      case BillingMethod.dayRate:
        return 'Day Rate';
      case BillingMethod.mixed:
        return 'Mixed Billing';
    }
  }

  // Quick template creation helpers
  static RateTemplate createHourlyTemplate({
    required String id,
    required String name,
    required double hourlyRate,
    double? overtimeMultiplier,
    String? description,
  }) {
    return RateTemplate(
      id: id,
      name: name,
      description: description,
      billingMethod: BillingMethod.hourly,
      hourlyRate: hourlyRate,
      overtimeRate: overtimeMultiplier != null ? hourlyRate * overtimeMultiplier : null,
      overtimeMultiplier: overtimeMultiplier,
      createdAt: DateTime.now(),
    );
  }

  static RateTemplate createDayRateTemplate({
    required String id,
    required String name,
    required double dayRate,
    double? extraHourlyRate,
    String? description,
  }) {
    return RateTemplate(
      id: id,
      name: name,
      description: description,
      billingMethod: BillingMethod.dayRate,
      dayRate: dayRate,
      hourlyRate: extraHourlyRate,
      createdAt: DateTime.now(),
    );
  }

  static RateTemplate createMixedTemplate({
    required String id,
    required String name,
    required double dayRate,
    required double hourlyRate,
    String? description,
  }) {
    return RateTemplate(
      id: id,
      name: name,
      description: description,
      billingMethod: BillingMethod.mixed,
      dayRate: dayRate,
      hourlyRate: hourlyRate,
      createdAt: DateTime.now(),
    );
  }

  RateTemplate copyWith({
    String? id,
    String? name,
    String? description,
    BillingMethod? billingMethod,
    double? hourlyRate,
    double? dayRate,
    double? overtimeRate,
    double? overtimeMultiplier,
    Map<String, double>? clientSpecificRates,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return RateTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      billingMethod: billingMethod ?? this.billingMethod,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dayRate: dayRate ?? this.dayRate,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      clientSpecificRates: clientSpecificRates ?? this.clientSpecificRates,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, billingMethod, hourlyRate, dayRate, 
    overtimeRate, overtimeMultiplier, clientSpecificRates, 
    isDefault, isActive, createdAt, lastUsed,
  ];
} 