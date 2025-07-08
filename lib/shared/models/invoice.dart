import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/enums/invoice_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/payment_terms.dart';
import 'package:invoicepatch_contractor/shared/models/enums/expense_category.dart';

class Invoice extends Equatable {
  final String id;
  final String clientId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final PaymentTerms paymentTerms;
  final List<InvoiceLineItem> lineItems;
  final Map<ExpenseCategory, double> expenses;
  final double subtotal;
  final double taxAmount; // Canadian GST/HST
  final double totalAmount;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.clientId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.paymentTerms,
    required this.lineItems,
    required this.expenses,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Canadian tax calculation methods
  double calculateTax(String province) {
    // GST/HST rates by province
    const taxRates = {
      'AB': 0.05, 'BC': 0.05, 'MB': 0.05, 'NB': 0.15, 'NL': 0.15, 'NT': 0.05,
      'NS': 0.15, 'NU': 0.05, 'ON': 0.13, 'PE': 0.15, 'QC': 0.05, 'SK': 0.05, 'YT': 0.05
    };
    final rate = taxRates[province] ?? 0.05;
    return subtotal * rate;
  }
  
  double get grandTotal => subtotal + taxAmount;

  Invoice copyWith({
    String? id,
    String? clientId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    PaymentTerms? paymentTerms,
    List<InvoiceLineItem>? lineItems,
    Map<ExpenseCategory, double>? expenses,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    InvoiceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      lineItems: lineItems ?? this.lineItems,
      expenses: expenses ?? this.expenses,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, clientId, invoiceNumber, issueDate, dueDate, paymentTerms, lineItems, expenses, subtotal, taxAmount, totalAmount, status, notes, createdAt, updatedAt
  ];
}

class InvoiceLineItem extends Equatable {
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  
  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
  });
  
  @override
  List<Object> get props => [description, quantity, rate, amount];
} 