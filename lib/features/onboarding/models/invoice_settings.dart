class InvoiceSettings {
  final String invoiceNumberPrefix;
  final String paymentTerms;
  final String? bankInfo;
  final String? companyLogoPath;

  InvoiceSettings({
    required this.invoiceNumberPrefix,
    required this.paymentTerms,
    this.bankInfo,
    this.companyLogoPath,
  });
} 