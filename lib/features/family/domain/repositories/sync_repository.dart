import '../../../../core/repository/base_repository.dart';

/// Real-time sync data types for family collaboration
enum FamilySyncType {
  familyGroups,
  familyMembers,
  sharedPets,
  petSitterAccess,
  activityFeed,
  inviteTokens,
}

/// Sync state for a real-time listener
class FamilySyncState {
  final FamilySyncType type;
  final bool isConnected;
  final int documentCount;
  final String? lastError;
  final DateTime? lastUpdate;
  final bool isReconnecting;

  const FamilySyncState({
    required this.type,
    this.isConnected = false,
    this.documentCount = 0,
    this.lastError,
    this.lastUpdate,
    this.isReconnecting = false,
  });

  FamilySyncState copyWith({
    bool? isConnected,
    int? documentCount,
    String? lastError,
    DateTime? lastUpdate,
    bool? isReconnecting,
  }) {
    return FamilySyncState(
      type: type,
      isConnected: isConnected ?? this.isConnected,
      documentCount: documentCount ?? this.documentCount,
      lastError: lastError ?? this.lastError,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isReconnecting: isReconnecting ?? this.isReconnecting,
    );
  }
}

/// Repository interface for real-time sync operations
abstract class FamilySyncRepository extends BaseRepository {
  /// Start listening for real-time updates for a collection
  /// Returns a stream that emits updates when remote data changes
  Stream<List<Map<String, dynamic>>> listenToCollection(
    String collection, {
    String? docId,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
  });

  /// Stop listening for a specific collection
  void stopListening(String collection);

  /// Push local changes to Firestore (conflict resolution)
  Future<void> pushLocalChanges({
    required String userId,
    required String collection,
    required String docId,
    required Map<String, dynamic> changes,
  });

  /// Merge remote changes into local state
  Future<void> applyRemoteChanges({
    required String collection,
    required List<Map<String, dynamic>> remoteDocs,
    required String userId,
  });

  /// Get sync status for a specific type
  Future<FamilySyncState> getSyncStatus(FamilySyncType type);

  /// Get all sync statuses
  Future<Map<FamilySyncType, FamilySyncState>> getAllSyncStatuses();

  /// Check if real-time sync is enabled
  bool isSyncEnabled();

  /// Enable real-time sync
  Future<void> enableSync();

  /// Disable real-time sync
  Future<void> disableSync();

  /// Force a full sync refresh
  Future<void> forceRefresh(FamilySyncType type);

  /// Resolve conflicts between local and remote data
  Future<void> resolveConflicts({
    required String collection,
    required String docId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  });
}
