import 'package:equatable/equatable.dart';
import '../models/personal_info.dart';
import '../models/business_info.dart';
import '../models/billing_preferences.dart';
import '../models/work_preferences.dart';
import '../models/invoice_settings.dart';
import '../models/notification_preferences.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class SubmitPersonalInfo extends OnboardingEvent {
  final PersonalInfo personalInfo;
  const SubmitPersonalInfo(this.personalInfo);
  @override
  List<Object?> get props => [personalInfo];
}

class SubmitBusinessInfo extends OnboardingEvent {
  final BusinessInfo businessInfo;
  const SubmitBusinessInfo(this.businessInfo);
  @override
  List<Object?> get props => [businessInfo];
}

class SubmitBillingPreferences extends OnboardingEvent {
  final BillingPreferences billingPreferences;
  const SubmitBillingPreferences(this.billingPreferences);
  @override
  List<Object?> get props => [billingPreferences];
}

class SubmitWorkPreferences extends OnboardingEvent {
  final WorkPreferences workPreferences;
  const SubmitWorkPreferences(this.workPreferences);
  @override
  List<Object?> get props => [workPreferences];
}

class SubmitInvoiceSettings extends OnboardingEvent {
  final InvoiceSettings invoiceSettings;
  const SubmitInvoiceSettings(this.invoiceSettings);
  @override
  List<Object?> get props => [invoiceSettings];
}

class SubmitNotificationPreferences extends OnboardingEvent {
  final NotificationPreferences notificationPreferences;
  const SubmitNotificationPreferences(this.notificationPreferences);
  @override
  List<Object?> get props => [notificationPreferences];
}

class CompleteOnboarding extends OnboardingEvent {} 