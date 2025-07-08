import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../models/work_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/enums/work_type.dart';

class WorkPreferencesScreen extends StatefulWidget {
  const WorkPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<WorkPreferencesScreen> createState() => _WorkPreferencesScreenState();
}

class _WorkPreferencesScreenState extends State<WorkPreferencesScreen> {
  final Set<WorkType> _selectedWorkTypes = {WorkType.remote};
  final _industriesController = TextEditingController();
  int _daysPerWeek = 5;
  int _hoursPerDay = 8;

  void _toggleWorkType(WorkType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedWorkTypes.add(type);
      } else {
        _selectedWorkTypes.remove(type);
      }
    });
  }

  void _submit() {
    final prefs = WorkPreferences(
      workTypes: _selectedWorkTypes.toList(),
      industries: _industriesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      daysPerWeek: _daysPerWeek,
      hoursPerDay: _hoursPerDay,
    );
    context.read<OnboardingBloc>().add(SubmitWorkPreferences(prefs));
  }

  @override
  void dispose() {
    _industriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Work Preferences', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Preferred Work Types', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Remote'),
              value: _selectedWorkTypes.contains(WorkType.remote),
              onChanged: (v) => _toggleWorkType(WorkType.remote, v ?? false),
              activeColor: Color(0xFF01C38D),
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: const Text('Onsite'),
              value: _selectedWorkTypes.contains(WorkType.onsite),
              onChanged: (v) => _toggleWorkType(WorkType.onsite, v ?? false),
              activeColor: Color(0xFF01C38D),
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: const Text('Hybrid'),
              value: _selectedWorkTypes.contains(WorkType.hybrid),
              onChanged: (v) => _toggleWorkType(WorkType.hybrid, v ?? false),
              activeColor: Color(0xFF01C38D),
              checkColor: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text('Industries (comma separated)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _industriesController,
              decoration: const InputDecoration(
                hintText: 'e.g. Construction, IT, Healthcare',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Availability', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Days per week'),
                      Slider(
                        value: _daysPerWeek.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: _daysPerWeek.toString(),
                        onChanged: (v) => setState(() => _daysPerWeek = v.round()),
                        activeColor: Color(0xFF01C38D),
                        inactiveColor: Color(0xFF132D46),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hours per day'),
                      Slider(
                        value: _hoursPerDay.toDouble(),
                        min: 1,
                        max: 16,
                        divisions: 15,
                        label: _hoursPerDay.toString(),
                        onChanged: (v) => setState(() => _hoursPerDay = v.round()),
                        activeColor: Color(0xFF01C38D),
                        inactiveColor: Color(0xFF132D46),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF01C38D),
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
} 