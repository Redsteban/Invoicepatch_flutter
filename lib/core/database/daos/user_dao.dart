import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // Basic CRUD operations
  Future<List<User>> getAllUsers() => select(users).get();
  
  Future<User?> getUserById(String id) => 
    (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
    
  Future<User?> getUserByEmail(String email) => 
    (select(users)..where((u) => u.email.equals(email))).getSingleOrNull();

  Future<int> createUser(UsersCompanion user) => 
    into(users).insert(user);

  Future<bool> updateUser(User user) => update(users).replace(user);

  Future<int> deleteUser(String id) => 
    (delete(users)..where((u) => u.id.equals(id))).go();
} 