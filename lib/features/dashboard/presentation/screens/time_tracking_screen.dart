import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart'; // For AnimatedGradientButton
import 'package:lucide_icons/lucide_icons.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';
import 'package:invoicepatch_contractor/shared/models/time_entry.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({Key? key}) : super(key: key);
  
  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;

  // Storage for time entries
  List<TimeEntry> _timeEntries = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Time Tracking'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF50C878),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Clock Display
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRunning ? const Color(0xFF50C878) : Colors.grey[300]!,
                        width: 4,
                      ),
                    ),
                  ),
                  // Time display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(_elapsedTime),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (_startTime != null)
                        Text(
                          'Started at ${DateFormat('h:mm a').format(_startTime!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Start/Stop Button
            AnimatedGradientButton(
              onPressed: _toggleTimer,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isRunning ? 'STOP' : 'START',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Quick Actions
            if (!_isRunning && _elapsedTime > Duration.zero)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _saveToLog,
                    icon: const Icon(Icons.save),
                    label: const Text('Save to Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF50C878),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            // Recent Time Entries
            _buildRecentEntries(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
        _isRunning = false;
      } else {
        _startTime = DateTime.now();
        _isRunning = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedTime = DateTime.now().difference(_startTime!);
          });
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _resetTimer() {
    setState(() {
      _elapsedTime = Duration.zero;
      _startTime = null;
    });
  }

  void _saveToLog() {
    if (_elapsedTime.inSeconds == 0) return;
    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      startTime: _startTime!,
      endTime: DateTime.now(),
      duration: _elapsedTime,
      hours: _elapsedTime.inMinutes / 60,
      clientId: '', // Will be selected in invoice creation
      description: '',
    );
    setState(() {
      _timeEntries.add(entry);
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Saved'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(_elapsedTime)}'),
            Text('Hours: ${entry.hours.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('What would you like to do?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Continue Tracking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToInvoiceWithTime(entry);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF50C878),
            ),
            child: const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }

  void _navigateToInvoiceWithTime(TimeEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceCreationScreen(),
      ),
    );
  }

  Widget _buildRecentEntries() {
    if (_timeEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No time entries yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Time Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _timeEntries.length,
          itemBuilder: (context, index) {
            final entry = _timeEntries[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF50C878),
                  child: const Icon(
                    LucideIcons.clock,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  DateFormat('MMM d, h:mm a').format(entry.date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Duration: ${_formatDuration(entry.duration)}',
                ),
                trailing: Text(
                  '${entry.hours.toStringAsFixed(2)} hrs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF50C878),
                  ),
                ),
                onTap: () => _navigateToInvoiceWithTime(entry),
              ),
            );
          },
        ),
      ],
    );
  }
} 