import 'package:equatable/equatable.dart';
import '../models/personal_info.dart';
import '../models/business_info.dart';
import '../models/billing_preferences.dart';
import '../models/work_preferences.dart';
import '../models/invoice_settings.dart';
import '../models/notification_preferences.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);
  @override
  List<Object?> get props => [message];
}

class PersonalInfoStep extends OnboardingState {
  final PersonalInfo? personalInfo;
  const PersonalInfoStep({this.personalInfo});
  @override
  List<Object?> get props => [personalInfo];
}

class BusinessInfoStep extends OnboardingState {
  final BusinessInfo? businessInfo;
  const BusinessInfoStep({this.businessInfo});
  @override
  List<Object?> get props => [businessInfo];
}

class BillingPreferencesStep extends OnboardingState {
  final BillingPreferences? billingPreferences;
  const BillingPreferencesStep({this.billingPreferences});
  @override
  List<Object?> get props => [billingPreferences];
}

class WorkPreferencesStep extends OnboardingState {
  final WorkPreferences? workPreferences;
  const WorkPreferencesStep({this.workPreferences});
  @override
  List<Object?> get props => [workPreferences];
}

class InvoiceSettingsStep extends OnboardingState {
  final InvoiceSettings? invoiceSettings;
  const InvoiceSettingsStep({this.invoiceSettings});
  @override
  List<Object?> get props => [invoiceSettings];
}

class NotificationPreferencesStep extends OnboardingState {
  final NotificationPreferences? notificationPreferences;
  const NotificationPreferencesStep({this.notificationPreferences});
  @override
  List<Object?> get props => [notificationPreferences];
}

class OnboardingCompleted extends OnboardingState {} 