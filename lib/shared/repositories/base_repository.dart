abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id);
} 