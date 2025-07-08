import 'package:flutter/material.dart';
import 'package:invoicepatch_contractor/shared/widgets/modern_text_field.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/navigation_button_row.dart';

class RatesConfigurationStep extends StatefulWidget {
  final void Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  final Map<String, dynamic>? initialData;
  const RatesConfigurationStep({Key? key, required this.onNext, required this.onBack, this.initialData}) : super(key: key);

  @override
  State<RatesConfigurationStep> createState() => _RatesConfigurationStepState();
}

class _RatesConfigurationStepState extends State<RatesConfigurationStep> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  String _payType = 'hourly';
  final _rateController = TextEditingController();
  final _dailySubsistenceController = TextEditingController();
  final _truckRateController = TextEditingController();
  final _kmsDrivenController = TextEditingController();
  final _kmsRateController = TextEditingController();
  final _otherChargesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _companyNameController.text = widget.initialData!['companyName'] ?? '';
      _payType = widget.initialData!['payType'] ?? 'hourly';
      _rateController.text = widget.initialData!['rate']?.toString() ?? '';
      _dailySubsistenceController.text = widget.initialData!['dailySubsistence']?.toString() ?? '';
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
            const Text('Rates Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please Choose',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 400,
              child: DropdownButtonFormField<String>(
                value: _payType,
                decoration: InputDecoration(
                  labelText: 'Pay Type',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.payments, color: emeraldGreen),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: emeraldGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: emeraldGreen),
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                items: const [
                  DropdownMenuItem(value: 'hourly', child: Text('Hourly Rate')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily Rate')),
                ],
                onChanged: (value) => setState(() => _payType = value!),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _rateController,
                label: _payType == 'hourly' ? 'Hourly Rate' : 'Daily Rate',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _dailySubsistenceController,
                label: 'Daily Subsistence',
                icon: Icons.restaurant,
                keyboardType: TextInputType.number,
                helperText: 'Tax-free allowance',
              ),
            ),
            const SizedBox(height: 32),
            const Text('Daily Variables', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _truckRateController,
                label: 'Truck Rate',
                icon: Icons.local_shipping,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _kmsDrivenController,
                label: 'Kms Driven per Day',
                icon: Icons.speed,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _kmsRateController,
                label: 'Kms Rate',
                icon: Icons.route,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _otherChargesController,
                label: 'Other Charges',
                icon: Icons.add_circle_outline,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 32),
            NavigationButtonRow(
              onBack: widget.onBack,
              onNext: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext({
                    'companyName': _companyNameController.text,
                    'payType': _payType,
                    'rate': double.tryParse(_rateController.text) ?? 0,
                    'dailySubsistence': double.tryParse(_dailySubsistenceController.text) ?? 0,
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