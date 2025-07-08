import 'package:invoicepatch_contractor/features/expense_tracking/models/expense_receipt.dart';

class ExpenseCategorizationService {
  static final ExpenseCategorizationService _instance = ExpenseCategorizationService._internal();
  factory ExpenseCategorizationService() => _instance;
  ExpenseCategorizationService._internal();

  // Canadian Revenue Agency (CRA) approved business expense categories
  final Map<ExpenseCategory, List<String>> _categoryKeywords = {
    ExpenseCategory.meals: [
      'restaurant', 'food', 'cafe', 'coffee', 'lunch', 'dinner', 'breakfast',
      'mcdonalds', 'subway', 'starbucks', 'tim hortons', 'pizza', 'bistro',
      'catering', 'uber eats', 'skip the dishes', 'doordash', 'grubhub'
    ],
    ExpenseCategory.travel: [
      'hotel', 'motel', 'flight', 'airline', 'taxi', 'uber', 'lyft',
      'car rental', 'gas station', 'parking', 'train', 'bus', 'ferry',
      'airbnb', 'booking.com', 'expedia', 'travel', 'accommodation'
    ],
    ExpenseCategory.office: [
      'office supplies', 'staples', 'paper', 'pen', 'printer', 'ink',
      'computer', 'software', 'microsoft', 'adobe', 'office depot',
      'costco', 'walmart', 'amazon', 'stationery', 'filing', 'desk'
    ],
    ExpenseCategory.equipment: [
      'tools', 'machinery', 'equipment', 'hardware', 'home depot',
      'canadian tire', 'lowes', 'rona', 'construction', 'safety',
      'hard hat', 'boots', 'gloves', 'ladder', 'drill', 'saw'
    ],
    ExpenseCategory.utilities: [
      'hydro', 'electricity', 'gas', 'water', 'internet', 'phone',
      'bell', 'rogers', 'telus', 'shaw', 'videotron', 'utility',
      'heating', 'cooling', 'energy', 'bc hydro', 'ontario hydro'
    ],
    ExpenseCategory.professional: [
      'accountant', 'lawyer', 'consultant', 'training', 'course',
      'seminar', 'conference', 'certification', 'membership',
      'professional development', 'cpa', 'legal', 'audit'
    ],
    ExpenseCategory.marketing: [
      'advertising', 'marketing', 'promotion', 'website', 'social media',
      'google ads', 'facebook', 'instagram', 'linkedin', 'branding',
      'design', 'printing', 'business cards', 'flyers', 'banners'
    ],
    ExpenseCategory.maintenance: [
      'repair', 'maintenance', 'cleaning', 'janitorial', 'fix',
      'service', 'warranty', 'parts', 'replacement', 'upkeep'
    ],
    ExpenseCategory.fuel: [
      'gas', 'fuel', 'diesel', 'petrol', 'shell', 'esso', 'chevron',
      'petro canada', 'husky', 'mohawk', 'gasoline', 'vehicle fuel'
    ],
    ExpenseCategory.insurance: [
      'insurance', 'liability', 'coverage', 'policy', 'premium',
      'deductible', 'claim', 'broker', 'auto insurance', 'business insurance'
    ],
  };

  // CRA deduction percentages and rules
  final Map<ExpenseCategory, double> _deductionPercentages = {
    ExpenseCategory.meals: 0.50, // 50% deductible for meals
    ExpenseCategory.travel: 1.0,  // 100% deductible for business travel
    ExpenseCategory.office: 1.0,  // 100% deductible for office supplies
    ExpenseCategory.equipment: 1.0, // 100% deductible (subject to depreciation)
    ExpenseCategory.utilities: 1.0, // 100% deductible for business portion
    ExpenseCategory.professional: 1.0, // 100% deductible
    ExpenseCategory.marketing: 1.0, // 100% deductible
    ExpenseCategory.maintenance: 1.0, // 100% deductible
    ExpenseCategory.fuel: 1.0, // 100% deductible for business use
    ExpenseCategory.insurance: 1.0, // 100% deductible for business portion
    ExpenseCategory.other: 1.0, // Review required
  };

  ExpenseCategory categorizeExpense(String vendorName, String description, List<Map<String, dynamic>> items) {
    final allText = '$vendorName $description ${items.map((item) => item['description']).join(' ')}';
    final normalizedText = allText.toLowerCase();

    int maxMatches = 0;
    ExpenseCategory bestCategory = ExpenseCategory.other;

    for (final category in _categoryKeywords.keys) {
      final keywords = _categoryKeywords[category]!;
      int matches = 0;

      for (final keyword in keywords) {
        if (normalizedText.contains(keyword)) {
          matches++;
        }
      }

      if (matches > maxMatches) {
        maxMatches = matches;
        bestCategory = category;
      }
    }

    return bestCategory;
  }

  bool isDeductible(ExpenseCategory category, double amount) {
    // Basic deductibility rules - can be expanded
    switch (category) {
      case ExpenseCategory.meals:
        // Meals must be for business purposes and within reasonable limits
        return amount <= 200.0; // Example limit
      case ExpenseCategory.travel:
        // Travel expenses are generally deductible if for business
        return true;
      case ExpenseCategory.office:
        // Office supplies are generally deductible
        return true;
      case ExpenseCategory.equipment:
        // Equipment may need to be depreciated over time
        return true;
      case ExpenseCategory.utilities:
        // Business portion of utilities is deductible
        return true;
      case ExpenseCategory.professional:
        // Professional development is generally deductible
        return true;
      case ExpenseCategory.marketing:
        // Marketing expenses are generally deductible
        return true;
      case ExpenseCategory.maintenance:
        // Maintenance and repairs are generally deductible
        return true;
      case ExpenseCategory.fuel:
        // Business fuel is deductible
        return true;
      case ExpenseCategory.insurance:
        // Business insurance is deductible
        return true;
      case ExpenseCategory.other:
        // Requires manual review
        return false;
    }
  }

  double getDeductionPercentage(ExpenseCategory category) {
    return _deductionPercentages[category] ?? 1.0;
  }

  String getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.meals:
        return 'Meals & Entertainment';
      case ExpenseCategory.travel:
        return 'Travel Expenses';
      case ExpenseCategory.office:
        return 'Office Supplies';
      case ExpenseCategory.equipment:
        return 'Equipment & Tools';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.professional:
        return 'Professional Services';
      case ExpenseCategory.marketing:
        return 'Marketing & Advertising';
      case ExpenseCategory.maintenance:
        return 'Maintenance & Repairs';
      case ExpenseCategory.fuel:
        return 'Vehicle Fuel';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.other:
        return 'Other Expenses';
    }
  }

  String getCategoryDescription(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.meals:
        return 'Business meals and entertainment (50% deductible)';
      case ExpenseCategory.travel:
        return 'Business travel expenses (100% deductible)';
      case ExpenseCategory.office:
        return 'Office supplies and materials (100% deductible)';
      case ExpenseCategory.equipment:
        return 'Tools and equipment (may require depreciation)';
      case ExpenseCategory.utilities:
        return 'Business utilities (100% of business portion)';
      case ExpenseCategory.professional:
        return 'Professional development and services (100% deductible)';
      case ExpenseCategory.marketing:
        return 'Marketing and advertising costs (100% deductible)';
      case ExpenseCategory.maintenance:
        return 'Maintenance and repair costs (100% deductible)';
      case ExpenseCategory.fuel:
        return 'Vehicle fuel for business use (100% deductible)';
      case ExpenseCategory.insurance:
        return 'Business insurance premiums (100% deductible)';
      case ExpenseCategory.other:
        return 'Other business expenses (requires review)';
    }
  }

  List<String> getCRARequirements(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.meals:
        return [
          'Must be for business purposes',
          'Receipt must show itemized details',
          'Must record business purpose and attendees',
          'Only 50% is deductible',
          'Must be reasonable in the circumstances'
        ];
      case ExpenseCategory.travel:
        return [
          'Must be for business purposes',
          'Keep detailed travel log',
          'Receipts for accommodation and transportation',
          'Record business purpose and duration',
          'Meals during travel follow meal rules'
        ];
      case ExpenseCategory.office:
        return [
          'Must be used for business purposes',
          'Keep receipts for purchases over \$75',
          'Maintain inventory of supplies',
          'Personal use items are not deductible'
        ];
      case ExpenseCategory.equipment:
        return [
          'Equipment over \$500 may need to be depreciated',
          'Must be used primarily for business',
          'Keep purchase receipts and warranties',
          'Track depreciation schedule',
          'Personal use reduces deduction'
        ];
      case ExpenseCategory.utilities:
        return [
          'Only business portion is deductible',
          'Home office must be principal workplace',
          'Calculate business use percentage',
          'Keep utility bills and usage records'
        ];
      case ExpenseCategory.professional:
        return [
          'Must be directly related to business',
          'Keep certificates and receipts',
          'Professional memberships are deductible',
          'Training must improve business skills'
        ];
      case ExpenseCategory.marketing:
        return [
          'Must be for business promotion',
          'Keep invoices and proof of publication',
          'Website and social media costs included',
          'Must be reasonable for business size'
        ];
      case ExpenseCategory.maintenance:
        return [
          'Must be for business property/equipment',
          'Keep repair receipts and invoices',
          'Capital improvements may need depreciation',
          'Regular maintenance is fully deductible'
        ];
      case ExpenseCategory.fuel:
        return [
          'Must track business vs personal use',
          'Keep fuel receipts and mileage log',
          'Only business portion is deductible',
          'Alternative: use per-km rate'
        ];
      case ExpenseCategory.insurance:
        return [
          'Must be for business purposes',
          'Keep policy documents and receipts',
          'Personal insurance is not deductible',
          'Life insurance premiums generally not deductible'
        ];
      case ExpenseCategory.other:
        return [
          'Must be reasonable and necessary for business',
          'Keep detailed records and receipts',
          'Consult with accountant for complex items',
          'Personal expenses are not deductible'
        ];
    }
  }
}