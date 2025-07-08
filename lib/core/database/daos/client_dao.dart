import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/clients_table.dart';

part 'client_dao.g.dart';

@DriftAccessor(tables: [Clients])
class ClientDao extends DatabaseAccessor<AppDatabase> with _$ClientDaoMixin {
  ClientDao(AppDatabase db) : super(db);

  // Basic CRUD operations
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Future<Client?> getClientById(String id) => 
    (select(clients)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Client>> getActiveClients() => 
    (select(clients)..orderBy([(c) => OrderingTerm.desc(c.updatedAt)])).get();

  Future<List<Client>> searchClients(String query) => 
    (select(clients)..where((c) => 
      c.name.contains(query) | c.company.contains(query))).get();

  Future<int> createClient(ClientsCompanion client) => 
    into(clients).insert(client);

  Future<bool> updateClient(Client client) => update(clients).replace(client);

  Future<int> deleteClient(String id) => 
    (delete(clients)..where((c) => c.id.equals(id))).go();
} 