import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/models/daily_log_entry.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/models/invoice_data.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_preview_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';

const emeraldGreen = Color(0xFF50C878);

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
      body: SafeArea(
        child: Column(
          children: [
            // Green Invoice Summary for the summary section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildInvoiceSummary(),
            ),
            Expanded(
              child: Container(
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
                    selectedBuilder: (context, day, _) {
                      final inPeriod = _isInPayPeriod(day);
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: inPeriod ? emeraldGreen : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Daily entries list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final entry = _logs[index];
                  final payType = (context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['payType'] ?? 'hourly') as String;
                  final rateRaw = context.findAncestorStateOfType<_InvoiceCreationScreenState>()?._formData['rate'] ?? 0;
                  final rate = (rateRaw is num) ? rateRaw.toDouble() : 0.0;
                  
                  double amount = 0;
                  if (entry.worked) {
                    if (payType == 'hourly') {
                      amount = entry.hours * rate;
                    } else {
                      amount = rate;
                    }
                    amount += entry.truckRate + (entry.kmsRegular * entry.kmsRegRate) + (entry.kmsTowing * entry.kmsTowRate) + entry.otherCharges;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: emeraldGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.date.day}',
                              style: const TextStyle(
                                color: emeraldGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.description.isEmpty ? 'No description' : entry.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.location.isEmpty ? 'No location' : entry.location,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${entry.hours.toStringAsFixed(1)} hours',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
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
                  );
                },
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