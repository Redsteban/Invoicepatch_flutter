import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoicepatch_contractor/shared/widgets/modern_text_field.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/pay_period_radio_group.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/date_picker_field.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/navigation_button_row.dart';

const emeraldGreen = Color(0xFF50C878);

class InvoiceDetailsStep extends StatefulWidget {
  final void Function(Map<String, dynamic>) onNext;
  final Map<String, dynamic>? initialData;
  const InvoiceDetailsStep({Key? key, required this.onNext, this.initialData}) : super(key: key);

  @override
  State<InvoiceDetailsStep> createState() => _InvoiceDetailsStepState();
}

class _InvoiceDetailsStepState extends State<InvoiceDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  String _periodType = '14-day';
  final _clientNameController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _contractorAddressController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _clientInvoiceNumberController = TextEditingController();
  DateTime _invoiceDeliveryDate = DateTime.now();
  DateTime _payPeriodStart = DateTime.now();
  DateTime _payPeriodEnd = DateTime.now().add(const Duration(days: 13));
  final _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _periodType = widget.initialData!['periodType'] ?? '14-day';
      _clientNameController.text = widget.initialData!['clientName'] ?? '';
      _clientAddressController.text = widget.initialData!['clientAddress'] ?? '';
      _contractorNameController.text = widget.initialData!['contractorName'] ?? '';
      _contractorAddressController.text = widget.initialData!['contractorAddress'] ?? '';
      _invoiceNumberController.text = widget.initialData!['invoiceNumber'] ?? '';
      _clientInvoiceNumberController.text = widget.initialData!['clientInvoiceNumber'] ?? '';
      _payPeriodStart = widget.initialData!['payPeriodStart'] ?? DateTime.now();
      _payPeriodEnd = widget.initialData!['payPeriodEnd'] ?? _payPeriodStart.add(const Duration(days: 13));
      _invoiceDeliveryDate = widget.initialData!['invoiceDeliveryDate'] ?? _payPeriodEnd;
      _companyNameController.text = widget.initialData!['companyName'] ?? '';
    } else {
      _payPeriodStart = DateTime.now();
      _payPeriodEnd = _payPeriodStart.add(const Duration(days: 13));
      _invoiceDeliveryDate = _payPeriodEnd;
      _generateInvoiceNumber();
    }
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    _invoiceNumberController.text = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-001';
  }

  void _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _payPeriodStart : _invoiceDeliveryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _payPeriodStart = picked;
          _payPeriodEnd = picked.add(const Duration(days: 14));
          _invoiceDeliveryDate = _payPeriodEnd;
        } else {
          _invoiceDeliveryDate = picked;
        }
      });
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
            const Text('Pay Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            PayPeriodRadioGroup(
              value: _periodType,
              options: ['14-day', 'monthly'],
              onChanged: (val) => setState(() => _periodType = val ?? _periodType),
              labels: {'14-day': '14-Day', 'monthly': 'Monthly'},
            ),
            const SizedBox(height: 24),
            const Text('Invoice Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _clientNameController,
                label: 'Client Name',
                icon: Icons.business,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _clientAddressController,
                label: 'Client Address',
                icon: Icons.location_on,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _contractorNameController,
                label: 'Contractor Name',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _contractorAddressController,
                label: 'Contractor Address',
                icon: Icons.home,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _companyNameController,
                label: 'Company Name',
                icon: Icons.business_center,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            // Pay Period Start/End
            SizedBox(
              width: 400,
              child: DatePickerField(
                label: 'Pay Period Start',
                icon: Icons.calendar_today,
                selectedDate: _payPeriodStart,
                onDateSelected: (picked) {
                  setState(() {
                    _payPeriodStart = picked;
                    _payPeriodEnd = picked.add(const Duration(days: 14));
                    _invoiceDeliveryDate = _payPeriodEnd;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: DatePickerField(
                label: 'Pay Period End',
                icon: Icons.calendar_month,
                selectedDate: _payPeriodEnd,
                onDateSelected: (_) {}, // End date is auto-calculated
                enabled: false, // Disable since it's auto-calculated
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: DatePickerField(
                label: 'Invoice Delivery Date',
                icon: Icons.event,
                selectedDate: _invoiceDeliveryDate,
                onDateSelected: (picked) {
                  setState(() {
                    _invoiceDeliveryDate = picked;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _invoiceNumberController,
                label: 'Invoice Number',
                icon: Icons.tag,
                readOnly: false,
                enabled: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: ModernTextField(
                controller: _clientInvoiceNumberController,
                label: 'Client Invoice #/First Day Ticket',
                icon: Icons.confirmation_number,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onNext({
                        'periodType': _periodType,
                        'clientName': _clientNameController.text,
                        'clientAddress': _clientAddressController.text,
                        'contractorName': _contractorNameController.text,
                        'contractorAddress': _contractorAddressController.text,
                        'invoiceNumber': _invoiceNumberController.text,
                        'clientInvoiceNumber': _clientInvoiceNumberController.text,
                        'invoiceDeliveryDate': _invoiceDeliveryDate,
                        'payPeriodStart': _payPeriodStart,
                        'payPeriodEnd': _payPeriodEnd,
                        'companyName': _companyNameController.text,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50C878),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(String value, String label) {
    final bool selected = _periodType == value;
    return GestureDetector(
      onTap: () => setState(() => _periodType = value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? emeraldGreen : Colors.black,
                width: 2,
              ),
              color: selected ? emeraldGreen : Colors.transparent,
            ),
            child: selected
                ? const Icon(Icons.circle, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
} 