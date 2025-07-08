import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.icon,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: minDate ?? DateTime(2020),
          lastDate: maxDate ?? DateTime(2030),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: TextEditingController(text: DateFormat('MMM dd, yyyy').format(selectedDate)),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            enabled: false,
          ),
        ),
      ),
    );
  }
} 