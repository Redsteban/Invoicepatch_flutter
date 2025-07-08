import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  meals,
  travel,
  office,
  equipment,
  utilities,
  professional,
  marketing,
  maintenance,
  fuel,
  insurance,
  other,
}

enum TaxType {
  gst, // 5% GST
  hst, // HST varies by province
  pst, // Provincial sales tax
  noTax,
}

class ExpenseReceipt extends Equatable {
  final String id;
  final String imagePath;
  final String vendorName;
  final DateTime date;
  final double subtotal;
  final double taxAmount;
  final double total;
  final TaxType taxType;
  final double taxRate;
  final String province;
  final ExpenseCategory category;
  final String description;
  final String receiptNumber;
  final bool isDeductible;
  final Map<String, dynamic> rawOcrData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseReceipt({
    required this.id,
    required this.imagePath,
    required this.vendorName,
    required this.date,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.taxType,
    required this.taxRate,
    required this.province,
    required this.category,
    required this.description,
    required this.receiptNumber,
    required this.isDeductible,
    required this.rawOcrData,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    imagePath,
    vendorName,
    date,
    subtotal,
    taxAmount,
    total,
    taxType,
    taxRate,
    province,
    category,
    description,
    receiptNumber,
    isDeductible,
    rawOcrData,
    createdAt,
    updatedAt,
  ];

  ExpenseReceipt copyWith({
    String? id,
    String? imagePath,
    String? vendorName,
    DateTime? date,
    double? subtotal,
    double? taxAmount,
    double? total,
    TaxType? taxType,
    double? taxRate,
    String? province,
    ExpenseCategory? category,
    String? description,
    String? receiptNumber,
    bool? isDeductible,
    Map<String, dynamic>? rawOcrData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseReceipt(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      vendorName: vendorName ?? this.vendorName,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      taxType: taxType ?? this.taxType,
      taxRate: taxRate ?? this.taxRate,
      province: province ?? this.province,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      isDeductible: isDeductible ?? this.isDeductible,
      rawOcrData: rawOcrData ?? this.rawOcrData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CanadianTaxRates {
  static const Map<String, double> gstRate = {
    'AB': 0.05, // Alberta
    'BC': 0.05, // British Columbia
    'MB': 0.05, // Manitoba
    'NB': 0.05, // New Brunswick (uses HST but calculated as GST + PST)
    'NL': 0.05, // Newfoundland and Labrador (uses HST)
    'NT': 0.05, // Northwest Territories
    'NS': 0.05, // Nova Scotia (uses HST)
    'NU': 0.05, // Nunavut
    'ON': 0.05, // Ontario (uses HST)
    'PE': 0.05, // Prince Edward Island (uses HST)
    'QC': 0.05, // Quebec
    'SK': 0.05, // Saskatchewan
    'YT': 0.05, // Yukon
  };

  static const Map<String, double> hstRate = {
    'NB': 0.15, // New Brunswick HST
    'NL': 0.15, // Newfoundland and Labrador HST
    'NS': 0.15, // Nova Scotia HST
    'ON': 0.13, // Ontario HST
    'PE': 0.15, // Prince Edward Island HST
  };

  static const Map<String, double> pstRate = {
    'BC': 0.07, // British Columbia PST
    'MB': 0.07, // Manitoba PST
    'QC': 0.09975, // Quebec QST
    'SK': 0.06, // Saskatchewan PST
  };

  static TaxType getTaxType(String province) {
    if (hstRate.containsKey(province)) {
      return TaxType.hst;
    } else if (pstRate.containsKey(province)) {
      return TaxType.pst;
    }
    return TaxType.gst;
  }

  static double getTaxRate(String province) {
    if (hstRate.containsKey(province)) {
      return hstRate[province]!;
    } else if (pstRate.containsKey(province)) {
      return gstRate[province]! + pstRate[province]!;
    }
    return gstRate[province] ?? 0.05;
  }
}