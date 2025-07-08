import 'package:flutter/material.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/widgets/summary_row.dart';

class InvoiceLogStep extends StatelessWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onBack;
  final VoidCallback onCreate;
  const InvoiceLogStep({Key? key, required this.formData, required this.onBack, required this.onCreate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) => date == null ? '' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    String formatCurrency(num? value) => value == null ? ' 240.00' : '\$${value.toStringAsFixed(2)}';
    final logs = formData['logs'] as List<dynamic>?;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logs != null && logs.isNotEmpty) ...[
            const Text('Daily Log Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (final log in logs)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${formatDate(log['date'])}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (log['description'] != null) Text('Description: ${log['description']}'),
                      if (log['hours'] != null) Text('Hours: ${log['hours']}'),
                      if (log['rate'] != null) Text('Rate: ${log['rate']}'),
                      if (log['amount'] != null) Text('Amount: ${log['amount']}'),
                      if (log['worked'] != null) Text('Worked: ${log['worked'] ? 'Yes' : 'No'}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
          const Text('Invoice Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  const Color(0xFF50C878).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF50C878).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '14-Day Period',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SummaryRow(label: 'Pay Period:', value: '${formatDate(formData['payPeriodStart'])} to ${formatDate(formData['payPeriodEnd'])}', icon: Icons.calendar_today),
                SummaryRow(label: 'Start Date:', value: formatDate(formData['payPeriodStart']), icon: Icons.calendar_today),
                SummaryRow(label: 'End Date:', value: formatDate(formData['payPeriodEnd']), icon: Icons.calendar_today),
                SummaryRow(label: 'Invoice Number:', value: formData['invoiceNumber'] ?? '', icon: Icons.confirmation_number),
                SummaryRow(label: 'Client:', value: formData['clientName'] ?? '', icon: Icons.business),
                SummaryRow(label: 'Pay Type:', value: formData['payType'] ?? '', icon: Icons.payment),
                SummaryRow(label: 'Base Rate:', value: formatCurrency(formData['rate']), icon: Icons.attach_money),
                SummaryRow(label: 'Daily Subsistence:', value: formatCurrency(formData['dailySubsistence']), icon: Icons.restaurant),
                SummaryRow(label: 'Truck Rate:', value: formatCurrency(formData['truckRate']), icon: Icons.local_shipping),
                SummaryRow(label: 'Kms Driven per Day:', value: formData['kmsDriven']?.toString() ?? '', icon: Icons.speed),
                SummaryRow(label: 'Kms Rate:', value: formatCurrency(formData['kmsRate']), icon: Icons.route),
                SummaryRow(label: 'Other Charges:', value: formatCurrency(formData['otherCharges']), icon: Icons.add_circle_outline),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
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
                onPressed: onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C878),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
} 