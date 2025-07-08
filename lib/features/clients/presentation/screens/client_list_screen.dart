import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_event.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_state.dart';
import 'package:invoicepatch_contractor/features/clients/presentation/screens/client_entry_screen.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:auto_route/auto_route.dart';
import 'package:invoicepatch_contractor/core/routing/app_router.dart';

const emeraldGreen = Color(0xFF50C878);

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load clients when screen initializes
    context.read<ClientBloc>().add(const ClientLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewClient,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ClientBloc>().add(const ClientLoadRequested());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (query) {
                setState(() {});
                if (query.trim().isNotEmpty) {
                  context.read<ClientBloc>().add(ClientSearchRequested(query: query));
                } else {
                  context.read<ClientBloc>().add(const ClientLoadRequested());
                }
              },
            ),
          ),

          // Client List
          Expanded(
            child: BlocConsumer<ClientBloc, ClientState>(
              listener: (context, state) {
                if (state is ClientFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ClientDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is ClientOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ClientLoaded) {
                  if (state.clients.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildClientList(state.clients);
                } else if (state is ClientSearchResults) {
                  if (state.clients.isEmpty) {
                    return _buildNoSearchResults(state.query);
                  }
                  return _buildClientList(state.clients, isSearchResult: true);
                } else if (state is ClientFailure) {
                  return _buildErrorState(state.message);
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewClient,
        backgroundColor: emeraldGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClientList(List<Client> clients, {bool isSearchResult = false}) {
    return Column(
      children: [
        // Results Summary
        if (isSearchResult)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.search, color: emeraldGreen),
                const SizedBox(width: 8),
                Text(
                  '${clients.length} client${clients.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    color: emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Client Count Summary
        if (!isSearchResult)
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              color: emeraldGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: emeraldGreen, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Clients',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${clients.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: emeraldGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _addNewClient,
                      child: const Text('Add New'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Client List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return _buildClientCard(client);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _editClient(client),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          client.company,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBillingMethodChip(client.billingPreferences.primaryMethod),
                ],
              ),

              const SizedBox(height: 12),

              // Contact Info Row
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      client.email,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (client.phone != null) ...[
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      client.phone!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Address Row
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${client.address.city}, ${client.address.province}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              // Rates Row
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (client.billingPreferences.defaultHourlyRate != null)
                    _buildRateChip(
                      icon: Icons.schedule,
                      label: '${client.billingPreferences.defaultHourlyRate!.toStringAsFixed(0)}/hr',
                      color: Colors.green,
                    ),
                  if (client.billingPreferences.defaultDayRate != null)
                    _buildRateChip(
                      icon: Icons.today,
                      label: '${client.billingPreferences.defaultDayRate!.toStringAsFixed(0)}/day',
                      color: Colors.orange,
                    ),
                  if (client.billingPreferences.defaultOvertimeRate != null)
                    _buildRateChip(
                      icon: Icons.timer,
                      label: '${client.billingPreferences.defaultOvertimeRate!.toStringAsFixed(0)}/hr OT',
                      color: Colors.purple,
                    ),
                ],
              ),

              // Action Buttons Row
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _editClient(client),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateRate(client),
                    icon: const Icon(Icons.attach_money, size: 16),
                    label: const Text('Rate'),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteClient(client),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingMethodChip(BillingMethod method) {
    String label;
    Color color;

    switch (method) {
      case BillingMethod.hourly:
        label = 'Hourly';
        color = Colors.green;
        break;
      case BillingMethod.dayRate:
        label = 'Day Rate';
        color = Colors.orange;
        break;
      case BillingMethod.mixed:
        label = 'Mixed';
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRateChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Clients Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first client to begin tracking work and creating invoices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewClient,
              icon: const Icon(Icons.add),
              label: const Text('Add First Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No clients found matching "$query".',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                context.read<ClientBloc>().add(const ClientLoadRequested());
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ClientBloc>().add(const ClientLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewClient() {
    context.router.push(ClientEntryRoute());
  }

  void _editClient(Client client) {
    context.router.push(ClientEntryRoute(existingClient: client));
  }

  void _deleteClient(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name} (${client.company})? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ClientBloc>().add(ClientDeleteRequested(clientId: client.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateRate(Client client) {
    final rateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Rate for ${client.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current rate: ${client.billingPreferences.defaultHourlyRate?.toStringAsFixed(2) ?? 'Not set'}'),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'New Rate',
                prefixText: '\$',
                suffixText: '/hour',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(rateController.text);
              if (newRate != null && newRate > 0) {
                Navigator.of(context).pop();
                context.read<ClientBloc>().add(
                  ClientRateUpdateRequested(
                    clientId: client.id,
                    newRate: newRate,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
} 