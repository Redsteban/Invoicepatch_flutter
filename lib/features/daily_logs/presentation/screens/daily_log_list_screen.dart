import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_event.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_state.dart';
import 'package:invoicepatch_contractor/features/daily_logs/presentation/screens/daily_log_entry_screen.dart';
import 'package:invoicepatch_contractor/shared/models/daily_log.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_state.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_event.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:auto_route/auto_route.dart';
import 'package:invoicepatch_contractor/core/routing/app_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';

const emeraldGreen = Color(0xFF50C878);

class DailyLogListScreen extends StatefulWidget {
  const DailyLogListScreen({Key? key}) : super(key: key);

  @override
  State<DailyLogListScreen> createState() => _DailyLogListScreenState();
}

class _DailyLogListScreenState extends State<DailyLogListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  LogStatus? _filterStatus;
  String? _filterClientId;
  DateTime? _focusedDay;
  DateTime? _selectedDay;

  List<Client> _availableClients = [];
  Map<String, String> _clientNameMap = {};

  @override
  void initState() {
    super.initState();
    _filterClientId = 'all';
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    // Load both logs and clients when screen initializes
    context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
    context.read<ClientBloc>().add(const ClientLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final payPeriodStart = today.subtract(Duration(days: today.weekday - 1));
    final payPeriodDays = List.generate(14, (i) => payPeriodStart.add(Duration(days: i)));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Logs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewLog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar
                TableCalendar(
                  firstDay: payPeriodStart.subtract(const Duration(days: 7)),
                  lastDay: payPeriodStart.add(const Duration(days: 20)),
                  focusedDay: _selectedDay ?? today,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => _selectedDay != null && day.year == _selectedDay!.year && day.month == _selectedDay!.month && day.day == _selectedDay!.day,
                  onDaySelected: (selected, _) {
                    if (payPeriodDays.any((d) => d.year == selected.year && d.month == selected.month && d.day == selected.day)) {
                      setState(() => _selectedDay = selected);
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final idx = payPeriodDays.indexWhere((d) => d.year == day.year && d.month == day.month && d.day == day.day);
                      final inPeriod = idx != -1;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: inPeriod ? Color(0xFF00B96B) : Colors.grey[200],
                          shape: BoxShape.circle,
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
                      final idx = payPeriodDays.indexWhere((d) => d.year == day.year && d.month == day.month && d.day == day.day);
                      final inPeriod = idx != -1;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: inPeriod ? Color(0xFF00B96B) : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final idx = payPeriodDays.indexWhere((d) => d.year == day.year && d.month == day.month && d.day == day.day);
                      final inPeriod = idx != -1;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: inPeriod ? Color(0xFF003366) : Colors.grey[600],
                          shape: BoxShape.circle,
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
                  enabledDayPredicate: (day) => payPeriodDays.any((d) => d.year == day.year && d.month == day.month && d.day == day.day),
                ),
                const SizedBox(height: 8),
                if (_hasActiveFilters()) _buildFilterSummary(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daily Entry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<DailyLogBloc, DailyLogState>(
                  builder: (context, state) {
                    if (state is DailyLogLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DailyLogLoaded) {
                      final today = DateTime.now();
                      final payPeriodStart = today.subtract(Duration(days: today.weekday - 1));
                      final days = List.generate(14, (i) => payPeriodStart.add(Duration(days: i)));
                      final logsByDate = {for (var log in state.logs) _dateKey(log.date): log};
                      return Column(
                        children: [
                          for (int index = 0; index < days.length; index++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: logsByDate[_dateKey(days[index])] != null
                                ? _buildRolodexLogCard(logsByDate[_dateKey(days[index])]!)
                                : _buildAddLogCard(days[index]),
                            ),
                        ],
                      );
                    } else if (state is DailyLogFailure) {
                      return _buildErrorState(state.message);
                    }
                    return _buildEmptyState();
                  },
                ),
                const SizedBox(height: 24),
                _buildInvoiceSummary(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLog,
        backgroundColor: emeraldGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFEBFAF2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFB2E5D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: emeraldGreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterSummaryText(),
              style: const TextStyle(color: emeraldGreen),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildRolodexLogCard(DailyLog log) {
    final dayNumber = log.date.difference(DateTime(log.date.year, log.date.month, 1)).inDays + 1;
    final truck = log.expenses[ExpenseCategory.equipment] ?? 0;
    final kms = log.expenses[ExpenseCategory.travel] ?? 0;
    final other = log.expenses.entries
        .where((e) => e.key != ExpenseCategory.equipment && e.key != ExpenseCategory.travel)
        .fold(0.0, (sum, e) => sum + e.value);
    return Card(
      elevation: 0,
      color: const Color(0xFFF9FBFC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getClientName(log.clientId),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF232B36)),
                      ),
                      const SizedBox(width: 12),
                      Text('• Day $dayNumber', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 16)),
                      const SizedBox(width: 8),
                      Text('• ${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Location: ${log.description?.isNotEmpty == true ? log.description : '-'} | Ticket #: -', style: const TextStyle(color: Color(0xFF7B8794), fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    'Hours: ${log.regularHours ?? 0}, Rate: 4${log.hourlyRate ?? 0}, Truck: 4$truck, Kms: 4$kms, Other: 4$other',
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  ),
                ],
              ),
            ),
            // Right side: Amount, Edit, Worked
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '4${log.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF232B36)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _editLog(log),
                      child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF232B36))),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        context.read<DailyLogBloc>().add(
                          DailyLogUpdateRequested(
                            dailyLog: log.copyWith(worked: !log.worked),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: log.worked ? const Color(0xFFE6F9EF) : const Color(0xFFF3F4F6),
                          border: Border.all(color: log.worked ? const Color(0xFF00B96B) : const Color(0xFFB0B7C3), width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          log.worked ? 'Worked' : 'Day Off',
                          style: TextStyle(
                            color: log.worked ? const Color(0xFF00B96B) : const Color(0xFF7B8794),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
  }

  Widget _buildStatusChip(LogStatus status) {
    Color color;
    String label;

    switch (status) {
      case LogStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
      case LogStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case LogStatus.approved:
        color = emeraldGreen;
        label = 'Approved';
        break;
      case LogStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emeraldGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: emeraldGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: emeraldGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Daily Logs Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your work by adding your first daily log.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewLog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBillingMethodLabel(DailyLog log) {
    switch (log.billingMethod) {
      case BillingMethod.hourly:
        final total = (log.regularHours ?? 0) + (log.overtimeHours ?? 0);
        return '${total.toStringAsFixed(1)}h';
      case BillingMethod.dayRate:
        return log.isFullDay ? 'Full Day' : 'Partial Day';
      case BillingMethod.mixed:
        return 'Day + ${(log.overtimeHours ?? 0).toStringAsFixed(1)}h OT';
    }
  }

  String _getClientName(String clientId) {
    if (_clientNameMap.containsKey(clientId)) {
      return _clientNameMap[clientId]!;
    }
    // Fallback: try to find in available clients
    final client = _availableClients.firstWhere(
      (c) => c.id == clientId,
      orElse: () => Client(
        id: '',
        name: 'Unknown Client',
        company: 'Unknown Client',
        email: '',
        address: Address(street: '', city: '', province: '', postalCode: '', country: ''),
        billingPreferences: BillingPreferences(primaryMethod: BillingMethod.hourly),
        rateHistory: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return client.company;
  }

  bool _hasActiveFilters() {
    return _startDate != null || 
           _endDate != null || 
           _filterStatus != null || 
           (_filterClientId != null && _filterClientId != 'all');
  }

  String _getFilterSummaryText() {
    List<String> filters = [];
    
    if (_startDate != null && _endDate != null) {
      filters.add('${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}');
    }
    
    if (_filterStatus != null) {
      filters.add('Status: ${_filterStatus.toString().split('.').last}');
    }
    
    if (_filterClientId != null && _filterClientId != 'all') {
      filters.add('Client: ${_getClientName(_filterClientId!)}');
    }
    
    return 'Filtered by: ${filters.join(', ')}';
  }

  void _addNewLog() {
    context.router.push(DailyLogEntryRoute(existingLog: null));
  }

  void _editLog(DailyLog log) {
    context.router.push(DailyLogEntryRoute(existingLog: log));
  }

  void _deleteLog(DailyLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this daily log? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DailyLogBloc>().add(DailyLogDeleteRequested(logId: log.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changeStatus(DailyLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LogStatus.values.map((status) {
            return RadioListTile<LogStatus>(
              title: Text(status.toString().split('.').last.toUpperCase()),
              value: status,
              groupValue: log.status,
              onChanged: (value) {
                Navigator.of(context).pop();
                if (value != null && value != log.status) {
                  context.read<DailyLogBloc>().add(
                    DailyLogStatusUpdateRequested(
                      logId: log.id,
                      newStatus: value,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        startDate: _startDate,
        endDate: _endDate,
        filterStatus: _filterStatus,
        filterClientId: _filterClientId,
        clients: _availableClients,
        onFiltersApplied: (startDate, endDate, status, clientId) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _filterStatus = status;
            _filterClientId = clientId;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filterStatus = null;
      _filterClientId = 'all';
    });
    context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
  }

  void _applyFilters() {
    if (_startDate != null && _endDate != null) {
      context.read<DailyLogBloc>().add(
        DailyLogLoadRequested.range(
          startDate: _startDate!,
          endDate: _endDate!,
          clientId: _filterClientId != 'all' ? _filterClientId : null,
        ),
      );
    } else {
      context.read<DailyLogBloc>().add(const DailyLogLoadRequested());
    }
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  Widget _buildAddLogCard(DateTime day) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _addNewLogForDay(day),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 48, color: emeraldGreen),
                const SizedBox(height: 16),
                Text(
                  'Add Log for\n${day.month}/${day.day}/${day.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNewLogForDay(DateTime day) {
    // Implement navigation to add log for specific day
    context.router.push(DailyLogEntryRoute(existingLog: null, initialDate: day));
  }

  Color _emeraldGradient(int index, int total) {
    // Returns a shade of emerald green from light to dark
    final shades = [
      Color(0xFFB2F5D0), // lightest
      Color(0xFF7FE6B2),
      Color(0xFF50C878), // base
      Color(0xFF2E8B57), // darker
      Color(0xFF206040), // darkest
    ];
    if (total <= 1) return shades[2];
    final pos = (index * (shades.length - 1) / (total - 1)).round();
    return shades[pos];
  }

  Widget _buildInvoiceSummary() {
    return Container();
  }
}

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final LogStatus? filterStatus;
  final String? filterClientId;
  final List<Client> clients;
  final Function(DateTime?, DateTime?, LogStatus?, String?) onFiltersApplied;

  const _FilterDialog({
    required this.startDate,
    required this.endDate,
    required this.filterStatus,
    required this.filterClientId,
    required this.clients,
    required this.onFiltersApplied,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  LogStatus? _filterStatus;
  String? _filterClientId;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _filterStatus = widget.filterStatus;
    _filterClientId = widget.filterClientId ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Logs'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null 
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null 
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<LogStatus?> (
              value: _filterStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...LogStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Client Filter
            const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _filterClientId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Clients')),
                ...widget.clients.map((client) {
                  return DropdownMenuItem(
                    value: client.id,
                    child: Text(client.company),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _filterClientId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _filterStatus = null;
              _filterClientId = 'all';
            });
          },
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFiltersApplied(_startDate, _endDate, _filterStatus, _filterClientId);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }
} 