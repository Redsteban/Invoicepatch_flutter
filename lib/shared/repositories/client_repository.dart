import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/core/database/app_database.dart' as db;
import 'package:invoicepatch_contractor/core/database/daos/client_dao.dart';
import 'package:drift/drift.dart' as drift;
import 'base_repository.dart';

class ClientRepository extends BaseRepository<Client> {
  final ClientDao _clientDao;

  ClientRepository({required ClientDao clientDao})
      : _clientDao = clientDao;

  @override
  Future<List<Client>> getAll() async {
    try {
      final driftClients = await _clientDao.getAllClients();
      return driftClients.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get clients: $e');
    }
  }

  @override
  Future<Client?> getById(String id) async {
    try {
      final driftClient = await _clientDao.getClientById(id);
      return driftClient != null ? _convertFromDrift(driftClient) : null;
    } catch (e) {
      throw Exception('Failed to get client by id: $e');
    }
  }

  @override
  Future<Client> create(Client entity) async {
    try {
      final companion = _convertToCompanion(entity);
      await _clientDao.createClient(companion);
      // Return the created entity with timestamps
      return entity.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  @override
  Future<Client> update(Client entity) async {
    try {
      final updatedEntity = entity.copyWith(updatedAt: DateTime.now());
      final driftClient = _convertToDrift(updatedEntity);
      await _clientDao.updateClient(driftClient);
      return updatedEntity;
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _clientDao.deleteClient(id);
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  // Client-specific methods
  Future<List<Client>> getActiveClients() async {
    try {
      final driftClients = await _clientDao.getActiveClients();
      return driftClients.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to get active clients: $e');
    }
  }

  Future<void> updateClientRate(String clientId, double newRate) async {
    try {
      final client = await getById(clientId);
      if (client == null) {
        throw Exception('Client not found');
      }

      // Update the default hourly rate and add to rate history
      final now = DateTime.now();
      final updatedBillingPreferences = client.billingPreferences.copyWith(
        defaultHourlyRate: newRate,
      );
      
      final updatedRateHistory = Map<String, double>.from(client.rateHistory);
      updatedRateHistory[now.toIso8601String()] = newRate;

      final updatedClient = client.copyWith(
        billingPreferences: updatedBillingPreferences,
        rateHistory: updatedRateHistory,
        updatedAt: now,
      );

      await update(updatedClient);
    } catch (e) {
      throw Exception('Failed to update client rate: $e');
    }
  }

  Future<Map<String, double>> getClientRateHistory(String clientId) async {
    try {
      final client = await getById(clientId);
      return client?.rateHistory ?? {};
    } catch (e) {
      throw Exception('Failed to get client rate history: $e');
    }
  }

  Future<List<Client>> searchClients(String query) async {
    try {
      final driftClients = await _clientDao.searchClients(query);
      return driftClients.map(_convertFromDrift).toList();
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }

  // Conversion methods between Client model and Drift entities
  Client _convertFromDrift(dynamic driftClient) {
    return Client(
      id: driftClient.id,
      name: driftClient.name,
      company: driftClient.company,
      email: driftClient.email,
      phone: driftClient.phone,
      address: Address.fromMap(driftClient.address),
      billingPreferences: BillingPreferences.fromMap(driftClient.billingPreferences),
      rateHistory: Map<String, double>.from(driftClient.rateHistory),
      createdAt: driftClient.createdAt,
      updatedAt: driftClient.updatedAt,
    );
  }

  dynamic _convertToDrift(Client client) {
    // This would return the actual Drift Client entity
    // For now, we'll use the companion approach
    throw UnimplementedError('Use _convertToCompanion for updates');
  }

  dynamic _convertToCompanion(Client client) {
    return db.ClientsCompanion.insert(
      id: client.id,
      name: client.name,
      company: client.company,
      email: client.email,
      phone: drift.Value(client.phone),
      address: client.address.toMap(),
      billingPreferences: client.billingPreferences.toMap(),
      rateHistory: client.rateHistory,
      createdAt: drift.Value(client.createdAt),
      updatedAt: drift.Value(client.updatedAt),
    );
  }
} 