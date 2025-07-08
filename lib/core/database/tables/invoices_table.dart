import 'package:drift/drift.dart';
import '../converters/enum_converters.dart';
import '../converters/map_converter.dart';

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get invoiceNumber => text().unique()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get paymentTerms => text().map(const PaymentTermsConverter())();
  TextColumn get expenses => text().map(const ExpenseMapConverter())();
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real()();
  RealColumn get totalAmount => real()();
  TextColumn get status => text().map(const InvoiceStatusConverter())();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
} 