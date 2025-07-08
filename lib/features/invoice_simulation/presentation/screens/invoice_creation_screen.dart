import 'package:flutter/material.dart';
import 'steps/invoice_details_step.dart';
import 'steps/rates_configuration_step.dart';
import 'steps/invoice_log_step.dart';
import 'package:invoicepatch_contractor/shared/models/time_entry.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/daily_logs_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/models/invoice_data.dart';

const emeraldGreen = Color(0xFF50C878);

class InvoiceCreationScreen extends StatefulWidget {
  final TimeEntry? prefilledTimeEntry;
  const InvoiceCreationScreen({Key? key, this.prefilledTimeEntry}) : super(key: key);
  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  int _currentStep = 0;
  Map<String, dynamic> _formData = {};
  final TextEditingController _hoursWorkedController = TextEditingController();
  String _payType = '';

  @override
  void initState() {
    super.initState();
    if (widget.prefilledTimeEntry != null) {
      final hours = widget.prefilledTimeEntry!.hours;
      _hoursWorkedController.text = hours.toStringAsFixed(2);
      _payType = 'hourly';
      _calculateDailyTotal();
    }
  }

  void _calculateDailyTotal() {
    // Calculate daily total based on hours worked and pay type
    final hours = double.tryParse(_hoursWorkedController.text) ?? 0.0;
    final hourlyRate = (_formData['hourlyRate'] as double?) ?? 50.0; // Default rate
    _formData['dailyTotal'] = hours * hourlyRate;
  }

  void _nextStep(Map<String, dynamic> data) {
    setState(() {
      _formData.addAll(data);
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  void _onCreateInvoice() {
    _showInvoiceCreatedDialog();
  }

  void _showInvoiceCreatedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF50C878).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF50C878),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Invoice Created!'),
          ],
        ),
        content: const Text('Your invoice has been generated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToInvoicePreview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF50C878),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'See Invoice',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToInvoicePreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyLogsScreen(
          payPeriodStart: _formData['payPeriodStart'],
          payPeriodEnd: _formData['payPeriodEnd'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentStep;
                final isCompleted = index < _currentStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? emeraldGreen : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Step content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                InvoiceDetailsStep(
                  formData: _formData,
                  onNext: _nextStep,
                ),
                RatesConfigurationStep(
                  formData: _formData,
                  onNext: _nextStep,
                  onPrevious: _prevStep,
                ),
                InvoiceLogStep(
                  formData: _formData,
                  onPrevious: _prevStep,
                  onCreateInvoice: _onCreateInvoice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}