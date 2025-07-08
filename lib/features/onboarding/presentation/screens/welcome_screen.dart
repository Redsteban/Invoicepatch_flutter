import 'package:flutter/material.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';

class WelcomeDialog extends StatelessWidget {
  final VoidCallback onStartInvoice;
  const WelcomeDialog({Key? key, required this.onStartInvoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/app_logo.png',
              height: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF50C878),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Let’s get you started with your first invoice. Just fill in your pay period and invoice details to unlock smart metrics and insights on your dashboard.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                label: const Text(
                  'Start Invoice Creation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C878),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onStartInvoice();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 