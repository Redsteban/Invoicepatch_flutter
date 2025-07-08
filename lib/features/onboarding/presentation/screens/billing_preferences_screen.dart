import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../models/billing_preferences.dart';
import 'package:lottie/lottie.dart';

class BillingPreferencesScreen extends StatefulWidget {
  const BillingPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<BillingPreferencesScreen> createState() => _BillingPreferencesScreenState();
}

class _BillingPreferencesScreenState extends State<BillingPreferencesScreen> {
  BillingMethod _selectedMethod = BillingMethod.hourly;
  final _hourlyRateController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _overtimeMultiplierController = TextEditingController();
  final _overtimeDayRateController = TextEditingController();
  final _overtimeThresholdController = TextEditingController();
  bool _rateVariationByClient = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _dayRateController.dispose();
    _overtimeMultiplierController.dispose();
    _overtimeDayRateController.dispose();
    _overtimeThresholdController.dispose();
    super.dispose();
  }

  void _submit() {
    final prefs = BillingPreferences(
      primaryMethod: _selectedMethod,
      defaultHourlyRate: _hourlyRateController.text.isNotEmpty ? double.tryParse(_hourlyRateController.text) : null,
      defaultDayRate: _dayRateController.text.isNotEmpty ? double.tryParse(_dayRateController.text) : null,
      overtimeMultiplier: _overtimeMultiplierController.text.isNotEmpty ? double.tryParse(_overtimeMultiplierController.text) : null,
      overtimeDayRate: _overtimeDayRateController.text.isNotEmpty ? double.tryParse(_overtimeDayRateController.text) : null,
      overtimeThresholdHours: _overtimeThresholdController.text.isNotEmpty ? int.tryParse(_overtimeThresholdController.text) : null,
      rateVariationByClient: _rateVariationByClient,
    );
    context.read<OnboardingBloc>().add(SubmitBillingPreferences(prefs));
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF50C878);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Billing Preferences', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/app_logo.png',
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<BillingMethod>(
                      value: _selectedMethod,
                      items: [
                        DropdownMenuItem(
                          value: BillingMethod.hourly,
                          child: Text('Hourly', style: TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: BillingMethod.dayRate,
                          child: Text('Day Rate', style: TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: BillingMethod.mixed,
                          child: Text('Mixed', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Primary Billing Method',
                        prefixIcon: const Icon(Icons.payments, color: emeraldGreen),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: emeraldGreen, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        if (_selectedMethod == BillingMethod.hourly || _selectedMethod == BillingMethod.mixed)
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _hourlyRateController,
                              decoration: const InputDecoration(
                                labelText: 'Default Hourly Rate',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        if (_selectedMethod == BillingMethod.dayRate || _selectedMethod == BillingMethod.mixed)
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _dayRateController,
                              decoration: const InputDecoration(labelText: 'Default Day Rate'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        SizedBox(
                          width: 220,
                          child: TextFormField(
                            controller: _overtimeThresholdController,
                            decoration: const InputDecoration(
                              labelText: 'Hours Threshold for Overtime',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        if (_selectedMethod == BillingMethod.hourly || _selectedMethod == BillingMethod.mixed)
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _overtimeMultiplierController,
                              decoration: const InputDecoration(
                                labelText: 'Overtime Multiplier (e.g. 1.5)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        if (_selectedMethod == BillingMethod.dayRate || _selectedMethod == BillingMethod.mixed)
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _overtimeDayRateController,
                              decoration: const InputDecoration(labelText: 'Overtime Day Rate'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('Rate Variation by Client'),
                      value: _rateVariationByClient,
                      onChanged: (v) => setState(() => _rateVariationByClient = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AnimatedButton(
                onTap: _submit,
                label: 'Continue',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  const AnimatedButton({Key? key, required this.onTap, required this.label}) : super(key: key);
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.05,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF01C38D);
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: emeraldGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: emeraldGreen.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
} 