import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:invoicepatch_contractor/shared/models/past_invoice.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  
  // Mock data - replace with real data from bloc
  final List<PastInvoice> _invoices = [];

  List<PastInvoice> get _filteredInvoices {
    var filtered = _invoices;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) =>
        invoice.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        invoice.clientName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply date range filter
    if (_dateRange != null) {
      filtered = filtered.where((invoice) =>
        invoice.invoiceDate.isAfter(_dateRange!.start) &&
        invoice.invoiceDate.isBefore(_dateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }
    
    // Sort by date descending
    filtered.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Invoice History'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF50C878),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              // TODO: Implement navigation to InvoiceUploadScreen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Summary Cards
          _buildSummaryCards(),
          
          // Invoice List
          Expanded(
            child: _buildInvoiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search invoices...',
          prefixIcon: const Icon(LucideIcons.search),
          suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => setState(() => _searchQuery = ''),
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF50C878), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRevenue = _filteredInvoices.fold<double>(
      0, (sum, invoice) => sum + invoice.totalAmount
    );
    final totalGST = _filteredInvoices.fold<double>(
      0, (sum, invoice) => sum + invoice.gstAmount
    );
    final avgInvoice = _filteredInvoices.isEmpty ? 0 : totalRevenue / _filteredInvoices.length;

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: LucideIcons.dollarSign,
              label: 'Total Revenue',
              value: '\$${totalRevenue.toStringAsFixed(0)}',
              color: const Color(0xFF50C878),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: LucideIcons.percent,
              label: 'Total GST',
              value: '\$${totalGST.toStringAsFixed(0)}',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: LucideIcons.trendingUp,
              label: 'Avg Invoice',
              value: '\$${avgInvoice.toStringAsFixed(0)}',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList() {
    if (_filteredInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileX,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement navigation to InvoiceUploadScreen
              },
              icon: const Icon(LucideIcons.upload),
              label: const Text('Upload Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50C878),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _filteredInvoices[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(PastInvoice invoice) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToInvoiceDetail(invoice);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSourceColor(invoice.source).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSourceLabel(invoice.source),
                      style: TextStyle(
                        color: _getSourceColor(invoice.source),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    LucideIcons.building2,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    invoice.clientName,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y').format(invoice.invoiceDate),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  Text(
                    '\$${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF50C878),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSourceColor(InvoiceSource source) {
    switch (source) {
      case InvoiceSource.generated:
        return const Color(0xFF50C878);
      case InvoiceSource.uploaded:
        return Colors.blue;
      case InvoiceSource.manual:
        return Colors.orange;
    }
  }

  String _getSourceLabel(InvoiceSource source) {
    switch (source) {
      case InvoiceSource.generated:
        return 'Generated';
      case InvoiceSource.uploaded:
        return 'Uploaded';
      case InvoiceSource.manual:
        return 'Manual';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterDialog(
        onApply: (dateRange) {
          setState(() {
            _dateRange = dateRange;
          });
        },
      ),
    );
  }

  void _navigateToInvoiceDetail(PastInvoice invoice) {
    // TODO: Implement navigation to InvoiceDetailScreen
  }
}

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final Function(DateTimeRange?) onApply;

  const _FilterDialog({required this.onApply});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Invoices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Date Range Picker
          ListTile(
            leading: const Icon(LucideIcons.calendar),
            title: Text(_selectedRange == null
              ? 'All Dates'
              : '${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d').format(_selectedRange!.end)}'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF50C878),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                setState(() => _selectedRange = range);
              }
            },
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _selectedRange = null);
                    widget.onApply(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedRange);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50C878),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 