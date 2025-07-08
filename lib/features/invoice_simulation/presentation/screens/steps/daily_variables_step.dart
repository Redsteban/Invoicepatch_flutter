import 'package:flutter/material.dart';
import 'package:invoicepatch_contractor/shared/widgets/modern_text_field.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/navigation_button_row.dart';

class DailyVariablesStep extends StatefulWidget {
  final void Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  final Map<String, dynamic>? initialData;
  const DailyVariablesStep({Key? key, required this.onNext, required this.onBack, this.initialData}) : super(key: key);

  @override
  State<DailyVariablesStep> createState() => _DailyVariablesStepState();
}

class _DailyVariablesStepState extends State<DailyVariablesStep> {
  final _formKey = GlobalKey<FormState>();
  final _truckRateController = TextEditingController();
  final _kmsDrivenController = TextEditingController();
  final _kmsRateController = TextEditingController();
  final _otherChargesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _truckRateController.text = widget.initialData!['truckRate']?.toString() ?? '';
      _kmsDrivenController.text = widget.initialData!['kmsDriven']?.toString() ?? '';
      _kmsRateController.text = widget.initialData!['kmsRate']?.toString() ?? '';
      _otherChargesController.text = widget.initialData!['otherCharges']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Variables', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ModernTextField(
              controller: _truckRateController,
              label: 'Truck Rate',
              icon: Icons.local_shipping,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _kmsDrivenController,
              label: 'Kms Driven per Day',
              icon: Icons.speed,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _kmsRateController,
              label: 'Kms Rate',
              icon: Icons.route,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _otherChargesController,
              label: 'Other Charges',
              icon: Icons.add_circle_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            NavigationButtonRow(
              onBack: widget.onBack,
              onNext: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext({
                    'truckRate': double.tryParse(_truckRateController.text) ?? 0,
                    'kmsDriven': double.tryParse(_kmsDrivenController.text) ?? 0,
                    'kmsRate': double.tryParse(_kmsRateController.text) ?? 0,
                    'otherCharges': double.tryParse(_otherChargesController.text) ?? 0,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 