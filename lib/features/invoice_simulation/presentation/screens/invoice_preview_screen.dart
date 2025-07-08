import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/models/invoice_data.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceData invoice;
  const InvoicePreviewScreen({Key? key, required this.invoice}) : super(key: key);

  double get subtotal => invoice.lineItems.fold(0, (sum, item) => sum + item.amount);
  double get gst => subtotal * 0.05;
  double get subsistenceTotal => invoice.lineItems.fold(0, (sum, item) => sum + (item.category == 'subsistence' ? item.amount : 0));
  double get grandTotal => subtotal + gst + subsistenceTotal;

  // Helper method to check if date is in pay period
  bool _isInPayPeriod(DateTime date) {
    final payPeriodStart = DateTime.parse(invoice.lineItems.first.id.split('T')[0]);
    final payPeriodEnd = DateTime.parse(invoice.lineItems.last.id.split('T')[0]);
    return !date.isBefore(payPeriodStart) && !date.isAfter(payPeriodEnd);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate pay period dates from line items
    final payPeriodStart = DateTime.parse(invoice.lineItems.first.id.split('T')[0]);
    final payPeriodEnd = DateTime.parse(invoice.lineItems.last.id.split('T')[0]);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Invoice Preview', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Calendar with highlighted pay period
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: payPeriodStart.subtract(const Duration(days: 7)),
              lastDay: payPeriodEnd.add(const Duration(days: 7)),
              focusedDay: payPeriodStart,
              calendarFormat: CalendarFormat.month,
              enabledDayPredicate: (day) => true,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final inPeriod = _isInPayPeriod(day);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: inPeriod ? const Color(0xFF50C878) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: inPeriod ? Colors.white : Colors.black,
                          fontWeight: inPeriod ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Daily entries section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daily Entries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // List of daily entries
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: invoice.lineItems.length,
              itemBuilder: (context, index) {
                final item = invoice.lineItems[index];
                final date = DateTime.parse(item.id.split('T')[0]);
                
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Date circle
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF50C878).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFF50C878), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF50C878),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Entry details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (item.description.isNotEmpty)
                                Text(
                                  item.description,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              if (item.location.isNotEmpty)
                                Text(
                                  'Location: ${item.location}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        
                        // Amount
                        Text(
                          '\$${item.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF50C878),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}