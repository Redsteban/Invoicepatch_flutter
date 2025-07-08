import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart'; // For AnimatedGradientButton

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    final hours = _elapsedTime.inMinutes / 60;
    // TODO: Implement navigation to invoice creation with pre-filled hours
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved $hours hours to log (feature coming soon)')),
    );
  }
} 