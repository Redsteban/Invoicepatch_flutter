import 'package:drift/drift.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/shared/models/enums/log_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/invoice_status.dart';
import 'package:invoicepatch_contractor/shared/models/enums/payment_terms.dart';

class BillingMethodConverter extends TypeConverter<BillingMethod, String> {
  const BillingMethodConverter();

  @override
  BillingMethod fromSql(String fromDb) {
    return BillingMethod.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(BillingMethod value) {
    return value.toString().split('.').last;
  }
}

class LogStatusConverter extends TypeConverter<LogStatus, String> {
  const LogStatusConverter();

  @override
  LogStatus fromSql(String fromDb) {
    return LogStatus.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(LogStatus value) {
    return value.toString().split('.').last;
  }
}

class InvoiceStatusConverter extends TypeConverter<InvoiceStatus, String> {
  const InvoiceStatusConverter();

  @override
  InvoiceStatus fromSql(String fromDb) {
    return InvoiceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(InvoiceStatus value) {
    return value.toString().split('.').last;
  }
}

class PaymentTermsConverter extends TypeConverter<PaymentTerms, String> {
  const PaymentTermsConverter();

  @override
  PaymentTerms fromSql(String fromDb) {
    return PaymentTerms.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(PaymentTerms value) {
    return value.toString().split('.').last;
  }
} 