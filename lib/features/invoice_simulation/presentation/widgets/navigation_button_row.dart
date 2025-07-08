import 'package:flutter/material.dart';

class NavigationButtonRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool nextEnabled;

  const NavigationButtonRow({
    Key? key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: nextEnabled ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF50C878),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(nextLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
} 