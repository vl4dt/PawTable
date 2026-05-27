import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/features/family/domain/repositories/sync_repository.dart';
import 'package:pawtable/features/family/data/services/firestore_sync_service.dart';

// =========================================================================
// SYNC OPERATION TYPES
// =========================================================================

/// Sync operation types for family collaboration
enum SyncType {
  familyGroups,
  familyMembers,
  sharedPets,
  petSitterAccess,
  activityFeed,
  inviteTokens,
  feedings,
  healthLogs,
  vaccinations,
  medications,
  weightLogs,
  pets,
}

/// Sync status for an operation
class SyncStatus {
  final SyncType type;
  final bool isSyncing;
  final bool isConnected;
  final String? lastError;
  final DateTime? lastSync;
  final int pendingChanges;
  final int documentCount;

  const SyncStatus({
    required this.type,
    this.isSyncing = false,
    this.isConnected = false,
    this.lastError,
    this.lastSync,
    this.pendingChanges = 0,
    this.documentCount = 0,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    bool? isConnected,
    String? lastError,
    DateTime? lastSync,
    int? pendingChanges,
    int? documentCount,
  }) {
    return SyncStatus(
      type: type,
      isSyncing: isSyncing ?? this.isSyncing,
      isConnected: isConnected ?? this.isConnected,
      lastError: lastError ?? this.lastError,
      lastSync: lastSync ?? this.lastSync,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      documentCount: documentCount ?? this.documentCount,
    );
  }

  /// Check if this sync type has active connection
  bool get hasConnection => isConnected && !isSyncing;

  /// Check if there are pending changes to sync
  bool get hasPendingChanges => pendingChanges > 0;
}

/// Global sync state managing all sync operations
class SyncState {
  final Map<SyncType, SyncStatus> statuses;
  final bool isFullSync;
  final String? lastFullSync;
  final bool isSyncEnabled;
  final String? errorMessage;

  const SyncState({
    this.statuses = const {},
    this.isFullSync = false,
    this.lastFullSync,
    this.isSyncEnabled = false,
    this.errorMessage,
  });

  SyncStatus getStatus(SyncType type) =>
      statuses[type] ?? SyncStatus(type: type);

  SyncState copyWith({
    Map<SyncType, SyncStatus>? statuses,
    bool? isFullSync,
    String? lastFullSync,
    bool? isSyncEnabled,
    String? errorMessage,
  }) {
    return SyncState(
      statuses: statuses ?? this.statuses,
      isFullSync: isFullSync ?? this.isFullSync,
      lastFullSync: lastFullSync ?? this.lastFullSync,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get overall sync health
  SyncHealth get health {
    if (!isSyncEnabled) return SyncHealth.disabled;

    final connectedTypes = statuses.values
        .where((s) => s.isConnected)
        .toList();

    if (connectedTypes.isEmpty) return SyncHealth.disconnected;
    if (connectedTypes.length == statuses.length) return SyncHealth.healthy;

    return SyncHealth.partial;
  }

  /// Get count of connected sync types
  int get connectedCount =>
      statuses.values.where((s) => s.isConnected).length;

  /// Get total sync types
  int get totalCount => statuses.length;
}

/// Overall sync health status
enum SyncHealth {
  disabled,    // Sync is not enabled
  disconnected, // No connections active
  partial,     // Some connections active
  healthy,     // All connections active
}

/// AsyncNotifier for sync management
class SyncNotifier extends AsyncNotifier<SyncState> {
  late final FamilySyncRepository _syncRepository;
  String? _currentUserId;

  @override
  Future<SyncState> build() async {
    _currentUserId = _getCurrentUserId();
    _syncRepository = FirestoreSyncService(
      userId: _currentUserId ?? 'anonymous',
    );

    return const SyncState(isSyncEnabled: true);
  }

  /// Get current user ID (helper)
  String? _getCurrentUserId() {
    try {
      // Try to get from auth provider
      // This is a simplification - in production, use proper auth provider
      return 'user-current';
    } catch (e) {
      return null;
    }
  }

  // =========================================================================
  // Enable/Disable Sync
  // =========================================================================

  /// Enable real-time sync
  Future<void> enableSync() async {
    state = const AsyncLoading();

    try {
      await _syncRepository.enableSync();

      state = AsyncData(
        state.value?.copyWith(isSyncEnabled: true) ??
            const SyncState(isSyncEnabled: true),
      );

      debugPrint('[SyncNotifier] Real-time sync enabled');
    } catch (e) {
      state = AsyncError(
        e.toString(),
        StackTrace.current,
      );
      debugPrint('[SyncNotifier] Failed to enable sync: $e');
    }
  }

  /// Disable real-time sync
  Future<void> disableSync() async {
    try {
      await _syncRepository.disableSync();

      state = AsyncData(
        state.value?.copyWith(isSyncEnabled: false) ??
            const SyncState(isSyncEnabled: false),
      );

      debugPrint('[SyncNotifier] Real-time sync disabled');
    } catch (e) {
      debugPrint('[SyncNotifier] Failed to disable sync: $e');
    }
  }

  // =========================================================================
  // Sync Operations
  // =========================================================================

  /// Start sync for a specific type
  Future<void> sync(SyncType type) async {
    final currentState = state.value ?? const SyncState();

    final updatedStatus = currentState.getStatus(type).copyWith(
      isSyncing: true,
    );

    final newStatuses = Map<SyncType, SyncStatus>.from(currentState.statuses);
    newStatuses[type] = updatedStatus;

    state = AsyncData(
      currentState.copyWith(statuses: newStatuses),
    );

    try {
      // Perform actual sync
      await _syncRepository.forceRefresh(
        FamilySyncType.values.byName(type.name),
      );

      final newStatus = updatedStatus.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
        isConnected: true,
      );

      newStatuses[type] = newStatus;

      state = AsyncData(
        currentState.copyWith(statuses: newStatuses),
      );

      debugPrint('[SyncNotifier] Synced $type successfully');
    } catch (e) {
      final errorStatus = updatedStatus.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );

      newStatuses[type] = errorStatus;

      state = AsyncData(
        currentState.copyWith(statuses: newStatuses),
      );

      debugPrint('[SyncNotifier] Sync failed for $type: $e');
    }
  }

  /// Full sync of all data
  Future<void> fullSync() async {
    state = const AsyncLoading();

    final currentState = state.value ?? const SyncState();

    try {
      // Sync all types in parallel
      await Future.wait(
        SyncType.values.map((type) => sync(type)),
      );

      state = AsyncData(
        currentState.copyWith(
          isFullSync: true,
          lastFullSync: DateTime.now().toIso8601String(),
        ),
      );

      debugPrint('[SyncNotifier] Full sync completed');
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(
          errorMessage: e.toString(),
        ),
      );

      debugPrint('[SyncNotifier] Full sync failed: $e');
    }
  }

  // =========================================================================
  // Change Tracking
  // =========================================================================

  /// Add pending change
  void addPendingChange(SyncType type) {
    final current = state.value ?? const SyncState();

    final status = current.getStatus(type);
    final newStatus = status.copyWith(
      pendingChanges: status.pendingChanges + 1,
    );

    final newStatuses = Map<SyncType, SyncStatus>.from(current.statuses);
    newStatuses[type] = newStatus;

    state = AsyncData(current.copyWith(statuses: newStatuses));
  }

  /// Clear pending changes
  void clearPendingChanges(SyncType type) {
    final current = state.value ?? const SyncState();

    final status = current.getStatus(type);
    final newStatus = status.copyWith(pendingChanges: 0);

    final newStatuses = Map<SyncType, SyncStatus>.from(current.statuses);
    newStatuses[type] = newStatus;

    state = AsyncData(current.copyWith(statuses: newStatuses));
  }

  // =========================================================================
  // Push Local Changes
  // =========================================================================

  /// Push local changes to Firestore
  Future<bool> pushLocalChanges({
    required SyncType type,
    required String docId,
    required Map<String, dynamic> changes,
  }) async {
    try {
      await _syncRepository.pushLocalChanges(
        userId: _currentUserId ?? 'anonymous',
        collection: type.name,
        docId: docId,
        changes: changes,
      );

      clearPendingChanges(type);

      debugPrint('[SyncNotifier] Pushed local changes for $type');
      return true;
    } catch (e) {
      debugPrint('[SyncNotifier] Failed to push local changes: $e');
      return false;
    }
  }

  // =========================================================================
  // Conflict Resolution
  // =========================================================================

  /// Resolve conflicts for a document
  Future<void> resolveConflict({
    required SyncType type,
    required String docId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {
    try {
      await _syncRepository.resolveConflicts(
        collection: type.name,
        docId: docId,
        localData: localData,
        remoteData: remoteData,
      );

      debugPrint('[SyncNotifier] Resolved conflict for $type/$docId');
    } catch (e) {
      debugPrint('[SyncNotifier] Conflict resolution failed: $e');
    }
  }

  // =========================================================================
  // Stream Listeners
  // =========================================================================

  /// Listen for real-time updates to a collection
  Stream<List<Map<String, dynamic>>> listenToCollection(
    SyncType type, {
    String? docId,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
  }) {
    return _syncRepository.listenToCollection(
      type.name,
      docId: docId,
      where: where,
      orderBy: orderBy,
      descending: descending,
    );
  }

  /// Stop listening to a collection
  void stopListening(SyncType type) {
    _syncRepository.stopListening(type.name);
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);

/// Provider for sync health indicator
final syncHealthProvider = Provider<SyncHealth>((ref) {
  final syncState = ref.watch(syncProvider);
  return syncState.when(
    data: (state) => state.health,
    loading: () => SyncHealth.disabled,
    error: (_, __) => SyncHealth.disconnected,
  );
});

/// Provider for sync connection status
final syncConnectionProvider = Provider<bool>((ref) {
  final syncState = ref.watch(syncProvider);
  return syncState.when(
    data: (state) => state.statuses.values.any((s) => s.isConnected),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for total connected document count
final syncDocumentCountProvider = Provider<int>((ref) {
  final syncState = ref.watch(syncProvider);
  return syncState.when(
    data: (state) =>
        state.statuses.values.fold<int>(0, (prev, status) => prev + status.documentCount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
