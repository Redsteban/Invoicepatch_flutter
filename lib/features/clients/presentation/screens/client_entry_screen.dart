import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_event.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_state.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';

const emeraldGreen = Color(0xFF50C878);

class ClientEntryScreen extends StatefulWidget {
  final Client? existingClient; // For editing existing clients

  const ClientEntryScreen({
    Key? key,
    this.existingClient,
  }) : super(key: key);

  @override
  State<ClientEntryScreen> createState() => _ClientEntryScreenState();
}

class _ClientEntryScreenState extends State<ClientEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info Controllers
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Address Controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  // Billing Controllers
  final _hourlyRateController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  final _regularKmsRateController = TextEditingController();
  final _towingKmsRateController = TextEditingController();
  final _truckRateController = TextEditingController();
  final _subsistenceRateController = TextEditingController();

  // Form State
  String _selectedProvince = 'Alberta';
  BillingMethod _primaryBillingMethod = BillingMethod.hourly;

  final List<String> _canadianProvinces = [
    'Alberta',
    'British Columbia', 
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Northwest Territories',
    'Nova Scotia',
    'Nunavut',
    'Ontario',
    'Prince Edward Island',
    'Quebec',
    'Saskatchewan',
    'Yukon',
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing existing client, populate fields
    if (widget.existingClient != null) {
      _populateFieldsFromExisting();
    }
  }

  void _populateFieldsFromExisting() {
    final client = widget.existingClient!;
    
    _nameController.text = client.name;
    _companyController.text = client.company;
    _emailController.text = client.email;
    _phoneController.text = client.phone ?? '';
    
    _streetController.text = client.address.street;
    _cityController.text = client.address.city;
    _selectedProvince = client.address.province;
    _postalCodeController.text = client.address.postalCode;
    
    _primaryBillingMethod = client.billingPreferences.primaryMethod;
    
    if (client.billingPreferences.defaultHourlyRate != null) {
      _hourlyRateController.text = client.billingPreferences.defaultHourlyRate.toString();
    }
    if (client.billingPreferences.defaultDayRate != null) {
      _dayRateController.text = client.billingPreferences.defaultDayRate.toString();
    }
    if (client.billingPreferences.defaultOvertimeRate != null) {
      _overtimeRateController.text = client.billingPreferences.defaultOvertimeRate.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _hourlyRateController.dispose();
    _dayRateController.dispose();
    _overtimeRateController.dispose();
    _regularKmsRateController.dispose();
    _towingKmsRateController.dispose();
    _truckRateController.dispose();
    _subsistenceRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.existingClient != null ? 'Edit Client' : 'New Client'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ClientFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Card
                      _buildBasicInfoCard(),
                      const SizedBox(height: 16),

                      // Address Information Card
                      _buildAddressCard(),
                      const SizedBox(height: 16),

                      // Billing Preferences Card
                      _buildBillingPreferencesCard(),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<ClientBloc, ClientState>(
                        builder: (context, state) {
                          final isLoading = state is ClientSaving;
                          return ElevatedButton(
                            onPressed: isLoading ? null : _saveClient,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: emeraldGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(widget.existingClient != null ? 'Update Client' : 'Save Client'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'John Smith',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter contact name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'ABC Construction Ltd.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'john@abcconstruction.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address';
                }
                if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: '(403) 555-0123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                hintText: '123 Main Street',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter street address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Calgary',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvince,
                    decoration: const InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(),
                    ),
                    items: _canadianProvinces.map((province) {
                      return DropdownMenuItem(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvince = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                hintText: 'T2P 1J9',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter postal code';
                }
                if (!RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$').hasMatch(value.trim())) {
                  return 'Please enter a valid Canadian postal code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingPreferencesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Primary Billing Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...BillingMethod.values.map((method) {
              return RadioListTile<BillingMethod>(
                title: Text(_getBillingMethodTitle(method)),
                subtitle: Text(_getBillingMethodDescription(method)),
                value: method,
                groupValue: _primaryBillingMethod,
                onChanged: (value) {
                  setState(() {
                    _primaryBillingMethod = value!;
                  });
                },
                activeColor: emeraldGreen,
              );
            }).toList(),

            const SizedBox(height: 24),

            const Text(
              'Default Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (_primaryBillingMethod == BillingMethod.hourly || _primaryBillingMethod == BillingMethod.mixed) ...[
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Default Hourly Rate',
                  hintText: '75.00',
                  prefixText: '\$',
                  suffixText: '/hour',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Please enter a valid rate';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _overtimeRateController,
                decoration: const InputDecoration(
                  labelText: 'Overtime Rate (Optional)',
                  hintText: '112.50',
                  prefixText: '\$',
                  suffixText: '/hour',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Please enter a valid rate';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_primaryBillingMethod == BillingMethod.dayRate || _primaryBillingMethod == BillingMethod.mixed) ...[
              TextFormField(
                controller: _dayRateController,
                decoration: const InputDecoration(
                  labelText: 'Default Day Rate',
                  hintText: '600.00',
                  prefixText: '\$',
                  suffixText: '/day',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Please enter a valid rate';
                    }
                  }
                  return null;
                },
              ),
            ],

            // Additional Rates
            TextFormField(
              controller: _regularKmsRateController,
              decoration: const InputDecoration(
                labelText: 'Regular KMs Rate (Optional)',
                hintText: '0.75',
                prefixText: '\$',
                suffixText: '/km',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: _rateValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _towingKmsRateController,
              decoration: const InputDecoration(
                labelText: 'Towing KMs Rate (Optional)',
                hintText: '1.00',
                prefixText: '\$',
                suffixText: '/km',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: _rateValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _truckRateController,
              decoration: const InputDecoration(
                labelText: 'Truck Rate (Optional)',
                hintText: '150.00',
                prefixText: '\$',
                suffixText: '/day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: _rateValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subsistenceRateController,
              decoration: const InputDecoration(
                labelText: 'Subsistence Rate (Optional)',
                hintText: '45.00',
                prefixText: '\$',
                suffixText: '/day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: _rateValidator,
            ),
          ],
        ),
      ),
    );
  }

  String _getBillingMethodTitle(BillingMethod method) {
    switch (method) {
      case BillingMethod.hourly:
        return 'Hourly Billing';
      case BillingMethod.dayRate:
        return 'Day Rate Billing';
      case BillingMethod.mixed:
        return 'Mixed Billing';
    }
  }

  String _getBillingMethodDescription(BillingMethod method) {
    switch (method) {
      case BillingMethod.hourly:
        return 'Bill by the hour with overtime support';
      case BillingMethod.dayRate:
        return 'Fixed daily rate for full or partial days';
      case BillingMethod.mixed:
        return 'Day rate + hourly overtime';
    }
  }

  String? _rateValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      final rate = double.tryParse(value);
      if (rate == null || rate <= 0) {
        return 'Please enter a valid rate';
      }
    }
    return null;
  }

  void _saveClient() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final address = Address(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      province: _selectedProvince,
      postalCode: _postalCodeController.text.trim().toUpperCase(),
      country: 'Canada',
    );

    final billingPreferences = BillingPreferences(
      primaryMethod: _primaryBillingMethod,
      defaultHourlyRate: _hourlyRateController.text.isNotEmpty 
          ? double.tryParse(_hourlyRateController.text) 
          : null,
      defaultDayRate: _dayRateController.text.isNotEmpty 
          ? double.tryParse(_dayRateController.text) 
          : null,
      defaultOvertimeRate: _overtimeRateController.text.isNotEmpty 
          ? double.tryParse(_overtimeRateController.text) 
          : null,
      clientSpecificRates: {
        if (_regularKmsRateController.text.isNotEmpty)
          'regular_kms': double.parse(_regularKmsRateController.text),
        if (_towingKmsRateController.text.isNotEmpty)
          'towing_kms': double.parse(_towingKmsRateController.text),
        if (_truckRateController.text.isNotEmpty)
          'truck_rate': double.parse(_truckRateController.text),
        if (_subsistenceRateController.text.isNotEmpty)
          'subsistence_rate': double.parse(_subsistenceRateController.text),
      },
    );

    final client = Client(
      id: widget.existingClient?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: address,
      billingPreferences: billingPreferences,
      rateHistory: widget.existingClient?.rateHistory ?? {},
      createdAt: widget.existingClient?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.existingClient != null) {
      context.read<ClientBloc>().add(ClientUpdateRequested(client: client));
    } else {
      context.read<ClientBloc>().add(ClientCreateRequested(client: client));
    }
  }
} 