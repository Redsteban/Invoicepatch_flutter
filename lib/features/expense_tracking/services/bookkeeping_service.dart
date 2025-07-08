import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';
import 'package:invoicepatch_contractor/features/expense_tracking/services/expense_categorization_service.dart';

class BookkeepingService {
  final ExpenseCategorizationService _categorizationService = ExpenseCategorizationService();

  // Generate quarterly GST/HST report
  Map<String, dynamic> generateQuarterlyTaxReport(List<ExpenseReceipt> receipts, int year, int quarter) {
    final quarterStart = DateTime(year, (quarter - 1) * 3 + 1, 1);
    final quarterEnd = DateTime(year, quarter * 3 + 1, 0);
    
    final quarterReceipts = receipts.where((receipt) =>
        receipt.date.isAfter(quarterStart) && receipt.date.isBefore(quarterEnd.add(const Duration(days: 1)))
    ).toList();

    double totalGST = 0;
    double totalHST = 0;
    double totalPST = 0;
    double totalExpenses = 0;
    double totalDeductibleExpenses = 0;

    final Map<ExpenseCategory, List<ExpenseReceipt>> categorizedExpenses = {};
    
    for (final receipt in quarterReceipts) {
      totalExpenses += receipt.total;
      
      if (receipt.isDeductible) {
        final deductionPercentage = _categorizationService.getDeductionPercentage(receipt.category);
        totalDeductibleExpenses += receipt.total * deductionPercentage;
      }

      switch (receipt.taxType) {
        case TaxType.gst:
          totalGST += receipt.taxAmount;
          break;
        case TaxType.hst:
          totalHST += receipt.taxAmount;
          break;
        case TaxType.pst:
          totalPST += receipt.taxAmount;
          break;
        case TaxType.noTax:
          break;
      }

      categorizedExpenses.putIfAbsent(receipt.category, () => []);
      categorizedExpenses[receipt.category]!.add(receipt);
    }

    return {
      'period': 'Q$quarter $year',
      'quarterStart': quarterStart.toIso8601String(),
      'quarterEnd': quarterEnd.toIso8601String(),
      'summary': {
        'totalExpenses': totalExpenses,
        'totalDeductibleExpenses': totalDeductibleExpenses,
        'totalGST': totalGST,
        'totalHST': totalHST,
        'totalPST': totalPST,
        'totalTaxPaid': totalGST + totalHST + totalPST,
        'receiptCount': quarterReceipts.length,
      },
      'categorizedExpenses': categorizedExpenses.map((category, receipts) => MapEntry(
        _categorizationService.getCategoryName(category),
        {
          'receipts': receipts.length,
          'totalAmount': receipts.fold(0.0, (sum, receipt) => sum + receipt.total),
          'deductibleAmount': receipts.fold(0.0, (sum, receipt) => 
            sum + (receipt.isDeductible ? receipt.total * _categorizationService.getDeductionPercentage(receipt.category) : 0)
          ),
          'taxAmount': receipts.fold(0.0, (sum, receipt) => sum + receipt.taxAmount),
        }
      )),
      'receipts': quarterReceipts.map((receipt) => {
        'id': receipt.id,
        'date': receipt.date.toIso8601String(),
        'vendor': receipt.vendorName,
        'category': _categorizationService.getCategoryName(receipt.category),
        'subtotal': receipt.subtotal,
        'taxAmount': receipt.taxAmount,
        'total': receipt.total,
        'taxType': receipt.taxType.name.toUpperCase(),
        'isDeductible': receipt.isDeductible,
        'deductionPercentage': _categorizationService.getDeductionPercentage(receipt.category),
        'receiptNumber': receipt.receiptNumber,
      }).toList(),
    };
  }

  // Generate annual summary for T2125 (Business Income Statement)
  Map<String, dynamic> generateAnnualBusinessSummary(List<ExpenseReceipt> receipts, int year) {
    final yearStart = DateTime(year, 1, 1);
    final yearEnd = DateTime(year, 12, 31);
    
    final yearReceipts = receipts.where((receipt) =>
        receipt.date.isAfter(yearStart.subtract(const Duration(days: 1))) && 
        receipt.date.isBefore(yearEnd.add(const Duration(days: 1)))
    ).toList();

    final Map<ExpenseCategory, double> categoryTotals = {};
    double totalBusinessExpenses = 0;
    double totalTaxPaid = 0;

    for (final receipt in yearReceipts) {
      if (receipt.isDeductible) {
        final deductionPercentage = _categorizationService.getDeductionPercentage(receipt.category);
        final deductibleAmount = receipt.total * deductionPercentage;
        
        categoryTotals[receipt.category] = (categoryTotals[receipt.category] ?? 0) + deductibleAmount;
        totalBusinessExpenses += deductibleAmount;
      }
      
      totalTaxPaid += receipt.taxAmount;
    }

    // Map to CRA T2125 line items
    final t2125LineItems = <String, double>{
      'Line 8523 - Meals and entertainment (50% only)': categoryTotals[ExpenseCategory.meals] ?? 0,
      'Line 8224 - Motor vehicle expenses': categoryTotals[ExpenseCategory.fuel] ?? 0,
      'Line 8230 - Office expenses': categoryTotals[ExpenseCategory.office] ?? 0,
      'Line 8518 - Insurance': categoryTotals[ExpenseCategory.insurance] ?? 0,
      'Line 8520 - Interest': 0, // Would need separate tracking
      'Line 8521 - Maintenance and repairs': categoryTotals[ExpenseCategory.maintenance] ?? 0,
      'Line 8220 - Management and administration fees': categoryTotals[ExpenseCategory.professional] ?? 0,
      'Line 8518 - Professional fees': categoryTotals[ExpenseCategory.professional] ?? 0,
      'Line 8226 - Rent': 0, // Would need separate tracking
      'Line 8225 - Supplies': categoryTotals[ExpenseCategory.equipment] ?? 0,
      'Line 8221 - Telephone and utilities': categoryTotals[ExpenseCategory.utilities] ?? 0,
      'Line 8229 - Travel': categoryTotals[ExpenseCategory.travel] ?? 0,
      'Line 8230 - Advertising': categoryTotals[ExpenseCategory.marketing] ?? 0,
      'Line 9270 - Other expenses': categoryTotals[ExpenseCategory.other] ?? 0,
    };

    return {
      'year': year,
      'totalBusinessExpenses': totalBusinessExpenses,
      'totalTaxPaid': totalTaxPaid,
      'receiptCount': yearReceipts.length,
      't2125LineItems': t2125LineItems,
      'categoryBreakdown': categoryTotals.map((category, amount) => MapEntry(
        _categorizationService.getCategoryName(category),
        amount
      )),
      'quarterlyBreakdown': [1, 2, 3, 4].map((quarter) => 
        generateQuarterlyTaxReport(receipts, year, quarter)
      ).toList(),
    };
  }

  // Generate expense summary by category
  Map<String, dynamic> generateExpenseSummary(List<ExpenseReceipt> receipts, DateTime startDate, DateTime endDate) {
    final filteredReceipts = receipts.where((receipt) =>
        receipt.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
        receipt.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    final Map<ExpenseCategory, Map<String, dynamic>> categoryData = {};
    
    for (final receipt in filteredReceipts) {
      final category = receipt.category;
      
      if (!categoryData.containsKey(category)) {
        categoryData[category] = {
          'name': _categorizationService.getCategoryName(category),
          'totalAmount': 0.0,
          'deductibleAmount': 0.0,
          'taxAmount': 0.0,
          'receiptCount': 0,
          'deductionPercentage': _categorizationService.getDeductionPercentage(category),
          'receipts': <ExpenseReceipt>[],
        };
      }
      
      categoryData[category]!['totalAmount'] += receipt.total;
      categoryData[category]!['taxAmount'] += receipt.taxAmount;
      categoryData[category]!['receiptCount'] += 1;
      categoryData[category]!['receipts'].add(receipt);
      
      if (receipt.isDeductible) {
        categoryData[category]!['deductibleAmount'] += 
          receipt.total * _categorizationService.getDeductionPercentage(category);
      }
    }

    return {
      'period': '${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}',
      'totalReceipts': filteredReceipts.length,
      'totalExpenses': filteredReceipts.fold(0.0, (sum, receipt) => sum + receipt.total),
      'totalDeductible': categoryData.values.fold(0.0, (sum, data) => sum + data['deductibleAmount']),
      'totalTax': filteredReceipts.fold(0.0, (sum, receipt) => sum + receipt.taxAmount),
      'categories': categoryData,
    };
  }

  // Generate compliance report for CRA audit
  Map<String, dynamic> generateComplianceReport(List<ExpenseReceipt> receipts) {
    final Map<String, List<String>> complianceIssues = {};
    final Map<String, int> issueCount = {};

    for (final receipt in receipts) {
      final issues = <String>[];
      
      // Check for missing receipt number
      if (receipt.receiptNumber.isEmpty) {
        issues.add('Missing receipt number');
      }
      
      // Check for reasonable amounts
      if (receipt.category == ExpenseCategory.meals && receipt.total > 200) {
        issues.add('Meal expense exceeds reasonable amount (\$200)');
      }
      
      // Check for tax calculation accuracy
      final expectedTax = receipt.subtotal * receipt.taxRate;
      if ((receipt.taxAmount - expectedTax).abs() > 0.50) {
        issues.add('Tax calculation may be incorrect');
      }
      
      // Check for proper categorization
      if (receipt.category == ExpenseCategory.other) {
        issues.add('Requires manual categorization review');
      }
      
      // Check for weekend/holiday transactions (might need justification)
      if (receipt.date.weekday > 5) {
        issues.add('Weekend transaction - may need business justification');
      }
      
      if (issues.isNotEmpty) {
        complianceIssues[receipt.id] = issues;
        for (final issue in issues) {
          issueCount[issue] = (issueCount[issue] ?? 0) + 1;
        }
      }
    }

    return {
      'totalReceipts': receipts.length,
      'receiptsWithIssues': complianceIssues.length,
      'complianceRate': ((receipts.length - complianceIssues.length) / receipts.length * 100).toStringAsFixed(1),
      'issuesSummary': issueCount,
      'receiptsWithIssues': complianceIssues.map((receiptId, issues) {
        final receipt = receipts.firstWhere((r) => r.id == receiptId);
        return MapEntry(receiptId, {
          'vendor': receipt.vendorName,
          'date': receipt.date.toIso8601String(),
          'amount': receipt.total,
          'category': _categorizationService.getCategoryName(receipt.category),
          'issues': issues,
        });
      }),
      'recommendations': _generateComplianceRecommendations(issueCount),
    };
  }

  List<String> _generateComplianceRecommendations(Map<String, int> issueCount) {
    final recommendations = <String>[];
    
    if (issueCount.containsKey('Missing receipt number')) {
      recommendations.add('Ensure all receipts have visible receipt numbers for audit trail');
    }
    
    if (issueCount.containsKey('Meal expense exceeds reasonable amount (\$200)')) {
      recommendations.add('Review meal expenses over \$200 and ensure they have proper business justification');
    }
    
    if (issueCount.containsKey('Tax calculation may be incorrect')) {
      recommendations.add('Verify tax calculations match provincial rates and receipt totals');
    }
    
    if (issueCount.containsKey('Requires manual categorization review')) {
      recommendations.add('Review and properly categorize expenses marked as "Other"');
    }
    
    if (issueCount.containsKey('Weekend transaction - may need business justification')) {
      recommendations.add('Document business purpose for weekend transactions');
    }
    
    return recommendations;
  }

  // Generate accountant-ready package
  Map<String, dynamic> generateAccountantPackage(List<ExpenseReceipt> receipts, int year) {
    return {
      'businessSummary': generateAnnualBusinessSummary(receipts, year),
      'quarterlyReports': [1, 2, 3, 4].map((quarter) => 
        generateQuarterlyTaxReport(receipts, year, quarter)
      ).toList(),
      'complianceReport': generateComplianceReport(receipts),
      'receiptImages': receipts.map((receipt) => receipt.imagePath).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
      'totalReceipts': receipts.length,
      'year': year,
    };
  }
}