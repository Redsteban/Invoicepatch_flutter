import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';

class Client extends Equatable {
  final String id;
  final String name;
  final String company;
  final String email;
  final String? phone;
  final Address address;
  final BillingPreferences billingPreferences;
  final Map<String, double> rateHistory; // ISO date -> rate
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    this.phone,
    required this.address,
    required this.billingPreferences,
    this.rateHistory = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // Returns the most recent rate
  double getCurrentRate() {
    if (rateHistory.isEmpty) return 0.0;
    final latest = rateHistory.entries.reduce((a, b) => a.key.compareTo(b.key) > 0 ? a : b);
    return latest.value;
  }

  // Returns the rate for a specific date, or null if not found
  double? getRateForDate(DateTime date) {
    if (rateHistory.isEmpty) return null;
    final sorted = rateHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    double? lastRate;
    for (final entry in sorted) {
      final entryDate = DateTime.parse(entry.key);
      if (entryDate.isAfter(date)) break;
      lastRate = entry.value;
    }
    return lastRate;
  }

  Client copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    Address? address,
    BillingPreferences? billingPreferences,
    Map<String, double>? rateHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      billingPreferences: billingPreferences ?? this.billingPreferences,
      rateHistory: rateHistory ?? this.rateHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, company, email, phone, address, billingPreferences, rateHistory, createdAt, updatedAt
  ];
} 