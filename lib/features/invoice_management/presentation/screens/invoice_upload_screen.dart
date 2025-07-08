import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';

class InvoiceUploadScreen extends StatefulWidget {
  const InvoiceUploadScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceUploadScreen> createState() => _InvoiceUploadScreenState();
}

class _InvoiceUploadScreenState extends State<InvoiceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  PlatformFile? _selectedFile;
  bool _isProcessing = false;
  
  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _gstAmountController = TextEditingController();
  final _subsistenceController = TextEditingController();
  
  DateTime _invoiceDate = DateTime.now();
  DateTime _payPeriodStart = DateTime.now();
  DateTime _payPeriodEnd = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Upload Past Invoice'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF50C878),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Upload Section
              _buildFileUploadSection(),
              const SizedBox(height: 24),
              
              // Invoice Details Section
              _buildInvoiceDetailsSection(),
              const SizedBox(height: 24),
              
              // Amount Details Section
              _buildAmountDetailsSection(),
              const SizedBox(height: 24),
              
              // Date Selection Section
              _buildDateSection(),
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.upload, color: Color(0xFF50C878)),
                const SizedBox(width: 8),
                const Text(
                  'Upload Invoice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: const Color(0xFF50C878),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF50C878).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.cloudUpload,
                            size: 40,
                            color: const Color(0xFF50C878),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to upload PDF or Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'PDF, JPG, PNG (max 10MB)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFile!.extension == 'pdf'
                              ? LucideIcons.fileText
                              : LucideIcons.image,
                            color: const Color(0xFF50C878),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _selectedFile!.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => setState(() => _selectedFile = null),
                          ),
                        ],
                      ),
                ),
              ),
            ),
            
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processFile,
                icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.scan),
                label: Text(_isProcessing ? 'Processing...' : 'Auto-Extract Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C878),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.fileText, color: Color(0xFF50C878)),
                const SizedBox(width: 8),
                const Text(
                  'Invoice Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.hash),
                    ),
                    validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.building2),
                    ),
                    validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.dollarSign, color: Color(0xFF50C878)),
                const SizedBox(width: 8),
                const Text(
                  'Amount Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount',
                      prefixText: ' 4',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (_) => _calculateGST(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _gstAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'GST Amount',
                      prefixText: ' 4',
                      border: OutlineInputBorder(),
                      helperText: 'Auto-calculated',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subsistenceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Subsistence Amount',
                prefixText: ' 4',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.utensils),
                helperText: 'Tax-free daily allowance',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.calendar, color: Color(0xFF50C878)),
                const SizedBox(width: 8),
                const Text(
                  'Dates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Invoice Date',
                    date: _invoiceDate,
                    onTap: () => _pickDate(context, _invoiceDate, (date) => setState(() => _invoiceDate = date)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Pay Period Start',
                    date: _payPeriodStart,
                    onTap: () => _pickDate(context, _payPeriodStart, (date) => setState(() => _payPeriodStart = date)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Pay Period End',
              date: _payPeriodEnd,
              onTap: () => _pickDate(context, _payPeriodEnd, (date) => setState(() => _payPeriodEnd = date)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, required DateTime date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(date)),
            const Icon(LucideIcons.calendar, size: 18, color: Color(0xFF50C878)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _submit,
        icon: const Icon(LucideIcons.upload),
        label: const Text('Upload Invoice'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF50C878),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _processFile() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));
    
    // In real app, this would use OCR/ML to extract data
    setState(() {
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice processed! Please verify the extracted data.'),
        backgroundColor: Color(0xFF50C878),
      ),
    );
  }

  void _calculateGST() {
    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final gst = total * 0.05 / 1.05; // Extract GST from total
    _gstAmountController.text = gst.toStringAsFixed(2);
  }

  Future<void> _pickDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDatePicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement upload logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice uploaded!'),
          backgroundColor: Color(0xFF50C878),
        ),
      );
    }
  }
} 