import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> extractReceiptData(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      print('OCR Error: $e');
      return {};
    }
  }

  Map<String, dynamic> _parseReceiptText(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();
    
    final result = <String, dynamic>{
      'rawText': text,
      'vendorName': _extractVendorName(lines),
      'date': _extractDate(lines),
      'total': _extractTotal(lines),
      'subtotal': _extractSubtotal(lines),
      'taxAmount': _extractTaxAmount(lines),
      'taxType': _extractTaxType(lines),
      'receiptNumber': _extractReceiptNumber(lines),
      'items': _extractItems(lines),
    };

    return result;
  }

  String _extractVendorName(List<String> lines) {
    // Look for vendor name in first few lines
    for (int i = 0; i < (lines.length > 5 ? 5 : lines.length); i++) {
      final line = lines[i];
      if (line.isNotEmpty && 
          !line.contains(RegExp(r'[\d\$]')) &&
          line.length > 3 &&
          line.length < 50) {
        return line;
      }
    }
    return 'Unknown Vendor';
  }

  DateTime? _extractDate(List<String> lines) {
    final datePatterns = [
      RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})'), // MM/DD/YYYY or DD/MM/YYYY
      RegExp(r'(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})'), // YYYY/MM/DD
      RegExp(r'(\w{3})\s+(\d{1,2}),?\s+(\d{4})'), // Jan 15, 2024
      RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})'), // 15 Jan 2024
    ];

    for (final line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            return _parseDate(match, pattern);
          } catch (e) {
            continue;
          }
        }
      }
    }
    return DateTime.now();
  }

  DateTime _parseDate(RegExpMatch match, RegExp pattern) {
    final groups = match.groups([1, 2, 3]);
    
    if (pattern.pattern.contains(r'(\w{3})')) {
      // Handle month names
      final monthStr = groups[0] ?? groups[1];
      final dayStr = groups[1] ?? groups[0];
      final yearStr = groups[2];
      
      final monthMap = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };
      
      final month = monthMap[monthStr?.toLowerCase()] ?? 1;
      final day = int.parse(dayStr ?? '1');
      final year = int.parse(yearStr ?? '2024');
      
      return DateTime(year, month, day);
    } else {
      // Handle numeric dates
      final part1 = int.parse(groups[0] ?? '1');
      final part2 = int.parse(groups[1] ?? '1');
      final part3 = int.parse(groups[2] ?? '2024');
      
      if (part3 > 31) {
        // Format: MM/DD/YYYY or DD/MM/YYYY
        return DateTime(part3, part1, part2);
      } else {
        // Format: YYYY/MM/DD
        return DateTime(part1, part2, part3);
      }
    }
  }

  double _extractTotal(List<String> lines) {
    final totalPatterns = [
      RegExp(r'total[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'amount[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'grand total[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
    ];

    for (final line in lines.reversed) {
      for (final pattern in totalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
    }

    // Fallback: look for largest dollar amount
    return _findLargestAmount(lines);
  }

  double _extractSubtotal(List<String> lines) {
    final subtotalPatterns = [
      RegExp(r'subtotal[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'sub total[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'sub-total[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
    ];

    for (final line in lines) {
      for (final pattern in subtotalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
    }

    return 0.0;
  }

  double _extractTaxAmount(List<String> lines) {
    final taxPatterns = [
      RegExp(r'gst[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'hst[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'pst[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'tax[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
      RegExp(r'sales tax[:\s]*\$?(\d+\.?\d*)', RegExp.caseInsensitive),
    ];

    double totalTax = 0.0;
    for (final line in lines) {
      for (final pattern in taxPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          totalTax += double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
    }

    return totalTax;
  }

  TaxType _extractTaxType(List<String> lines) {
    final text = lines.join(' ').toLowerCase();
    
    if (text.contains('hst')) {
      return TaxType.hst;
    } else if (text.contains('pst')) {
      return TaxType.pst;
    } else if (text.contains('gst')) {
      return TaxType.gst;
    }
    
    return TaxType.gst; // Default to GST
  }

  String _extractReceiptNumber(List<String> lines) {
    final receiptPatterns = [
      RegExp(r'receipt\s*#?[:\s]*(\w+)', RegExp.caseInsensitive),
      RegExp(r'ref\s*#?[:\s]*(\w+)', RegExp.caseInsensitive),
      RegExp(r'transaction\s*#?[:\s]*(\w+)', RegExp.caseInsensitive),
      RegExp(r'invoice\s*#?[:\s]*(\w+)', RegExp.caseInsensitive),
    ];

    for (final line in lines) {
      for (final pattern in receiptPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1) ?? '';
        }
      }
    }

    return '';
  }

  List<Map<String, dynamic>> _extractItems(List<String> lines) {
    final items = <Map<String, dynamic>>[];
    
    for (final line in lines) {
      // Look for lines with item and price pattern
      final itemMatch = RegExp(r'(.+?)\s+\$?(\d+\.?\d*)').firstMatch(line);
      if (itemMatch != null) {
        final description = itemMatch.group(1)?.trim() ?? '';
        final price = double.tryParse(itemMatch.group(2) ?? '0') ?? 0.0;
        
        if (description.isNotEmpty && 
            price > 0 && 
            !description.toLowerCase().contains('total') &&
            !description.toLowerCase().contains('tax')) {
          items.add({
            'description': description,
            'price': price,
          });
        }
      }
    }
    
    return items;
  }

  double _findLargestAmount(List<String> lines) {
    double largest = 0.0;
    final amountPattern = RegExp(r'\$?(\d+\.?\d*)');
    
    for (final line in lines) {
      final matches = amountPattern.allMatches(line);
      for (final match in matches) {
        final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        if (amount > largest) {
          largest = amount;
        }
      }
    }
    
    return largest;
  }

  void dispose() {
    _textRecognizer.close();
  }
}