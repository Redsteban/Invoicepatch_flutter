import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/personal_info.dart';
import '../models/business_info.dart';
import '../models/billing_preferences.dart';
import '../models/work_preferences.dart';
import '../models/invoice_settings.dart';
import '../models/notification_preferences.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  PersonalInfo? _personalInfo;
  BusinessInfo? _businessInfo;
  BillingPreferences? _billingPreferences;
  WorkPreferences? _workPreferences;
  InvoiceSettings? _invoiceSettings;
  NotificationPreferences? _notificationPreferences;

  OnboardingBloc() : super(OnboardingInitial()) {
    on<SubmitPersonalInfo>((event, emit) {
      _personalInfo = event.personalInfo;
      emit(BusinessInfoStep());
    });
    on<SubmitBusinessInfo>((event, emit) {
      _businessInfo = event.businessInfo;
      emit(BillingPreferencesStep());
    });
    on<SubmitBillingPreferences>((event, emit) {
      _billingPreferences = event.billingPreferences;
      emit(InvoiceSettingsStep());
    });
    on<SubmitWorkPreferences>((event, emit) {
      _workPreferences = event.workPreferences;
      emit(InvoiceSettingsStep());
    });
    on<SubmitInvoiceSettings>((event, emit) {
      _invoiceSettings = event.invoiceSettings;
      emit(NotificationPreferencesStep());
    });
    on<SubmitNotificationPreferences>((event, emit) {
      _notificationPreferences = event.notificationPreferences;
      emit(OnboardingCompleted());
    });
    on<CompleteOnboarding>((event, emit) {
      emit(OnboardingCompleted());
    });
  }

  // Optionally, expose collected data
  PersonalInfo? get personalInfo => _personalInfo;
  BusinessInfo? get businessInfo => _businessInfo;
  BillingPreferences? get billingPreferences => _billingPreferences;
  WorkPreferences? get workPreferences => _workPreferences;
  InvoiceSettings? get invoiceSettings => _invoiceSettings;
  NotificationPreferences? get notificationPreferences => _notificationPreferences;
} 