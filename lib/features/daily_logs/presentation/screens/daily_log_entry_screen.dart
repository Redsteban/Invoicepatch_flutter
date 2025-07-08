import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_event.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_state.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_event.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_state.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/date_picker_field.dart';

const emeraldGreen = Color(0xFF50C878);

class DailyLogEntryScreen extends StatefulWidget {
  final DailyLog? existingLog; // For editing existing logs
  final DateTime? initialDate;

  const DailyLogEntryScreen({
    Key? key,
    this.existingLog,
    this.initialDate,
  }) : super(key: key);

  @override
  State<DailyLogEntryScreen> createState() => _DailyLogEntryScreenState();
}

class _DailyLogEntryScreenState extends State<DailyLogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _regularHoursController = TextEditingController();
  final _overtimeHoursController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  final _dayRateController = TextEditingController();
  // Revenue controllers
  final _dailySubsistenceController = TextEditingController();
  final _truckRateController = TextEditingController();
  final _kmsDrivenController = TextEditingController();
  final _kmsRateController = TextEditingController();
  final _otherChargesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  BillingMethod _billingMethod = BillingMethod.hourly;
  bool _isFullDay = false;
  LogStatus _status = LogStatus.draft;
  Map<ExpenseCategory, double> _expenses = {};
  List<Client> _availableClients = [];
  String _selectedClientId = '';
  bool _worked = true;

  @override
  void initState() {
    super.initState();
    // Load clients when screen initializes
    context.read<ClientBloc>().add(const ClientLoadRequested());
    // If editing existing log, populate fields
    if (widget.existingLog != null) {
      _populateFieldsFromExisting();
      _worked = widget.existingLog!.worked;
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  void _populateFieldsFromExisting() {
    final log = widget.existingLog!;
    _selectedDate = log.date;
    _billingMethod = log.billingMethod;
    _isFullDay = log.isFullDay;
    _status = log.status;
    _descriptionController.text = log.description ?? '';
    _regularHoursController.text = log.regularHours?.toString() ?? '';
    _overtimeHoursController.text = log.overtimeHours?.toString() ?? '';
    _hourlyRateController.text = log.hourlyRate?.toString() ?? '';
    _overtimeRateController.text = log.overtimeRate?.toString() ?? '';
    _dayRateController.text = log.dayRate?.toString() ?? '';
    _expenses = Map<ExpenseCategory, double>.from(log.expenses);
    _selectedClientId = log.clientId;
    // Revenue fields
    _dailySubsistenceController.text = log.dailySubsistence?.toString() ?? '';
    _truckRateController.text = log.truckRate?.toString() ?? '';
    _kmsDrivenController.text = log.kmsDriven?.toString() ?? '';
    _kmsRateController.text = log.kmsRate?.toString() ?? '';
    _otherChargesController.text = log.otherCharges?.toString() ?? '';
  }

  void _loadClientRates(String clientId) {
    final client = _availableClients.firstWhere(
      (c) => c.id == clientId,
      orElse: () => _availableClients.first, // Fallback to first client
    );

    // Auto-populate rates from client preferences
    if (client.billingPreferences.defaultHourlyRate != null) {
      _hourlyRateController.text = client.billingPreferences.defaultHourlyRate.toString();
    }
    if (client.billingPreferences.defaultDayRate != null) {
      _dayRateController.text = client.billingPreferences.defaultDayRate.toString();
    }
    if (client.billingPreferences.defaultOvertimeRate != null) {
      _overtimeRateController.text = client.billingPreferences.defaultOvertimeRate.toString();
    }

    // Set billing method from client preferences
    setState(() {
      _billingMethod = client.billingPreferences.primaryMethod;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _regularHoursController.dispose();
    _overtimeHoursController.dispose();
    _hourlyRateController.dispose();
    _overtimeRateController.dispose();
    _dayRateController.dispose();
    // Revenue controllers
    _dailySubsistenceController.dispose();
    _truckRateController.dispose();
    _kmsDrivenController.dispose();
    _kmsRateController.dispose();
    _otherChargesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final log = DailyLog(
        id: widget.existingLog?.id ?? UniqueKey().toString(),
        clientId: _selectedClientId,
        date: _selectedDate,
        billingMethod: _billingMethod,
        regularHours: _billingMethod != BillingMethod.dayRate ? double.tryParse(_regularHoursController.text) : null,
        overtimeHours: double.tryParse(_overtimeHoursController.text),
        hourlyRate: _billingMethod != BillingMethod.dayRate ? double.tryParse(_hourlyRateController.text) : null,
        overtimeRate: double.tryParse(_overtimeRateController.text),
        dayRate: _billingMethod != BillingMethod.hourly ? double.tryParse(_dayRateController.text) : null,
        isFullDay: _isFullDay,
        expenses: _expenses,
        description: _descriptionController.text,
        status: _status,
        worked: _worked,
        createdAt: widget.existingLog?.createdAt ?? DateTime.now(),
        approvedAt: widget.existingLog?.approvedAt,
        // Revenue fields
        dailySubsistence: double.tryParse(_dailySubsistenceController.text),
        truckRate: double.tryParse(_truckRateController.text),
        kmsDriven: double.tryParse(_kmsDrivenController.text),
        kmsRate: double.tryParse(_kmsRateController.text),
        otherCharges: double.tryParse(_otherChargesController.text),
      );
      if (widget.existingLog == null) {
        context.read<DailyLogBloc>().add(DailyLogCreateRequested(dailyLog: log));
      } else {
        context.read<DailyLogBloc>().add(DailyLogUpdateRequested(dailyLog: log));
      }
    }
  }


  Widget _buildExpenseFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ExpenseCategory.values.map((category) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextFormField(
            initialValue: _expenses[category]?.toString() ?? '',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: category.toString().split('.').last.capitalize(),
              prefixIcon: const Icon(Icons.attach_money),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                final amount = double.tryParse(value);
                if (amount != null && amount > 0) {
                  _expenses[category] = amount;
                } else {
                  _expenses.remove(category);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  double _calculateDailyTotal() {
    double total = 0;
    // Base rate calculation
    if (_billingMethod == BillingMethod.hourly) {
      final hours = double.tryParse(_regularHoursController.text) ?? 0;
      final rate = double.tryParse(_hourlyRateController.text) ?? 0;
      total += hours * rate;
    } else if (_billingMethod == BillingMethod.dayRate) {
      final rate = double.tryParse(_dayRateController.text) ?? 0;
      total += rate;
    }
    // Add additional charges (default to 0 if empty)
    final subsistence = double.tryParse(_dailySubsistenceController.text) ?? 0;
    final truckRate = double.tryParse(_truckRateController.text) ?? 0;
    final kms = double.tryParse(_kmsDrivenController.text) ?? 0;
    final kmsRate = double.tryParse(_kmsRateController.text) ?? 0;
    final otherCharges = double.tryParse(_otherChargesController.text) ?? 0;
    total += subsistence + truckRate + (kms * kmsRate) + otherCharges;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLog == null ? 'New Daily Log' : 'Edit Daily Log'),
        backgroundColor: emeraldGreen,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<DailyLogBloc, DailyLogState>(
        listener: (context, state) {
          if (state is DailyLogSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          } else if (state is DailyLogFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Picker
                SizedBox(
                  width: 400,
                  child: DatePickerField(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    selectedDate: _selectedDate,
                    onDateSelected: (picked) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _worked,
                  onChanged: (val) {
                    setState(() => _worked = val);
                  },
                  title: const Text('Worked (On/Off Day)', style: TextStyle(fontWeight: FontWeight.bold)),
                  activeColor: emeraldGreen,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey,
                ),
                const SizedBox(height: 16),
                // --- Revenue Section ---
                const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: emeraldGreen)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dailySubsistenceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Daily Subsistence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _truckRateController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Truck Rate',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kmsDrivenController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kms Driven per Day',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kmsRateController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kms Rate',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.route),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherChargesController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Other Charges',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_circle_outline),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // --- Daily Total Display ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daily Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '\$${_calculateDailyTotal().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: emeraldGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Client Dropdown
                BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, clientState) {
                    if (clientState is ClientLoaded) {
                      _availableClients = clientState.clients;
                      if (_availableClients.isEmpty) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.orange[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No clients found. Please add a client first.',
                                      style: TextStyle(color: Colors.orange[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please use the Clients screen to add clients first'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Client'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }
                      // Ensure selected client is valid
                      if (_selectedClientId.isNotEmpty &&
                          !_availableClients.any((c) => c.id == _selectedClientId)) {
                        _selectedClientId = _availableClients.first.id;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _loadClientRates(_selectedClientId);
                        });
                      } else if (_selectedClientId.isEmpty && _availableClients.isNotEmpty) {
                        _selectedClientId = _availableClients.first.id;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _loadClientRates(_selectedClientId);
                        });
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedClientId.isNotEmpty ? _selectedClientId : null,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: _availableClients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  client.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  client.company,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClientId = value!;
                          });
                          _loadClientRates(value!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a client';
                          }
                          return null;
                        },
                      );
                    } else if (clientState is ClientLoading) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading clients...'),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Failed to load clients. Please try again.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ClientBloc>().add(const ClientLoadRequested());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Billing Method
                DropdownButtonFormField<BillingMethod>(
                  value: _billingMethod,
                  items: BillingMethod.values
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method.name.capitalize()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _billingMethod = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Billing Method',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Regular Hours
                if (_billingMethod != BillingMethod.dayRate)
                  TextFormField(
                    controller: _regularHoursController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Regular Hours',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_billingMethod != BillingMethod.dayRate && (value == null || value.isEmpty)) {
                        return 'Enter regular hours';
                      }
                      return null;
                    },
                  ),
                if (_billingMethod != BillingMethod.dayRate)
                  const SizedBox(height: 16),
                // Overtime Hours
                TextFormField(
                  controller: _overtimeHoursController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Overtime Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Hourly Rate
                if (_billingMethod != BillingMethod.dayRate)
                  TextFormField(
                    controller: _hourlyRateController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Hourly Rate (CAD)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_billingMethod != BillingMethod.dayRate && (value == null || value.isEmpty)) {
                        return 'Enter hourly rate';
                      }
                      return null;
                    },
                  ),
                if (_billingMethod != BillingMethod.dayRate)
                  const SizedBox(height: 16),
                // Overtime Rate
                TextFormField(
                  controller: _overtimeRateController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Overtime Rate (CAD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Day Rate
                if (_billingMethod != BillingMethod.hourly)
                  TextFormField(
                    controller: _dayRateController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Day Rate (CAD)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_billingMethod != BillingMethod.hourly && (value == null || value.isEmpty)) {
                        return 'Enter day rate';
                      }
                      return null;
                    },
                  ),
                if (_billingMethod != BillingMethod.hourly)
                  const SizedBox(height: 16),
                // Is Full Day
                if (_billingMethod != BillingMethod.hourly)
                  CheckboxListTile(
                    value: _isFullDay,
                    onChanged: (value) {
                      setState(() {
                        _isFullDay = value ?? false;
                      });
                    },
                    title: const Text('Full Day'),
                  ),
                // Expenses
                const SizedBox(height: 16),
                const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildExpenseFields(),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Status
                DropdownButtonFormField<LogStatus>(
                  value: _status,
                  items: LogStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name.capitalize()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emeraldGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(widget.existingLog == null ? 'Save Log' : 'Update Log'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
} 