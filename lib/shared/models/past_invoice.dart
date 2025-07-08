import 'package:equatable/equatable.dart';

class PastInvoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final DateTime invoiceDate;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double totalAmount;
  final double gstAmount;
  final double subsistenceAmount;
  final String? pdfUrl;
  final String? imageUrl;
  final InvoiceSource source;
  final DateTime uploadedAt;

  const PastInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.invoiceDate,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.totalAmount,
    required this.gstAmount,
    required this.subsistenceAmount,
    this.pdfUrl,
    this.imageUrl,
    required this.source,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    clientName,
    invoiceDate,
    payPeriodStart,
    payPeriodEnd,
    totalAmount,
    gstAmount,
    subsistenceAmount,
    pdfUrl,
    imageUrl,
    source,
    uploadedAt,
  ];
}

enum InvoiceSource { manual, uploaded, generated } 