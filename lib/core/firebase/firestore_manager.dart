/// PawTable Firestore manager
///
/// Wraps [cloud_firestore] with PawTable-specific operations:
/// - Pet CRUD (with nested subcollections)
/// - Health log CRUD
/// - Feeding log CRUD
/// - Vaccination CRUD
/// - Medication CRUD
/// - Weight log CRUD
/// - Family member management
/// - Real-time streams for shared data
/// - Batch operations
/// - Sync state management
///
/// All operations are scoped to the current user.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore manager for PawTable
///
/// Provides a clean API for all Firestore operations with automatic
/// user scoping, error handling, and real-time stream support.
class FirestoreManager {
  FirestoreManager({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Get the user-scoped reference path
  String _userPath(String userId, String collection) {
    return 'users/$userId/collection/$collection';
  }

  /// Get a user-scoped collection reference
  CollectionReference<Map<String, dynamic>> _userCollection(
    String userId,
    String collection,
  ) {
    return _firestore.collection(_userPath(userId, collection));
  }

  /// Get a pet-scoped subcollection reference
  CollectionReference<Map<String, dynamic>> _petSubcollection(
    String userId,
    String petId,
    String collection,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection(collection);
  }

  // =========================================================================
  // USER PROFILE
  // =========================================================================

  /// Get user profile document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String userId,
  ) {
    return _firestore.doc('users/$userId').get();
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _firestore.doc('users/$userId').update(data);
  }

  /// Create user profile (initial creation)
  Future<void> createUserProfile(String userId, Map<String, dynamic> data) {
    return _firestore.doc('users/$userId').set(data);
  }

  // =========================================================================
  // PETS
  // =========================================================================

  /// Get all pets for a user
  Stream<List<Map<String, dynamic>>> listPets(String userId) {
    return _userCollection(userId, 'pets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get a single pet
  Future<DocumentSnapshot<Map<String, dynamic>>> getPet(
    String userId,
    String petId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .get();
  }

  /// Create a pet
  ///
  /// Returns the document ID of the newly created pet.
  Future<String> createPet(String userId, Map<String, dynamic> petData) async {
    final ref = await _userCollection(userId, 'pets').add({
      ...petData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Update a pet
  Future<void> updatePet(String userId, String petId, Map<String, dynamic> data) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Delete a pet (cascades to all subcollections)
  Future<void> deletePet(String userId, String petId) async {
    final batch = _firestore.batch();

    // Delete subcollections
    final subcollections = [
      'feeding_logs',
      'health_logs',
      'vaccinations',
      'medications',
      'weight_logs',
    ];

    for (final collection in subcollections) {
      final docs = await _petSubcollection(userId, petId, collection).get();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
    }

    // Delete the pet document
    batch.delete(
      _firestore.collection(_userPath(userId, 'pets')).doc(petId),
    );

    await batch.commit();
  }

  // =========================================================================
  // FEEDING LOGS
  // =========================================================================

  /// Get feeding logs for a pet (last N entries)
  Stream<List<Map<String, dynamic>>> listFeedingLogs(
    String userId,
    String petId, {
    int limit = 30,
  }) {
    return _petSubcollection(userId, petId, 'feeding_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add a feeding log
  Future<void> addFeedingLog(
    String userId,
    String petId,
    Map<String, dynamic> logData,
  ) {
    return _petSubcollection(userId, petId, 'feeding_logs').add({
      ...logData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a feeding log
  Future<void> updateFeedingLog(
    String userId,
    String petId,
    String logId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('feeding_logs')
        .doc(logId)
        .update(data);
  }

  /// Delete a feeding log
  Future<void> deleteFeedingLog(
    String userId,
    String petId,
    String logId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('feeding_logs')
        .doc(logId)
        .delete();
  }

  // =========================================================================
  // HEALTH LOGS
  // =========================================================================

  /// Get health logs for a pet
  Stream<List<Map<String, dynamic>>> listHealthLogs(
    String userId,
    String petId, {
    int limit = 50,
  }) {
    return _petSubcollection(userId, petId, 'health_logs')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add a health log
  Future<void> addHealthLog(
    String userId,
    String petId,
    Map<String, dynamic> logData,
  ) {
    return _petSubcollection(userId, petId, 'health_logs').add({
      ...logData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a health log
  Future<void> updateHealthLog(
    String userId,
    String petId,
    String logId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('health_logs')
        .doc(logId)
        .update(data);
  }

  /// Delete a health log
  Future<void> deleteHealthLog(
    String userId,
    String petId,
    String logId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('health_logs')
        .doc(logId)
        .delete();
  }

  // =========================================================================
  // VACCINATIONS
  // =========================================================================

  /// Get vaccinations for a pet
  Stream<List<Map<String, dynamic>>> listVaccinations(
    String userId,
    String petId,
  ) {
    return _petSubcollection(userId, petId, 'vaccinations')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add a vaccination
  Future<void> addVaccination(
    String userId,
    String petId,
    Map<String, dynamic> data,
  ) {
    return _petSubcollection(userId, petId, 'vaccinations').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a vaccination
  Future<void> updateVaccination(
    String userId,
    String petId,
    String vaccId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccId)
        .update(data);
  }

  /// Delete a vaccination
  Future<void> deleteVaccination(
    String userId,
    String petId,
    String vaccId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccId)
        .delete();
  }

  // =========================================================================
  // MEDICATIONS
  // =========================================================================

  /// Get active medications for a pet
  Stream<List<Map<String, dynamic>>> listActiveMedications(
    String userId,
    String petId,
  ) {
    return _petSubcollection(userId, petId, 'medications')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get all medications for a pet
  Stream<List<Map<String, dynamic>>> listAllMedications(
    String userId,
    String petId,
  ) {
    return _petSubcollection(userId, petId, 'medications')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add a medication
  Future<void> addMedication(
    String userId,
    String petId,
    Map<String, dynamic> data,
  ) {
    return _petSubcollection(userId, petId, 'medications').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a medication
  Future<void> updateMedication(
    String userId,
    String petId,
    String medId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('medications')
        .doc(medId)
        .update(data);
  }

  /// Delete a medication
  Future<void> deleteMedication(
    String userId,
    String petId,
    String medId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('medications')
        .doc(medId)
        .delete();
  }

  // =========================================================================
  // WEIGHT LOGS
  // =========================================================================

  /// Get weight logs for a pet (sorted by date ascending for charts)
  Stream<List<Map<String, dynamic>>> listWeightLogs(
    String userId,
    String petId,
  ) {
    return _petSubcollection(userId, petId, 'weight_logs')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add a weight log
  Future<void> addWeightLog(
    String userId,
    String petId,
    Map<String, dynamic> data,
  ) {
    return _petSubcollection(userId, petId, 'weight_logs').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a weight log
  Future<void> updateWeightLog(
    String userId,
    String petId,
    String logId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('weight_logs')
        .doc(logId)
        .update(data);
  }

  /// Delete a weight log
  Future<void> deleteWeightLog(
    String userId,
    String petId,
    String logId,
  ) {
    return _firestore
        .collection(_userPath(userId, 'pets'))
        .doc(petId)
        .collection('weight_logs')
        .doc(logId)
        .delete();
  }

  // =========================================================================
  // FAMILY / SHARED PETS
  // =========================================================================

  /// Add a family member to a user
  Future<void> addFamilyMember(
    String userId,
    String memberUid,
    String memberName,
  ) {
    return _firestore
        .collection(_userPath(userId, 'family_members'))
        .doc(memberUid)
        .set({
          'uid': memberUid,
          'name': memberName,
          'addedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Remove a family member
  Future<void> removeFamilyMember(String userId, String memberUid) {
    return _firestore
        .collection(_userPath(userId, 'family_members'))
        .doc(memberUid)
        .delete();
  }

  /// Get family members for a user
  Stream<List<Map<String, dynamic>>> listFamilyMembers(String userId) {
    return _userCollection(userId, 'family_members')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Share a pet with a family member
  Future<void> sharePet(
    String ownerUserId,
    String memberUserId,
    String petId,
  ) {
    return _firestore
        .collection(_userPath(memberUserId, 'shared_pets'))
        .doc(petId)
        .set({
          'petId': petId,
          'sharedBy': ownerUserId,
          'sharedAt': FieldValue.serverTimestamp(),
          'role': 'editor', // default role
        });
  }

  /// Get shared pets for a user (pets owned by others in the family)
  Stream<List<Map<String, dynamic>>> listSharedPets(String userId) {
    return _userCollection(userId, 'shared_pets')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stop sharing a pet
  Future<void> stopSharingPet(String userId, String petId) {
    return _firestore
        .collection(_userPath(userId, 'shared_pets'))
        .doc(petId)
        .delete();
  }

  // =========================================================================
  // NOTIFICATIONS / REMINDERS
  // =========================================================================

  /// Get active reminders for a user
  Stream<List<Map<String, dynamic>>> listReminders(String userId) {
    return _userCollection(userId, 'reminders')
        .where('isActive', isEqualTo: true)
        .orderBy('nextTriggerAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Create a reminder
  Future<void> addReminder(String userId, Map<String, dynamic> data) {
    return _userCollection(userId, 'reminders').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a reminder
  Future<void> updateReminder(
    String userId,
    String reminderId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(_userPath(userId, 'reminders'))
        .doc(reminderId)
        .update(data);
  }

  /// Delete a reminder
  Future<void> deleteReminder(String userId, String reminderId) {
    return _firestore
        .collection(_userPath(userId, 'reminders'))
        .doc(reminderId)
        .delete();
  }

  // =========================================================================
  // BATCH OPERATIONS
  // =========================================================================

  /// Write a batch of operations
  Future<void> writeBatch(void Function(WriteBatch) operation) async {
    final batch = _firestore.batch();
    operation(batch);
    await batch.commit();
  }

  /// Execute an operation within a transaction
  Future<T> withTransaction<T>(
    Future<T> Function(Transaction) operation,
  ) {
    return _firestore.runTransaction(operation);
  }

  // =========================================================================
  // SYNC / OFFLINE
  // =========================================================================

  /// Enable offline persistence
  ///
  /// Note: Offline persistence is enabled by default in Flutter.
  /// This method is a no-op but kept for API compatibility.
  Future<void> enablePersistence() async {
    // Persistence is enabled by default in Flutter SDK
    // No additional configuration needed
  }
}
