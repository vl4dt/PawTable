import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/sync_repository.dart';

/// Firestore-sync backed real-time sync service
///
/// Uses [FirebaseFirestore] directly for real-time listening, push,
/// merge, and conflict resolution.
class FirestoreSyncService implements FamilySyncRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  /// Track active stream subscriptions for cleanup
  final Map<String, StreamSubscription<QuerySnapshot>> _activeSubscriptions = {};

  /// Sync status state
  final Map<FamilySyncType, FamilySyncState> _syncStates = {};

  /// Enable/disable sync
  bool _syncEnabled = false;

  FirestoreSyncService({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  // =========================================================================
  // BaseRepository overrides
  // =========================================================================

  @override
  bool get isSyncing => _activeSubscriptions.isNotEmpty;

  @override
  String get syncStatus =>
      _syncEnabled
          ? 'Listening to ${_activeSubscriptions.length} collections'
          : 'Sync disabled';

  // =========================================================================
  // Real-time listening
  // =========================================================================

  @override
  Stream<List<Map<String, dynamic>>> listenToCollection(
    String collection, {
    String? docId,
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> ref =
        _firestore.collection(_userPath(_userId, collection));

    if (orderBy != null) {
      ref = ref.orderBy(orderBy, descending: descending);
    }

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  void stopListening(String collection) {
    final key = '$_userId:$collection';
    final subscription = _activeSubscriptions.remove(key);
    if (subscription != null) {
      subscription.cancel();
      debugPrint('[FirestoreSync] Stopped listening to $collection');
    }
  }

  // =========================================================================
  // Push & Merge
  // =========================================================================

  @override
  Future<void> pushLocalChanges({
    required String userId,
    required String collection,
    required String docId,
    required Map<String, dynamic> changes,
  }) async {
    try {
      await _firestore
          .doc(_userPath(userId, '$collection/$docId'))
          .set(changes, SetOptions(merge: true));

      debugPrint('[FirestoreSync] Pushed changes to $collection/$docId');
    } catch (e) {
      debugPrint('[FirestoreSync] Failed to push changes: $e');
      rethrow;
    }
  }

  @override
  Future<void> applyRemoteChanges({
    required String collection,
    required List<Map<String, dynamic>> remoteDocs,
    required String userId,
  }) async {
    // Remote changes are applied via stream listeners
    // This method updates our sync state tracking
    try {
      final index = _getIndexByString(collection);
      _syncStates[FamilySyncType.values[index]] = FamilySyncState(
        type: FamilySyncType.values[index],
        isConnected: true,
        documentCount: remoteDocs.length,
        lastUpdate: DateTime.now(),
      );
      debugPrint(
        '[FirestoreSync] Applied ${remoteDocs.length} changes to $collection',
      );
    } catch (e) {
      debugPrint('[FirestoreSync] Failed to apply remote changes: $e');
    }
  }

  // =========================================================================
  // Sync Status
  // =========================================================================

  @override
  Future<FamilySyncState> getSyncStatus(FamilySyncType type) async {
    return _syncStates[type] ?? FamilySyncState(type: type);
  }

  @override
  Future<Map<FamilySyncType, FamilySyncState>> getAllSyncStatuses() async {
    return Map<FamilySyncType, FamilySyncState>.from(_syncStates);
  }

  // =========================================================================
  // Enable/Disable
  // =========================================================================

  @override
  bool isSyncEnabled() => _syncEnabled;

  @override
  Future<void> enableSync() async {
    _syncEnabled = true;

    // Start listening to all family-related collections
    _startListeningToAll();

    debugPrint('[FirestoreSync] Real-time sync enabled');
  }

  @override
  Future<void> disableSync() async {
    _syncEnabled = false;

    // Cancel all active subscriptions
    for (final subscription in _activeSubscriptions.values) {
      await subscription.cancel();
    }
    _activeSubscriptions.clear();

    debugPrint('[FirestoreSync] Real-time sync disabled');
  }

  @override
  Future<void> forceRefresh(FamilySyncType type) async {
    final collection = type.name;
    try {
      final snapshot = await _firestore
          .collection(_userPath(_userId, collection))
          .get();
      final docs = snapshot.docs.map((doc) => doc.data()).toList();

      await applyRemoteChanges(
        collection: collection,
        remoteDocs: docs,
        userId: _userId,
      );

      debugPrint('[FirestoreSync] Force refreshed $collection');
    } catch (e) {
      debugPrint('[FirestoreSync] Force refresh failed: $e');
    }
  }

  // =========================================================================
  // Conflict Resolution
  // =========================================================================

  @override
  Future<void> resolveConflicts({
    required String collection,
    required String docId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {
    // Conflict resolution strategy: last-write-wins based on updatedAt
    // Remote timestamp takes precedence if newer
    final localUpdated = localData['updatedAt'] as DateTime?;
    final remoteUpdated = remoteData['updatedAt'] as DateTime?;

    if (remoteUpdated == null ||
        (localUpdated != null && localUpdated.isAfter(remoteUpdated))) {
      // Local is newer, push local to remote
      await pushLocalChanges(
        userId: _userId,
        collection: collection,
        docId: docId,
        changes: localData,
      );
      debugPrint(
        '[FirestoreSync] Conflict resolved: kept local changes for $docId',
      );
    } else {
      // Remote is newer or equal, accept remote
      debugPrint(
        '[FirestoreSync] Conflict resolved: accepted remote changes for $docId',
      );
    }
  }

  // =========================================================================
  // Helper Methods
  // =========================================================================

  /// Get index of FamilySyncType by string name
  int _getIndexByString(String name) {
    for (var i = 0; i < FamilySyncType.values.length; i++) {
      if (FamilySyncType.values[i].name == name) {
        return i;
      }
    }
    return 0;
  }

  /// Build the user-scoped path for a collection
  String _userPath(String userId, String collection) {
    return 'users/$userId/collection/$collection';
  }

  /// Start listening to all family-related collections
  void _startListeningToAll() {
    // Listen to family groups
    _listenToFamilyGroups();

    // Listen to family members
    _listenToFamilyMembers();

    // Listen to shared pets
    _listenToSharedPets();

    // Listen to pet sitter access
    _listenToPetSitterAccess();

    // Listen to activity feed
    _listenToActivityFeed();

    // Listen to invite tokens
    _listenToInviteTokens();

    // Update sync states
    for (final type in FamilySyncType.values) {
      _syncStates[type] = FamilySyncState(
        type: type,
        isConnected: true,
        lastUpdate: DateTime.now(),
      );
    }

    debugPrint(
      '[FirestoreSync] Started listening to ${FamilySyncType.values.length} collections',
    );
  }

  void _listenToFamilyGroups() {
    final collection = 'family_groups';
    final key = '$_userId:$collection';

    final subscription =
        _firestore.collection(_userPath(_userId, collection)).snapshots().listen(
      (snapshot) {
        _syncStates[FamilySyncType.familyGroups] = FamilySyncState(
          type: FamilySyncType.familyGroups,
          isConnected: true,
          documentCount: snapshot.docs.length,
          lastUpdate: DateTime.now(),
        );
      },
    );

    _activeSubscriptions[key] = subscription;
  }

  void _listenToFamilyMembers() {
    final collection = 'family_members';
    final key = '$_userId:$collection';

    final subscription =
        _firestore.collection(_userPath(_userId, collection)).snapshots().listen(
      (snapshot) {
        _syncStates[FamilySyncType.familyMembers] = FamilySyncState(
          type: FamilySyncType.familyMembers,
          isConnected: true,
          documentCount: snapshot.docs.length,
          lastUpdate: DateTime.now(),
        );
      },
    );

    _activeSubscriptions[key] = subscription;
  }

  void _listenToSharedPets() {
    final collection = 'shared_pets';
    final key = '$_userId:$collection';

    final subscription =
        _firestore.collection(_userPath(_userId, collection)).snapshots().listen(
      (snapshot) {
        _syncStates[FamilySyncType.sharedPets] = FamilySyncState(
          type: FamilySyncType.sharedPets,
          isConnected: true,
          documentCount: snapshot.docs.length,
          lastUpdate: DateTime.now(),
        );
      },
    );

    _activeSubscriptions[key] = subscription;
  }

  void _listenToPetSitterAccess() {
    final collection = 'pet_sitter_access';
    final key = '$_userId:$collection';

    final subscription =
        _firestore.collection(_userPath(_userId, collection)).snapshots().listen(
      (snapshot) {
        _syncStates[FamilySyncType.petSitterAccess] = FamilySyncState(
          type: FamilySyncType.petSitterAccess,
          isConnected: true,
          documentCount: snapshot.docs.length,
          lastUpdate: DateTime.now(),
        );
      },
    );

    _activeSubscriptions[key] = subscription;
  }

  void _listenToActivityFeed() {
    final collection = 'activity_feed';
    final key = '$_userId:$collection';

    final subscription = _firestore
        .collection(_userPath(_userId, collection))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          _syncStates[FamilySyncType.activityFeed] = FamilySyncState(
            type: FamilySyncType.activityFeed,
            isConnected: true,
            documentCount: snapshot.docs.length,
            lastUpdate: DateTime.now(),
          );
        });

    _activeSubscriptions[key] = subscription;
  }

  void _listenToInviteTokens() {
    final collection = 'invite_tokens';
    final key = '$_userId:$collection';

    final subscription =
        _firestore.collection(_userPath(_userId, collection)).snapshots().listen(
      (snapshot) {
        _syncStates[FamilySyncType.inviteTokens] = FamilySyncState(
          type: FamilySyncType.inviteTokens,
          isConnected: true,
          documentCount: snapshot.docs.length,
          lastUpdate: DateTime.now(),
        );
      },
    );

    _activeSubscriptions[key] = subscription;
  }
}
