import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_state.dart';
import 'personal_info_screen.dart';
import 'business_info_screen.dart';
import 'billing_preferences_screen.dart';
import 'work_preferences_screen.dart';
import 'invoice_settings_screen.dart';
import 'notification_preferences_screen.dart';

// This screen is now deprecated and not used in the flow.

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  int _stepIndex(OnboardingState state) {
    if (state is PersonalInfoStep) return 0;
    if (state is BusinessInfoStep) return 1;
    if (state is BillingPreferencesStep) return 2;
    if (state is InvoiceSettingsStep) return 3;
    if (state is NotificationPreferencesStep) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final step = _stepIndex(state);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text('Onboarding', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (step + 1) / 5,
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildStepScreen(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepScreen(OnboardingState state) {
    if (state is PersonalInfoStep) {
      return const PersonalInfoScreen(prefilledEmail: '');
    } else if (state is BusinessInfoStep) {
      return const BusinessInfoScreen();
    } else if (state is BillingPreferencesStep) {
      return const BillingPreferencesScreen();
    } else if (state is InvoiceSettingsStep) {
      return const InvoiceSettingsScreen();
    } else if (state is NotificationPreferencesStep) {
      return const NotificationPreferencesScreen();
    } else {
      // Default to first step
      return const PersonalInfoScreen(prefilledEmail: '');
    }
  }
} 