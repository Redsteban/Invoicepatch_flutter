import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/expense_categorization_service.dart';
import 'dart:io';

const emeraldGreen = Color(0xFF50C878);

class ReceiptDetailsScreen extends StatefulWidget {
  final ExpenseReceipt receipt;

  const ReceiptDetailsScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  final ExpenseCategorizationService _categorizationService = ExpenseCategorizationService();
  late ExpenseReceipt _receipt;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Receipt Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.save),
            onPressed: _saveReceipt,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt Image
              _buildReceiptImage(),
              const SizedBox(height: 24),

              // Basic Information
              _buildBasicInfoCard(),
              const SizedBox(height: 16),

              // Tax Information
              _buildTaxInfoCard(),
              const SizedBox(height: 16),

              // Category and Deductibility
              _buildCategoryCard(),
              const SizedBox(height: 16),

              // CRA Requirements
              _buildCRARequirementsCard(),
              const SizedBox(height: 16),

              // Items (if available)
              if (_receipt.rawOcrData['items'] != null)
                _buildItemsCard(),
              
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_receipt.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.receipt, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Receipt Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _receipt.vendorName,
              decoration: const InputDecoration(
                labelText: 'Vendor Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _receipt = _receipt.copyWith(vendorName: value);
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _receipt.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  _receipt = _receipt.copyWith(description: value);
                });
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _receipt.date.toString().split(' ')[0],
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(LucideIcons.calendar),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _receipt.receiptNumber,
                    decoration: const InputDecoration(
                      labelText: 'Receipt Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _receipt = _receipt.copyWith(receiptNumber: value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.calculator, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tax Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _receipt.subtotal.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Subtotal',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final subtotal = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _receipt = _receipt.copyWith(subtotal: subtotal);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _receipt.taxAmount.toStringAsFixed(2),
                    decoration: InputDecoration(
                      labelText: '${_receipt.taxType.name.toUpperCase()} Tax',
                      prefixText: '\$',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final taxAmount = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _receipt = _receipt.copyWith(taxAmount: taxAmount);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _receipt.total.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final total = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _receipt = _receipt.copyWith(total: total);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: emeraldGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: emeraldGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tax Rate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_receipt.taxRate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: emeraldGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.tag, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Category & Deductibility',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<ExpenseCategory>(
              value: _receipt.category,
              decoration: const InputDecoration(
                labelText: 'Expense Category',
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_categorizationService.getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _receipt = _receipt.copyWith(
                      category: value,
                      isDeductible: _categorizationService.isDeductible(value, _receipt.total),
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _receipt.isDeductible ? emeraldGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _receipt.isDeductible ? emeraldGreen.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _receipt.isDeductible ? LucideIcons.checkCircle : LucideIcons.xCircle,
                    color: _receipt.isDeductible ? emeraldGreen : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _receipt.isDeductible ? 'Tax Deductible' : 'Not Deductible',
                          style: TextStyle(
                            color: _receipt.isDeductible ? emeraldGreen : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _categorizationService.getCategoryDescription(_receipt.category),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_receipt.isDeductible)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: emeraldGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(_categorizationService.getDeductionPercentage(_receipt.category) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCRARequirementsCard() {
    final requirements = _categorizationService.getCRARequirements(_receipt.category);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.fileText, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'CRA Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...requirements.map((requirement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: emeraldGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      requirement,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    final items = _receipt.rawOcrData['items'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.list, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['description'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(LucideIcons.fileText),
            label: const Text('Generate Report'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveReceipt,
            icon: const Icon(LucideIcons.save),
            label: const Text('Save Receipt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: emeraldGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _receipt.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _receipt = _receipt.copyWith(date: date);
      });
    }
  }

  void _saveReceipt() {
    if (_formKey.currentState!.validate()) {
      // Here you would save the receipt to your database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt saved successfully!'),
          backgroundColor: emeraldGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _generateReport() {
    // Here you would generate a detailed report for the accountant
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text('This will generate a detailed expense report for your accountant including all CRA requirements and supporting documentation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate and download/share the report
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report generated and ready for download!'),
                  backgroundColor: emeraldGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}