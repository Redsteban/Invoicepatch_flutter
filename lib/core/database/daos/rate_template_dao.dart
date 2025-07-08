import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/rate_templates_table.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';

part 'rate_template_dao.g.dart';

@DriftAccessor(tables: [RateTemplates])
class RateTemplateDao extends DatabaseAccessor<AppDatabase> with _$RateTemplateDaoMixin {
  RateTemplateDao(AppDatabase db) : super(db);

  // Basic CRUD operations
  Future<List<RateTemplate>> getAllTemplates() => 
    (select(rateTemplates)..orderBy([(rt) => OrderingTerm.asc(rt.name)])).get();
  
  Future<RateTemplate?> getTemplateById(String id) => 
    (select(rateTemplates)..where((rt) => rt.id.equals(id))).getSingleOrNull();

  // Template-specific queries
  Future<List<RateTemplate>> getActiveTemplates() => 
    (select(rateTemplates)
      ..where((rt) => rt.isActive.equals(true))
      ..orderBy([(rt) => OrderingTerm.asc(rt.name)])).get();

  Future<RateTemplate?> getDefaultTemplate() => 
    (select(rateTemplates)..where((rt) => 
      rt.isDefault.equals(true) & rt.isActive.equals(true)))
      .getSingleOrNull();

  Future<List<RateTemplate>> getTemplatesByBillingMethod(BillingMethod method) => 
    (select(rateTemplates)
      ..where((rt) => 
        rt.billingMethod.equals(method.toString().split('.').last) & 
        rt.isActive.equals(true))
      ..orderBy([(rt) => OrderingTerm.asc(rt.name)])).get();

  Future<int> createTemplate(RateTemplatesCompanion template) => 
    into(rateTemplates).insert(template);

  Future<bool> updateTemplate(RateTemplate template) => 
    update(rateTemplates).replace(template);

  Future<int> setDefaultTemplate(String id) async {
    // First, clear any existing default
    await (update(rateTemplates)..where((rt) => rt.isDefault.equals(true)))
      .write(const RateTemplatesCompanion(isDefault: Value(false)));
    
    // Then set the new default
    return (update(rateTemplates)..where((rt) => rt.id.equals(id)))
      .write(RateTemplatesCompanion(
        isDefault: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
  }

  Future<int> activateTemplate(String id) => 
    (update(rateTemplates)..where((rt) => rt.id.equals(id)))
      .write(RateTemplatesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> deactivateTemplate(String id) => 
    (update(rateTemplates)..where((rt) => rt.id.equals(id)))
      .write(RateTemplatesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> deleteTemplate(String id) => 
    (delete(rateTemplates)..where((rt) => rt.id.equals(id))).go();

  // Search templates by name
  Future<List<RateTemplate>> searchTemplates(String query) => 
    (select(rateTemplates)
      ..where((rt) => 
        rt.name.contains(query) | (rt.description.contains(query)))
      ..orderBy([(rt) => OrderingTerm.asc(rt.name)])).get();
} 