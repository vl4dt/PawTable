/// PawTable base repository interfaces.
///
/// Repositories define the contract between domain and data layers.
/// Domain layer depends on these interfaces; data layer implements them.
///
/// Usage pattern:
/// ```dart
/// abstract class PetRepository {
///   Future<List<Pet>> getPets();
///   Future<Pet?> getPet(String id);
///   Future<void> savePet(Pet pet);
///   Future<void> deletePet(String id);
/// }
///
/// class PetRepositoryImpl implements PetRepository {
///   // Implementation using Hive + SQLite + Firebase
/// }
/// ```
library;

abstract class BaseRepository {
  /// Check if repository operations are currently syncing
  bool get isSyncing => false;

  /// Get sync status message (for UI feedback)
  String get syncStatus => '';
}

/// Common repository methods that most repositories will implement
abstract class ListRepository<T> extends BaseRepository {
  /// Fetch all items
  Future<List<T>> getAll();

  /// Fetch a single item by ID
  Future<T?> getById(String id);

  /// Save/create an item
  Future<void> save(T item);

  /// Update an existing item
  Future<void> update(T item);

  /// Delete an item by ID
  Future<void> delete(String id);

  /// Search items by keyword
  Future<List<T>> search(String query);
}

/// Repository that supports real-time listening (streaming)
abstract class StreamRepository<T> extends ListRepository<T> {
  /// Stream of all items (reactive updates)
  Stream<List<T>> getAllStream();

  /// Stream of a single item by ID
  Stream<T?> getByIdStream(String id);
}
