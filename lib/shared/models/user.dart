import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/enums/payment_terms.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final BusinessInfo businessInfo;
  final BillingPreferences billingPreferences;
  final UserPreferences userPreferences;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.businessInfo,
    required this.billingPreferences,
    required this.userPreferences,
    this.onboardingCompleted = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
    BusinessInfo? businessInfo,
    BillingPreferences? billingPreferences,
    UserPreferences? userPreferences,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      businessInfo: businessInfo ?? this.businessInfo,
      billingPreferences: billingPreferences ?? this.billingPreferences,
      userPreferences: userPreferences ?? this.userPreferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    id, email, fullName, phoneNumber, profilePhotoUrl,
    businessInfo, billingPreferences, userPreferences,
    onboardingCompleted, createdAt, lastLoginAt,
  ];
}

class BusinessInfo extends Equatable {
  final String businessName;
  final String? businessNumber;
  final String? gstNumber;
  final Address businessAddress;
  final String province;
  final String? logoUrl;
  final String? website;
  final String? bankAccountInfo;

  const BusinessInfo({
    required this.businessName,
    this.businessNumber,
    this.gstNumber,
    required this.businessAddress,
    required this.province,
    this.logoUrl,
    this.website,
    this.bankAccountInfo,
  });

  // Canadian provinces for validation
  static const List<String> canadianProvinces = [
    'AB', 'BC', 'MB', 'NB', 'NL', 'NT', 'NS', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'
  ];

  bool get hasGSTNumber => gstNumber?.isNotEmpty == true;
  bool get isValidProvince => canadianProvinces.contains(province);

  // Tax rates by province for calculations
  static const Map<String, Map<String, double>> taxRates = {
    'AB': {'gst': 0.05, 'pst': 0.0},
    'BC': {'gst': 0.05, 'pst': 0.07},
    'MB': {'gst': 0.05, 'pst': 0.07},
    'NB': {'gst': 0.05, 'pst': 0.10},
    'NL': {'gst': 0.05, 'pst': 0.10},
    'NT': {'gst': 0.05, 'pst': 0.0},
    'NS': {'gst': 0.05, 'pst': 0.10},
    'NU': {'gst': 0.05, 'pst': 0.0},
    'ON': {'gst': 0.05, 'pst': 0.08},
    'PE': {'gst': 0.05, 'pst': 0.10},
    'QC': {'gst': 0.05, 'pst': 0.09975},
    'SK': {'gst': 0.05, 'pst': 0.06},
    'YT': {'gst': 0.05, 'pst': 0.0},
  };

  double get gstRate => taxRates[province]?['gst'] ?? 0.05;
  double get pstRate => taxRates[province]?['pst'] ?? 0.0;

  BusinessInfo copyWith({
    String? businessName,
    String? businessNumber,
    String? gstNumber,
    Address? businessAddress,
    String? province,
    String? logoUrl,
    String? website,
    String? bankAccountInfo,
  }) {
    return BusinessInfo(
      businessName: businessName ?? this.businessName,
      businessNumber: businessNumber ?? this.businessNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      province: province ?? this.province,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      bankAccountInfo: bankAccountInfo ?? this.bankAccountInfo,
    );
  }

  @override
  List<Object?> get props => [
    businessName, businessNumber, gstNumber, businessAddress,
    province, logoUrl, website, bankAccountInfo,
  ];
}

class UserPreferences extends Equatable {
  final String dailyNotificationTime; // "18:00"
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final String defaultInvoicePrefix;
  final PaymentTerms defaultPaymentTerms;
  final bool biometricAuthEnabled;

  const UserPreferences({
    this.dailyNotificationTime = '18:00',
    this.emailNotificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.defaultInvoicePrefix = 'INV',
    this.defaultPaymentTerms = PaymentTerms.net30,
    this.biometricAuthEnabled = false,
  });

  UserPreferences copyWith({
    String? dailyNotificationTime,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    String? defaultInvoicePrefix,
    PaymentTerms? defaultPaymentTerms,
    bool? biometricAuthEnabled,
  }) {
    return UserPreferences(
      dailyNotificationTime: dailyNotificationTime ?? this.dailyNotificationTime,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      defaultInvoicePrefix: defaultInvoicePrefix ?? this.defaultInvoicePrefix,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
    );
  }

  @override
  List<Object?> get props => [
    dailyNotificationTime, emailNotificationsEnabled, pushNotificationsEnabled,
    defaultInvoicePrefix, defaultPaymentTerms, biometricAuthEnabled,
  ];
} 