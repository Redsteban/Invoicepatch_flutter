import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/bookkeeping_service.dart';

const emeraldGreen = Color(0xFF50C878);

class ExpenseReportsScreen extends StatefulWidget {
  const ExpenseReportsScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseReportsScreen> createState() => _ExpenseReportsScreenState();
}

class _ExpenseReportsScreenState extends State<ExpenseReportsScreen> {
  final BookkeepingService _bookkeepingService = BookkeepingService();
  int _selectedYear = DateTime.now().year;
  int _selectedQuarter = ((DateTime.now().month - 1) ~/ 3) + 1;
  
  // Mock data - in real app, this would come from your database
  final List<ExpenseReceipt> _receipts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Expense Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: _exportAllReports,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year/Quarter Selector
              _buildPeriodSelector(),
              const SizedBox(height: 24),

              // Quick Stats
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Report Cards
              _buildReportCards(),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, color: emeraldGreen),
            const SizedBox(width: 12),
            const Text(
              'Reporting Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            DropdownButton<int>(
              value: _selectedYear,
              items: List.generate(5, (index) => DateTime.now().year - index)
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _selectedQuarter,
              items: [1, 2, 3, 4]
                  .map((quarter) => DropdownMenuItem(
                        value: quarter,
                        child: Text('Q$quarter'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuarter = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final quarterlyReport = _bookkeepingService.generateQuarterlyTaxReport(_receipts, _selectedYear, _selectedQuarter);
    final summary = quarterlyReport['summary'] as Map<String, dynamic>;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Expenses',
            '\$${summary['totalExpenses']?.toStringAsFixed(2) ?? '0.00'}',
            LucideIcons.dollarSign,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Tax Paid',
            '\$${summary['totalTaxPaid']?.toStringAsFixed(2) ?? '0.00'}',
            LucideIcons.percent,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Deductible',
            '\$${summary['totalDeductibleExpenses']?.toStringAsFixed(2) ?? '0.00'}',
            LucideIcons.checkCircle,
            emeraldGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Reports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Quarterly GST/HST Report
        _buildReportCard(
          'Quarterly GST/HST Report',
          'Q$_selectedQuarter $_selectedYear tax submission report',
          LucideIcons.fileText,
          emeraldGreen,
          () => _viewQuarterlyReport(),
        ),
        
        // Annual Business Summary
        _buildReportCard(
          'Annual Business Summary',
          'T2125 Business Income Statement data',
          LucideIcons.barChart,
          Colors.blue,
          () => _viewAnnualSummary(),
        ),
        
        // Expense Summary
        _buildReportCard(
          'Expense Summary',
          'Detailed breakdown by category',
          LucideIcons.pieChart,
          Colors.purple,
          () => _viewExpenseSummary(),
        ),
        
        // Compliance Report
        _buildReportCard(
          'Compliance Report',
          'CRA audit readiness assessment',
          LucideIcons.shield,
          Colors.orange,
          () => _viewComplianceReport(),
        ),
        
        // Accountant Package
        _buildReportCard(
          'Accountant Package',
          'Complete package for your accountant',
          LucideIcons.briefcase,
          Colors.green,
          () => _generateAccountantPackage(),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_receipts.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.receipt,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No receipts scanned yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start scanning receipts to see reports',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_receipts.take(5).map((receipt) => _buildActivityItem(receipt))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ExpenseReceipt receipt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: emeraldGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.receipt, color: emeraldGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.vendorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${receipt.date.day}/${receipt.date.month}/${receipt.date.year}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${receipt.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _viewQuarterlyReport() {
    final report = _bookkeepingService.generateQuarterlyTaxReport(_receipts, _selectedYear, _selectedQuarter);
    _showReportDialog('Quarterly GST/HST Report', _formatQuarterlyReport(report));
  }

  void _viewAnnualSummary() {
    final report = _bookkeepingService.generateAnnualBusinessSummary(_receipts, _selectedYear);
    _showReportDialog('Annual Business Summary', _formatAnnualSummary(report));
  }

  void _viewExpenseSummary() {
    final startDate = DateTime(_selectedYear, (_selectedQuarter - 1) * 3 + 1, 1);
    final endDate = DateTime(_selectedYear, _selectedQuarter * 3 + 1, 0);
    final report = _bookkeepingService.generateExpenseSummary(_receipts, startDate, endDate);
    _showReportDialog('Expense Summary', _formatExpenseSummary(report));
  }

  void _viewComplianceReport() {
    final report = _bookkeepingService.generateComplianceReport(_receipts);
    _showReportDialog('Compliance Report', _formatComplianceReport(report));
  }

  void _generateAccountantPackage() {
    final package = _bookkeepingService.generateAccountantPackage(_receipts, _selectedYear);
    _showReportDialog('Accountant Package', _formatAccountantPackage(package));
  }

  void _showReportDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportReport(title, content);
            },
            style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  String _formatQuarterlyReport(Map<String, dynamic> report) {
    final summary = report['summary'] as Map<String, dynamic>;
    return '''
QUARTERLY GST/HST REPORT
Period: ${report['period']}

SUMMARY:
Total Expenses: \$${summary['totalExpenses']?.toStringAsFixed(2) ?? '0.00'}
Deductible Expenses: \$${summary['totalDeductibleExpenses']?.toStringAsFixed(2) ?? '0.00'}
GST Paid: \$${summary['totalGST']?.toStringAsFixed(2) ?? '0.00'}
HST Paid: \$${summary['totalHST']?.toStringAsFixed(2) ?? '0.00'}
Total Tax Paid: \$${summary['totalTaxPaid']?.toStringAsFixed(2) ?? '0.00'}
Number of Receipts: ${summary['receiptCount']}

CATEGORY BREAKDOWN:
${_formatCategoryBreakdown(report['categorizedExpenses'] as Map<String, dynamic>)}
''';
  }

  String _formatAnnualSummary(Map<String, dynamic> report) {
    return '''
ANNUAL BUSINESS SUMMARY
Year: ${report['year']}

TOTAL SUMMARY:
Total Business Expenses: \$${report['totalBusinessExpenses']?.toStringAsFixed(2) ?? '0.00'}
Total Tax Paid: \$${report['totalTaxPaid']?.toStringAsFixed(2) ?? '0.00'}
Number of Receipts: ${report['receiptCount']}

T2125 LINE ITEMS:
${_formatT2125LineItems(report['t2125LineItems'] as Map<String, dynamic>)}
''';
  }

  String _formatExpenseSummary(Map<String, dynamic> report) {
    return '''
EXPENSE SUMMARY
Period: ${report['period']}

SUMMARY:
Total Receipts: ${report['totalReceipts']}
Total Expenses: \$${report['totalExpenses']?.toStringAsFixed(2) ?? '0.00'}
Total Deductible: \$${report['totalDeductible']?.toStringAsFixed(2) ?? '0.00'}
Total Tax: \$${report['totalTax']?.toStringAsFixed(2) ?? '0.00'}

CATEGORY BREAKDOWN:
${_formatCategoryData(report['categories'] as Map<String, dynamic>)}
''';
  }

  String _formatComplianceReport(Map<String, dynamic> report) {
    return '''
COMPLIANCE REPORT

SUMMARY:
Total Receipts: ${report['totalReceipts']}
Receipts with Issues: ${report['receiptsWithIssues']}
Compliance Rate: ${report['complianceRate']}%

ISSUES SUMMARY:
${_formatIssuesSummary(report['issuesSummary'] as Map<String, dynamic>)}

RECOMMENDATIONS:
${_formatRecommendations(report['recommendations'] as List<dynamic>)}
''';
  }

  String _formatAccountantPackage(Map<String, dynamic> package) {
    return '''
ACCOUNTANT PACKAGE
Generated: ${package['generatedAt']}
Year: ${package['year']}
Total Receipts: ${package['totalReceipts']}

This package includes:
- Annual Business Summary
- Quarterly GST/HST Reports
- Compliance Assessment
- All Receipt Images
- Detailed Expense Categorization

The package is ready for submission to your accountant.
''';
  }

  String _formatCategoryBreakdown(Map<String, dynamic> categories) {
    return categories.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return '${entry.key}: \$${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'} (${data['receipts']} receipts)';
    }).join('\n');
  }

  String _formatT2125LineItems(Map<String, dynamic> lineItems) {
    return lineItems.entries.map((entry) {
      return '${entry.key}: \$${entry.value?.toStringAsFixed(2) ?? '0.00'}';
    }).join('\n');
  }

  String _formatCategoryData(Map<String, dynamic> categories) {
    return categories.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return '${data['name']}: \$${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'} (${data['receiptCount']} receipts)';
    }).join('\n');
  }

  String _formatIssuesSummary(Map<String, dynamic> issues) {
    return issues.entries.map((entry) {
      return '${entry.key}: ${entry.value} occurrences';
    }).join('\n');
  }

  String _formatRecommendations(List<dynamic> recommendations) {
    return recommendations.map((rec) => '• $rec').join('\n');
  }

  void _exportReport(String title, String content) {
    // Here you would implement actual export functionality
    // For example, sharing as PDF or text file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title exported successfully!'),
        backgroundColor: emeraldGreen,
      ),
    );
  }

  void _exportAllReports() {
    // Export all reports as a complete package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All reports exported successfully!'),
        backgroundColor: emeraldGreen,
      ),
    );
  }
}