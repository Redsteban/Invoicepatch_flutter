class InvoiceData {
  final String contractorName;
  final String contractorAddress;
  final String contractorCity;
  final String contractorProvince;
  final String contractorPostal;
  final String contractorPhone;
  final String contractorEmail;
  final String? gstNumber;
  final String clientName;
  final String clientAddress;
  final String clientCity;
  final String clientProvince;
  final String clientPostal;
  final String clientEmail;
  final String invoiceNumber;
  final String invoiceDate;
  final String dueDate;
  final String? projectDescription;
  final List<LineItem> lineItems;
  final String? notes;
  final String? paymentTerms;

  InvoiceData({
    required this.contractorName,
    required this.contractorAddress,
    required this.contractorCity,
    required this.contractorProvince,
    required this.contractorPostal,
    required this.contractorPhone,
    required this.contractorEmail,
    this.gstNumber,
    required this.clientName,
    required this.clientAddress,
    required this.clientCity,
    required this.clientProvince,
    required this.clientPostal,
    required this.clientEmail,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    this.projectDescription,
    required this.lineItems,
    this.notes,
    this.paymentTerms,
  });
}

class LineItem {
  final String id;
  final String description;
  final String? category;
  final int quantity;
  final String? unit;
  final double rate;
  final double amount;
  final String location;
  final bool worked;
  final double kmsRegular;
  final double kmsTowing;
  final double kmsRegRate;
  final double kmsTowRate;
  final double truckRate;
  final double otherCharges;

  LineItem({
    required this.id,
    required this.description,
    this.category,
    required this.quantity,
    this.unit,
    required this.rate,
    required this.amount,
    this.location = '',
    this.worked = true,
    this.kmsRegular = 0,
    this.kmsTowing = 0,
    this.kmsRegRate = 0,
    this.kmsTowRate = 0,
    this.truckRate = 0,
    this.otherCharges = 0,
  });
}