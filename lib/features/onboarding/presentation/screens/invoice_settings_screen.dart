import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../models/invoice_settings.dart';
import '../../../../shared/models/enums/payment_terms.dart';

class InvoiceSettingsScreen extends StatefulWidget {
  const InvoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends State<InvoiceSettingsScreen> {
  PaymentTerms _selectedTerms = PaymentTerms.net15;
  final _prefixController = TextEditingController();
  final _notesController = TextEditingController();

  void _submit() {
    final settings = InvoiceSettings(
      invoiceNumberPrefix: _prefixController.text,
      paymentTerms: _selectedTerms.name,
    );
    context.read<OnboardingBloc>().add(SubmitInvoiceSettings(settings));
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _notesController.dispose();
    super.dispose();
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
        title: const Text('Invoice Settings', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text('Default Payment Terms', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<PaymentTerms>(
              value: _selectedTerms,
              isExpanded: true,
              items: PaymentTerms.values.map((e) => DropdownMenuItem(
                value: e,
                child: Text(_paymentTermsLabel(e), style: const TextStyle(color: Colors.black)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedTerms = v!),
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Payment Terms',
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
            const SizedBox(height: 16),
            const Text('Invoice Prefix', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _prefixController,
              decoration: InputDecoration(
                labelText: 'e.g. INV, CNTR',
                prefixIcon: const Icon(Icons.confirmation_number, color: emeraldGreen),
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
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text('Default Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'e.g. Thank you for your business!',
                prefixIcon: const Icon(Icons.sticky_note_2, color: emeraldGreen),
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
              style: const TextStyle(color: Colors.black),
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentTermsLabel(PaymentTerms terms) {
    switch (terms) {
      case PaymentTerms.net15:
        return 'Net 15 days';
      case PaymentTerms.net30:
        return 'Net 30 days';
      case PaymentTerms.net45:
        return 'Net 45 days';
      case PaymentTerms.immediate:
        return 'Immediate';
    }
  }
} 