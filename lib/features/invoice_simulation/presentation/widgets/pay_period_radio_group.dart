import 'package:flutter/material.dart';

class PayPeriodRadioGroup extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final Map<String, String> labels;

  const PayPeriodRadioGroup({
    Key? key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) => Expanded(
        child: RadioListTile<String>(
          value: option,
          groupValue: value,
          onChanged: onChanged,
          title: Text(
            labels[option] ?? option,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          activeColor: const Color(0xFF50C878),
        ),
      )).toList(),
    );
  }
} 