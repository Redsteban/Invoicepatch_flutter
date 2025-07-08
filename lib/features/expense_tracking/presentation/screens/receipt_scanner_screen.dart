import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/camera_service.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/ocr_service.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/expense_categorization_service.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/presentation/screens/receipt_details_screen.dart';
import 'dart:io';

const emeraldGreen = Color(0xFF50C878);

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final CameraService _cameraService = CameraService();
  final OCRService _ocrService = OCRService();
  final ExpenseCategorizationService _categorizationService = ExpenseCategorizationService();
  
  bool _isProcessing = false;
  String? _selectedProvince = 'ON'; // Default to Ontario

  final List<String> _provinces = [
    'AB', 'BC', 'MB', 'NB', 'NL', 'NT', 'NS', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'
  ];

  final Map<String, String> _provinceNames = {
    'AB': 'Alberta',
    'BC': 'British Columbia',
    'MB': 'Manitoba',
    'NB': 'New Brunswick',
    'NL': 'Newfoundland and Labrador',
    'NT': 'Northwest Territories',
    'NS': 'Nova Scotia',
    'NU': 'Nunavut',
    'ON': 'Ontario',
    'PE': 'Prince Edward Island',
    'QC': 'Quebec',
    'SK': 'Saskatchewan',
    'YT': 'Yukon',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Expense Scanner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),
              
              // Tax Information
              _buildTaxInfoCard(),
              const SizedBox(height: 24),
              
              // Recent Receipts
              Expanded(
                child: _buildRecentReceipts(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            emeraldGreen.withOpacity(0.8),
            emeraldGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: emeraldGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                  LucideIcons.receipt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Receipt Scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan receipts for automatic expense tracking',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'CRA Compliant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Province: ${_provinceNames[_selectedProvince]}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: LucideIcons.camera,
            title: 'Scan Receipt',
            subtitle: 'Take a photo',
            onTap: _scanReceipt,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: LucideIcons.image,
            title: 'From Gallery',
            subtitle: 'Select image',
            onTap: _selectFromGallery,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: emeraldGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxInfoCard() {
    final taxRate = CanadianTaxRates.getTaxRate(_selectedProvince ?? 'ON');
    final taxType = CanadianTaxRates.getTaxType(_selectedProvince ?? 'ON');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.calculator,
                color: emeraldGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tax Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTaxInfo(
                  'Tax Type',
                  taxType.name.toUpperCase(),
                  emeraldGreen,
                ),
              ),
              Expanded(
                child: _buildTaxInfo(
                  'Tax Rate',
                  '${(taxRate * 100).toStringAsFixed(1)}%',
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReceipts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Receipts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _cameraService.getReceiptImages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          'Tap "Scan Receipt" to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final imagePath = snapshot.data![index];
                    return _buildReceiptItem(imagePath);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptItem(String imagePath) {
    final fileName = imagePath.split('/').last;
    final date = DateTime.now(); // You might want to extract this from filename
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(fileName),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => _processReceiptImage(imagePath),
      ),
    );
  }

  Future<void> _scanReceipt() async {
    setState(() => _isProcessing = true);
    
    try {
      final imagePath = await _cameraService.captureReceiptImage();
      if (imagePath != null) {
        await _processReceiptImage(imagePath);
      }
    } catch (e) {
      _showErrorSnackBar('Error scanning receipt: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectFromGallery() async {
    setState(() => _isProcessing = true);
    
    try {
      final imagePath = await _cameraService.pickReceiptFromGallery();
      if (imagePath != null) {
        await _processReceiptImage(imagePath);
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processReceiptImage(String imagePath) async {
    setState(() => _isProcessing = true);
    
    try {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing receipt...'),
            ],
          ),
        ),
      );

      // Extract text from image
      final ocrData = await _ocrService.extractReceiptData(imagePath);
      
      // Categorize expense
      final category = _categorizationService.categorizeExpense(
        ocrData['vendorName'] ?? '',
        ocrData['items']?.map((item) => item['description']).join(' ') ?? '',
        ocrData['items'] ?? [],
      );

      // Create expense receipt
      final receipt = ExpenseReceipt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        vendorName: ocrData['vendorName'] ?? 'Unknown Vendor',
        date: ocrData['date'] ?? DateTime.now(),
        subtotal: ocrData['subtotal'] ?? 0.0,
        taxAmount: ocrData['taxAmount'] ?? 0.0,
        total: ocrData['total'] ?? 0.0,
        taxType: ocrData['taxType'] ?? CanadianTaxRates.getTaxType(_selectedProvince ?? 'ON'),
        taxRate: CanadianTaxRates.getTaxRate(_selectedProvince ?? 'ON'),
        province: _selectedProvince ?? 'ON',
        category: category,
        description: ocrData['items']?.map((item) => item['description']).join(', ') ?? '',
        receiptNumber: ocrData['receiptNumber'] ?? '',
        isDeductible: _categorizationService.isDeductible(category, ocrData['total'] ?? 0.0),
        rawOcrData: ocrData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Close processing dialog
      Navigator.pop(context);

      // Navigate to receipt details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptDetailsScreen(receipt: receipt),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close processing dialog
      _showErrorSnackBar('Error processing receipt: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select your province for accurate tax calculations:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(),
              ),
              items: _provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(_provinceNames[province] ?? province),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}