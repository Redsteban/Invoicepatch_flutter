import 'package:flutter/material.dart';
import 'steps/invoice_details_step.dart';
import 'steps/rates_configuration_step.dart';
import 'steps/invoice_log_step.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:invoicepatch_contractor/shared/models/time_entry.dart';

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

  void _onFinalizeLogs(List<DailyLogEntry> logs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Invoice'),
        content: const Text('Are you sure you want to create the invoice with these daily logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Build InvoiceData from _formData and logs
              final invoice = InvoiceData(
                contractorName: _formData['contractorName'] ?? '',
                contractorAddress: _formData['contractorAddress'] ?? '',
                contractorCity: '',
                contractorProvince: '',
                contractorPostal: '',
                contractorPhone: '',
                contractorEmail: '',
                gstNumber: '',
                clientName: _formData['clientName'] ?? '',
                clientAddress: _formData['clientAddress'] ?? '',
                clientCity: '',
                clientProvince: '',
                clientPostal: '',
                clientEmail: '',
                invoiceNumber: _formData['invoiceNumber'] ?? '',
                invoiceDate: DateTime.now().toString().split(' ')[0],
                dueDate: '',
                projectDescription: '',
                lineItems: logs.map((log) => LineItem(
                  id: log.date.toIso8601String(),
                  description: log.description,
                  category: '',
                  quantity: 1,
                  unit: '',
                  rate: 0,
                  amount: (log.kmsRegular * log.kmsRegRate) + (log.kmsTowing * log.kmsTowRate) + log.truckRate + log.otherCharges,
                  location: log.location,
                  worked: log.worked,
                  kmsRegular: log.kmsRegular,
                  kmsTowing: log.kmsTowing,
                  kmsRegRate: log.kmsRegRate,
                  kmsTowRate: log.kmsTowRate,
                  truckRate: log.truckRate,
                  otherCharges: log.otherCharges,
                )).toList(),
                notes: '',
                paymentTerms: '',
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InvoicePreviewScreen(invoice: invoice),
                ),
              );
            },
            child: const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Invoice Creation', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF50C878),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentStep,
          children: [
            InvoiceDetailsStep(
              onNext: _nextStep,
              initialData: _formData,
            ),
            RatesConfigurationStep(
              onNext: _nextStep,
              onBack: _prevStep,
              initialData: _formData,
            ),
            InvoiceLogStep(
              formData: _formData,
              onBack: _prevStep,
              onCreate: _onCreateInvoice,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _currentStep > 0 && _currentStep < 2
          ? Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
              child: ElevatedButton(
                onPressed: _prevStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }
}

class DailyLogsScreen extends StatefulWidget {
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  const DailyLogsScreen({Key? key, required this.payPeriodStart, required this.payPeriodEnd}) : super(key: key);

  @override
  State<DailyLogsScreen> createState() => _DailyLogsScreenState();
}

class _DailyLogsScreenState extends State<DailyLogsScreen> {
  late List<DailyLogEntry> _logs;
  DateTime? _selectedDay;

  // --- Summary Computation ---
  int get _workDaysCount => _logs.where((e) => e.worked).length;
  double get _totalHours => _logs.fold(0, (sum, e) => sum + (e.worked ? e.hours : 0));
  double get _baseEarnings {
    final payType = context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['payType'] ?? 'hourly';
    final rateRaw = context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['rate'] ?? 0;
    final rate = (rateRaw is num) ? rateRaw.toDouble() : 0.0;
    if (payType == 'hourly') {
      return _logs.fold(0, (sum, e) => sum + (e.worked ? e.hours * rate : 0));
    } else {
      return _logs.fold(0, (sum, e) => sum + (e.worked ? rate : 0));
    }
  }
  double get _truckMileageTotal => _logs.fold(0, (sum, e) => sum + (e.worked ? (e.truckRate + (e.kmsRegular * e.kmsRegRate) + (e.kmsTowing * e.kmsTowRate)) : 0));
  double get _subsistenceTotal => _logs.fold(0, (sum, e) => sum + (e.worked ? (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['dailySubsistence'] ?? 0) : 0));
  double get _subtotal => _baseEarnings + _truckMileageTotal;
  double get _gst => _subtotal * 0.05;
  double get _grandTotal => _subtotal + _gst + _subsistenceTotal;

  @override
  void initState() {
    super.initState();
    _logs = List.generate(
      widget.payPeriodEnd.difference(widget.payPeriodStart).inDays,
      (i) => DailyLogEntry(
        date: widget.payPeriodStart.add(Duration(days: i)),
        worked: true,
        location: '',
        description: '',
        kmsRegular: 0,
        kmsTowing: 0,
        kmsRegRate: 0,
        kmsTowRate: 0,
        truckRate: 0,
        otherCharges: 0,
      ),
    );
    _selectedDay = _logs.first.date;
  }

  void _editEntry(DailyLogEntry entry) async {
    final payType = (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['payType'] ?? 'hourly') as String;
    final hoursController = TextEditingController(text: entry.hours.toString());
    final locationController = TextEditingController(text: entry.location);
    final descriptionController = TextEditingController(text: entry.description);
    final ticketController = TextEditingController(text: entry.ticketNumber);
    final rateController = TextEditingController(text: payType == 'hourly' ? entry.kmsRegRate.toString() : entry.kmsTowRate.toString());
    final subsistenceController = TextEditingController(text: entry.truckRate.toString());
    final truckRateController = TextEditingController(text: entry.truckRate.toString());
    final otherChargesController = TextEditingController(text: entry.otherCharges.toString());
    bool worked = entry.worked;

    double _calculateDialogTotal() {
      double total = 0;
      if (payType == 'hourly') {
        final hours = double.tryParse(hoursController.text) ?? 0;
        final rate = double.tryParse(rateController.text) ?? 0;
        total += hours * rate;
      } else if (payType == 'daily') {
        final rate = double.tryParse(rateController.text) ?? 0;
        total += rate;
      }
      final subsistence = double.tryParse(subsistenceController.text) ?? 0;
      final truckRate = double.tryParse(truckRateController.text) ?? 0;
      final otherCharges = double.tryParse(otherChargesController.text) ?? 0;
      total += subsistence + truckRate + otherCharges;
      return total;
    }

    void _updateTotal() {
      setState(() {});
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_calendar, color: Color(0xFF50C878)),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Day',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildEditField(
                      controller: descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      setState: setState,
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                      setState: setState,
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: hoursController,
                      label: 'Hours Worked',
                      icon: Icons.access_time,
                      keyboardType: TextInputType.number,
                      setState: setState,
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: rateController,
                      label: payType == 'hourly' ? 'Hourly Rate' : 'Daily Rate',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      prefix: '\$',
                      setState: setState,
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: subsistenceController,
                      label: 'Subsistence',
                      icon: Icons.restaurant,
                      keyboardType: TextInputType.number,
                      prefix: '\$',
                      setState: setState,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildEditField(
                            controller: truckRateController,
                            label: 'Truck Rate',
                            icon: Icons.local_shipping,
                            keyboardType: TextInputType.number,
                            prefix: '\$',
                            setState: setState,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEditField(
                            controller: otherChargesController,
                            label: 'Other',
                            icon: Icons.add_circle,
                            keyboardType: TextInputType.number,
                            prefix: '\$',
                            setState: setState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF50C878)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text('Worked This Day'),
                        value: worked,
                        onChanged: (value) => setState(() => worked = value),
                        activeColor: const Color(0xFF50C878),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              entry.hours = double.tryParse(hoursController.text) ?? 0;
                              entry.location = locationController.text;
                              entry.description = descriptionController.text;
                              entry.ticketNumber = ticketController.text;
                              entry.kmsRegular = 0; // Not in dialog
                              entry.kmsTowing = 0; // Not in dialog
                              entry.kmsRegRate = payType == 'hourly' ? double.tryParse(rateController.text) ?? 0 : 0;
                              entry.kmsTowRate = payType == 'daily' ? double.tryParse(rateController.text) ?? 0 : 0;
                              entry.truckRate = double.tryParse(truckRateController.text) ?? 0;
                              entry.otherCharges = double.tryParse(otherChargesController.text) ?? 0;
                              entry.worked = worked;
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF50C878),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefix,
    required void Function(void Function()) setState,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: const Color(0xFF50C878)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF50C878), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF50C878).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF50C878), width: 2),
        ),
      ),
    );
  }

  bool _isInPayPeriod(DateTime day) {
    return !day.isBefore(widget.payPeriodStart) && day.isBefore(widget.payPeriodEnd);
  }

  void _onFinalizeLogs(List<DailyLogEntry> logs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Invoice'),
        content: const Text('Are you sure you want to create the invoice with these daily logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Build InvoiceData from logs and navigate to InvoicePreviewScreen
              // You may need to pass additional data from parent if needed
            },
            child: const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Daily Logs',
          style: TextStyle(
            color: emeraldGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- Enhanced Invoice Summary ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildInvoiceSummary(),
          ),
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: widget.payPeriodStart.subtract(const Duration(days: 7)),
              lastDay: widget.payPeriodEnd.add(const Duration(days: 7)),
              focusedDay: _selectedDay!,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => _selectedDay != null && day.year == _selectedDay!.year && day.month == _selectedDay!.month && day.day == _selectedDay!.day,
              onDaySelected: (selected, _) {
                if (_isInPayPeriod(selected)) {
                  setState(() => _selectedDay = selected);
                  final entry = _logs.firstWhere((e) => e.date.year == selected.year && e.date.month == selected.month && e.date.day == selected.day);
                  _editEntry(entry);
                }
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final inPeriod = _isInPayPeriod(day);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: inPeriod ? emeraldGreen.withOpacity(0.85) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: inPeriod ? Colors.white : Colors.grey[600],
                          fontWeight: inPeriod ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final inPeriod = _isInPayPeriod(day);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: inPeriod ? emeraldGreen : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
              enabledDayPredicate: _isInPayPeriod,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daily Entry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, idx) {
                  final entry = _logs[idx];
                  final dayNumber = idx + 1;
                  final clientName = (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['clientName'] ?? '') as String;
                  final payType = (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['payType'] ?? 'hourly') as String;
                  final rateRaw = context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['rate'] ?? 0;
                  final rate = (rateRaw is num) ? rateRaw.toDouble() : 0.0;
                  final hours = entry.hours;
                  double amount = 0;
                  if (payType == 'hourly') {
                    amount = (hours * rate) + entry.truckRate + (entry.kmsRegular * entry.kmsRegRate) + (entry.kmsTowing * entry.kmsTowRate) + entry.otherCharges;
                  } else {
                    amount = rate + entry.truckRate + (entry.kmsRegular * entry.kmsRegRate) + (entry.kmsTowing * entry.kmsTowRate) + entry.otherCharges;
                  }
                  return Card(
                    elevation: 0,
                    color: const Color(0xFFF9FBFC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF232B36))),
                                    const SizedBox(width: 10),
                                    Text('• Day $dayNumber', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 15)),
                                    const SizedBox(width: 8),
                                    Text('• ${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 15)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text('Location: ${entry.location.isNotEmpty ? entry.location : '-'}', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 14)),
                                    const SizedBox(width: 10),
                                    Text('Ticket #: ${entry.ticketNumber.isNotEmpty ? entry.ticketNumber : '-'}', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Hours: $hours, Rate: $rate, Truck: ${entry.truckRate}, Kms: ${entry.kmsRegular}, Other: ${entry.otherCharges}', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                              ],
                            ),
                          ),
                          // Right side: Amount, Edit, Worked
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF232B36))),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF232B36)),
                                    onPressed: () => _editEntry(entry),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        entry.worked = !entry.worked;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: entry.worked ? const Color(0xFFE6F9EF) : const Color(0xFFF3F4F6),
                                        border: Border.all(color: entry.worked ? emeraldGreen : const Color(0xFFB0B7C3), width: 1.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        entry.worked ? 'Worked' : 'Day Off',
                                        style: TextStyle(
                                          color: entry.worked ? emeraldGreen : const Color(0xFFB0B7C3),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final invoice = InvoiceData(
                    contractorName: (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['contractorName'] ?? '') as String,
                    contractorAddress: (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['contractorAddress'] ?? '') as String,
                    contractorCity: '',
                    contractorProvince: '',
                    contractorPostal: '',
                    contractorPhone: '',
                    contractorEmail: '',
                    gstNumber: '',
                    clientName: (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['clientName'] ?? '') as String,
                    clientAddress: (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['clientAddress'] ?? '') as String,
                    clientCity: '',
                    clientProvince: '',
                    clientPostal: '',
                    clientEmail: '',
                    invoiceNumber: (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['invoiceNumber'] ?? '') as String,
                    invoiceDate: DateTime.now().toString().split(' ')[0],
                    dueDate: '',
                    projectDescription: '',
                    lineItems: _logs.map((log) => LineItem(
                      id: log.date.toIso8601String(),
                      description: log.description,
                      category: '',
                      quantity: 1,
                      unit: '',
                      rate: 0,
                      amount: (log.kmsRegular * log.kmsRegRate) + (log.kmsTowing * log.kmsTowRate) + log.truckRate + log.otherCharges,
                      location: log.location,
                      worked: log.worked,
                      kmsRegular: log.kmsRegular,
                      kmsTowing: log.kmsTowing,
                      kmsRegRate: log.kmsRegRate,
                      kmsTowRate: log.kmsTowRate,
                      truckRate: log.truckRate,
                      otherCharges: log.otherCharges,
                    )).toList(),
                    notes: '',
                    paymentTerms: '',
                  );
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: SizedBox(
                        width: double.infinity,
                        child: InvoicePreviewScreen(invoice: invoice),
                      ),
                    ),
                  );
                },
                child: const Text('Invoice Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Enhanced Invoice Summary Widget ---
  Widget _buildInvoiceSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            const Color(0xFF50C878).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF50C878).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '14-Day Period',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Work Days', '$_workDaysCount days', Icons.calendar_today),
          _buildSummaryRow('Total Hours', '${_totalHours.toStringAsFixed(1)} hrs', Icons.access_time),
          _buildSummaryRow('Base Earnings', '\$${_baseEarnings.toStringAsFixed(2)}', Icons.attach_money),
          _buildSummaryRow('Truck & Mileage', '\$${_truckMileageTotal.toStringAsFixed(2)}', Icons.local_shipping),
          _buildSummaryRow('Subsistence', '\$${_subsistenceTotal.toStringAsFixed(2)}', Icons.restaurant),
          const Divider(color: Colors.white30, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                '\$${_subtotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST (5%)',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                '\$${_gst.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyLogEntry {
  final DateTime date;
  bool worked;
  String location;
  String description;
  String ticketNumber;
  double hours;
  double kmsRegular;
  double kmsTowing;
  double kmsRegRate;
  double kmsTowRate;
  double truckRate;
  double otherCharges;
  DailyLogEntry({
    required this.date,
    this.worked = true,
    this.location = '',
    this.description = '',
    this.ticketNumber = '',
    this.hours = 0,
    this.kmsRegular = 0,
    this.kmsTowing = 0,
    this.kmsRegRate = 0,
    this.kmsTowRate = 0,
    this.truckRate = 0,
    this.otherCharges = 0,
  });
  DailyLogEntry copyWith({
    DateTime? date,
    bool? worked,
    String? location,
    String? description,
    String? ticketNumber,
    double? hours,
    double? kmsRegular,
    double? kmsTowing,
    double? kmsRegRate,
    double? kmsTowRate,
    double? truckRate,
    double? otherCharges,
  }) => DailyLogEntry(
    date: date ?? this.date,
    worked: worked ?? this.worked,
    location: location ?? this.location,
    description: description ?? this.description,
    ticketNumber: ticketNumber ?? this.ticketNumber,
    hours: hours ?? this.hours,
    kmsRegular: kmsRegular ?? this.kmsRegular,
    kmsTowing: kmsTowing ?? this.kmsTowing,
    kmsRegRate: kmsRegRate ?? this.kmsRegRate,
    kmsTowRate: kmsTowRate ?? this.kmsTowRate,
    truckRate: truckRate ?? this.truckRate,
    otherCharges: otherCharges ?? this.otherCharges,
  );
}

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceData invoice;
  const InvoicePreviewScreen({Key? key, required this.invoice}) : super(key: key);

  double get subtotal => invoice.lineItems.fold(0, (sum, item) => sum + item.amount);
  double get gst => subtotal * 0.05;
  double get subsistenceTotal => invoice.lineItems.fold(0, (sum, item) => sum + (item.category == 'subsistence' ? item.amount : 0));
  double get grandTotal => subtotal + gst + subsistenceTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Invoice Preview', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice #${invoice.invoiceNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Text('Date: ${invoice.invoiceDate}', style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 8),
                    Text('Contractor: ${invoice.contractorName}', style: const TextStyle(color: Colors.black)),
                    Text('Client: ${invoice.clientName}', style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Work Summary', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Day', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Date', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Description', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Location', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Ticket #', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Truck \$', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('KMS driven', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('KMS rate \$', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Other \$', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Subtotal \$', style: TextStyle(color: Colors.black))),
                ],
                rows: invoice.lineItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text((i + 1).toString(), style: const TextStyle(color: Colors.black))),
                    DataCell(Text(item.id.split('T')[0], style: const TextStyle(color: Colors.black))),
                    DataCell(Text(item.description, style: const TextStyle(color: Colors.black))),
                    DataCell(Text(item.location ?? '', style: const TextStyle(color: Colors.black))),
                    DataCell(Text(item.unit ?? '', style: const TextStyle(color: Colors.black))),
                    DataCell(Text('\$${item.truckRate.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black))),
                    DataCell(Text(item.kmsRegular.toStringAsFixed(1), style: const TextStyle(color: Colors.black))),
                    DataCell(Text('\$${item.kmsRegRate.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black))),
                    DataCell(Text('\$${item.otherCharges.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black))),
                    DataCell(Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black))),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    const Color(0xFF50C878).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF50C878).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '14-Day Period',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', Icons.attach_money),
                  _buildSummaryRow('GST (5%)', '\$${gst.toStringAsFixed(2)}', Icons.percent),
                  _buildSummaryRow('Subsistence (Tax-Free)', '\$${subsistenceTotal.toStringAsFixed(2)}', Icons.restaurant),
                  const Divider(color: Colors.white30, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Notes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Text(invoice.notes!, style: const TextStyle(color: Colors.black)),
            ],
            if (invoice.paymentTerms != null && invoice.paymentTerms!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Payment Terms', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Text(invoice.paymentTerms!, style: const TextStyle(color: Colors.black)),
            ],
            const SizedBox(height: 32),
            _buildApprovalSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _showApprovalDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF50C878),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Approve Invoice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.task_alt,
                color: Color(0xFF50C878),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Invoice Approved!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What would you like to do with your invoice?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.email,
                label: 'Email Invoice',
                onPressed: () {
                  Navigator.of(context).pop();
                  _emailInvoice(context);
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.download,
                label: 'Download PDF',
                onPressed: () {
                  Navigator.of(context).pop();
                  _downloadPDF(context);
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.done_all,
                label: 'Email & Download',
                onPressed: () {
                  Navigator.of(context).pop();
                  _emailInvoice(context);
                  _downloadPDF(context);
                },
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Return to dashboard after action
      Navigator.of(context).popUntil((route) => route.isFirst);
      // Optionally, push dashboard route if using named routes
      // context.router.replaceAll([const DashboardRoute()]);
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF50C878)),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF50C878),
          side: const BorderSide(color: Color(0xFF50C878)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _emailInvoice(BuildContext context) {
    // TODO: Implement email logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice emailed!'), backgroundColor: Color(0xFF50C878)),
    );
  }

  void _downloadPDF(BuildContext context) {
    // TODO: Implement download logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF downloaded!'), backgroundColor: Color(0xFF50C878)),
    );
  }
}

class InvoiceData {
  final String contractorName;
  final String contractorAddress;
  final String contractorCity;
  final String contractorProvince;
  final String contractorPostal;
  final String contractorPhone;
  final String contractorEmail;
  final String? gstNumber;
  final String clientName;
  final String clientAddress;
  final String clientCity;
  final String clientProvince;
  final String clientPostal;
  final String clientEmail;
  final String invoiceNumber;
  final String invoiceDate;
  final String dueDate;
  final String? projectDescription;
  final List<LineItem> lineItems;
  final String? notes;
  final String? paymentTerms;
  InvoiceData({
    required this.contractorName,
    required this.contractorAddress,
    required this.contractorCity,
    required this.contractorProvince,
    required this.contractorPostal,
    required this.contractorPhone,
    required this.contractorEmail,
    this.gstNumber,
    required this.clientName,
    required this.clientAddress,
    required this.clientCity,
    required this.clientProvince,
    required this.clientPostal,
    required this.clientEmail,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    this.projectDescription,
    required this.lineItems,
    this.notes,
    this.paymentTerms,
  });
}

class LineItem {
  final String id;
  final String description;
  final String? category;
  final int quantity;
  final String? unit;
  final double rate;
  final double amount;
  final String location;
  final bool worked;
  final double kmsRegular;
  final double kmsTowing;
  final double kmsRegRate;
  final double kmsTowRate;
  final double truckRate;
  final double otherCharges;
  LineItem({
    required this.id,
    required this.description,
    this.category,
    required this.quantity,
    this.unit,
    required this.rate,
    required this.amount,
    this.location = '',
    this.worked = true,
    this.kmsRegular = 0,
    this.kmsTowing = 0,
    this.kmsRegRate = 0,
    this.kmsTowRate = 0,
    this.truckRate = 0,
    this.otherCharges = 0,
  });
} 