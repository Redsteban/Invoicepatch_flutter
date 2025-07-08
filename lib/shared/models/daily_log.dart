import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';

class DailyLog extends Equatable {
  final String id;
  final String clientId;
  final DateTime date;
  final BillingMethod billingMethod;
  final double? regularHours;
  final double? overtimeHours;
  final double? hourlyRate;
  final double? overtimeRate;
  final double? dayRate;
  final bool isFullDay;
  final Map<ExpenseCategory, double> expenses;
  final String? description;
  final LogStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? updatedAt;
  final bool worked;
  // Revenue fields
  final double? dailySubsistence;
  final double? truckRate;
  final double? kmsDriven;
  final double? kmsRate;
  final double? otherCharges;

  const DailyLog({
    required this.id,
    required this.clientId,
    required this.date,
    required this.billingMethod,
    this.regularHours,
    this.overtimeHours,
    this.hourlyRate,
    this.overtimeRate,
    this.dayRate,
    this.isFullDay = false,
    this.expenses = const {},
    this.description,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.updatedAt,
    this.worked = true,
    this.dailySubsistence,
    this.truckRate,
    this.kmsDriven,
    this.kmsRate,
    this.otherCharges,
  });

  // Complex calculation getter
  double get totalAmount {
    double total = 0.0;
    
    switch (billingMethod) {
      case BillingMethod.hourly:
        total += (regularHours ?? 0) * (hourlyRate ?? 0);
        total += (overtimeHours ?? 0) * (overtimeRate ?? hourlyRate ?? 0);
        break;
      
      case BillingMethod.dayRate:
        if (isFullDay) {
          total += dayRate ?? 0;
        } else {
          // Partial day calculation
          total += ((regularHours ?? 0) / 8.0) * (dayRate ?? 0);
        }
        break;
      
      case BillingMethod.mixed:
        total += dayRate ?? 0;
        if ((overtimeHours ?? 0) > 0) {
          total += (overtimeHours ?? 0) * (overtimeRate ?? hourlyRate ?? 0);
        }
        break;
    }
    // Add expenses
    total += expenses.values.fold(0.0, (sum, amount) => sum + amount);
    return total;
  }

  double get totalExpenses {
    return expenses.values.fold(0, (sum, amount) => sum + amount);
  }

  double get grandTotal {
    return totalAmount + totalExpenses;
  }

  // Validation methods
  bool get isValidForBilling {
    switch (billingMethod) {
      case BillingMethod.hourly:
        return (regularHours != null && regularHours! > 0) || 
               (overtimeHours != null && overtimeHours! > 0);
      case BillingMethod.dayRate:
        return (isFullDay == true || !isFullDay == true) || 
               (overtimeHours != null && overtimeHours! > 0);
      case BillingMethod.mixed:
        return dayRate != null && dayRate! > 0;
    }
  }

  DailyLog copyWith({
    String? id,
    String? clientId,
    DateTime? date,
    BillingMethod? billingMethod,
    double? regularHours,
    double? overtimeHours,
    double? hourlyRate,
    double? overtimeRate,
    double? dayRate,
    bool? isFullDay,
    Map<ExpenseCategory, double>? expenses,
    String? description,
    LogStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? updatedAt,
    bool? worked,
    double? dailySubsistence,
    double? truckRate,
    double? kmsDriven,
    double? kmsRate,
    double? otherCharges,
  }) {
    return DailyLog(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      billingMethod: billingMethod ?? this.billingMethod,
      regularHours: regularHours ?? this.regularHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      dayRate: dayRate ?? this.dayRate,
      isFullDay: isFullDay ?? this.isFullDay,
      expenses: expenses ?? this.expenses,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      worked: worked ?? this.worked,
      dailySubsistence: dailySubsistence ?? this.dailySubsistence,
      truckRate: truckRate ?? this.truckRate,
      kmsDriven: kmsDriven ?? this.kmsDriven,
      kmsRate: kmsRate ?? this.kmsRate,
      otherCharges: otherCharges ?? this.otherCharges,
    );
  }

  @override
  List<Object?> get props => [
    id, clientId, date, billingMethod, regularHours, overtimeHours, hourlyRate, overtimeRate, dayRate, isFullDay, expenses, description, status, createdAt, approvedAt, updatedAt, worked,
    dailySubsistence, truckRate, kmsDriven, kmsRate, otherCharges,
  ];
} 