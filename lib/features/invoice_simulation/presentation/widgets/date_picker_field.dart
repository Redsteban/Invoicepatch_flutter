import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const emeraldGreen = Color(0xFF50C878);

class DatePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool enabled;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.icon,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: minDate ?? DateTime(2020),
          lastDate: maxDate ?? DateTime(2030),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      } : null,
      child: IgnorePointer(
        child: TextFormField(
          controller: TextEditingController(text: DateFormat('MMM dd, yyyy').format(selectedDate)),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: emeraldGreen),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
          enabled: false, // Keep disabled to prevent manual text input
        ),
      ),
    );
  }
} 