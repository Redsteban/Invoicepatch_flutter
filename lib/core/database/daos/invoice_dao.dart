import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/invoices_table.dart';
import '../tables/invoice_line_items_table.dart';
import 'package:invoicepatch_contractor/shared/models/enums/invoice_status.dart';

part 'invoice_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceLineItems])
class InvoiceDao extends DatabaseAccessor<AppDatabase> with _$InvoiceDaoMixin {
  InvoiceDao(AppDatabase db) : super(db);

  // Basic CRUD operations
  Future<List<Invoice>> getAllInvoices() => 
    (select(invoices)..orderBy([(i) => OrderingTerm.desc(i.issueDate)])).get();
  
  Future<Invoice?> getInvoiceById(String id) => 
    (select(invoices)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) => 
    (select(invoices)..where((i) => i.invoiceNumber.equals(invoiceNumber))).getSingleOrNull();

  // Invoice-specific queries
  Future<List<Invoice>> getInvoicesByStatus(InvoiceStatus status) => 
    (select(invoices)
      ..where((i) => i.status.equals(status.toString().split('.').last))
      ..orderBy([(i) => OrderingTerm.desc(i.issueDate)])).get();

  Future<List<Invoice>> getInvoicesByClient(String clientId) => 
    (select(invoices)
      ..where((i) => i.clientId.equals(clientId))
      ..orderBy([(i) => OrderingTerm.desc(i.issueDate)])).get();

  Future<List<Invoice>> getOverdueInvoices() async {
    final now = DateTime.now();
    return (select(invoices)
      ..where((i) => 
        i.dueDate.isSmallerThanValue(now) & 
        i.status.equals('sent'))
      ..orderBy([(i) => OrderingTerm.asc(i.dueDate)])).get();
  }

  Future<List<Invoice>> getInvoicesForDateRange(DateTime start, DateTime end) => 
    (select(invoices)
      ..where((i) => 
        i.issueDate.isBetweenValues(start, end))
      ..orderBy([(i) => OrderingTerm.desc(i.issueDate)])).get();

  Future<double> getTotalReceivables() async {
    final unpaidInvoices = await (select(invoices)..where((i) => 
      i.status.equals('sent') | i.status.equals('overdue'))).get();
    double total = 0.0;
    for (final invoice in unpaidInvoices) {
      total += invoice.totalAmount;
    }
    return total;
  }

  Future<String> generateInvoiceNumber() async {
    final year = DateTime.now().year;
    final prefix = 'INV- $year-';
    
    final lastInvoice = await (select(invoices)
      ..where((i) => i.invoiceNumber.like(' $prefix%'))
      ..orderBy([(i) => OrderingTerm.desc(i.invoiceNumber)])
      ..limit(1)).getSingleOrNull();
    
    int nextNumber = 1;
    if (lastInvoice != null) {
      final numberPart = lastInvoice.invoiceNumber.split('-').last;
      nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
    }
    
    return ' $prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  // Line Items operations
  Future<List<InvoiceLineItem>> getLineItemsByInvoice(String invoiceId) => 
    (select(invoiceLineItems)
      ..where((li) => li.invoiceId.equals(invoiceId))
      ..orderBy([(li) => OrderingTerm.asc(li.sortOrder)])).get();

  Future<int> createInvoice(InvoicesCompanion invoice) => 
    into(invoices).insert(invoice);

  Future<int> createLineItem(InvoiceLineItemsCompanion lineItem) => 
    into(invoiceLineItems).insert(lineItem);

  Future<bool> updateInvoice(Invoice invoice) => update(invoices).replace(invoice);

  Future<int> updateInvoiceStatus(String id, InvoiceStatus status) => 
    (update(invoices)..where((i) => i.id.equals(id)))
      .write(InvoicesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> deleteInvoice(String id) async {
    // Delete line items first
    await (delete(invoiceLineItems)..where((li) => li.invoiceId.equals(id))).go();
    // Then delete invoice
    return (delete(invoices)..where((i) => i.id.equals(id))).go();
  }
} 