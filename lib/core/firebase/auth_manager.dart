/// PawTable Firebase Auth manager
///
/// Wraps [firebase_auth] with a simple API for common auth operations:
/// - Sign up with email/password
/// - Sign in with email/password
/// - Sign in with Google (placeholder for google_sign_in integration)
/// - Sign out
/// - Password reset
/// - Auth state stream
/// - Get current user
/// - Delete account
library;

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Auth provider enum
enum AuthProvider {
  email,
  google,
  anonymous,
}

/// Auth state representing user status
enum AuthState {
  /// User is not signed in
  unsigned,

  /// User is signed in anonymously (before email setup)
  anonymous,

  /// User is fully authenticated
  authenticated,
}

/// PawTable user profile stored in Firestore
class PTUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isPremium;
  final String? preferredWeightUnit;

  const PTUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastSignInAt,
    this.isPremium = false,
    this.preferredWeightUnit,
  });

  factory PTUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PTUser(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastSignInAt: (data['lastSignInAt'] as Timestamp?)?.toDate(),
      isPremium: data['isPremium'] as bool? ?? false,
      preferredWeightUnit: data['preferredWeightUnit'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastSignInAt':
          lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'isPremium': isPremium,
      'preferredWeightUnit': preferredWeightUnit,
    };
  }

  PTUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isPremium,
    String? preferredWeightUnit,
  }) {
    return PTUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isPremium: isPremium ?? this.isPremium,
      preferredWeightUnit: preferredWeightUnit ?? this.preferredWeightUnit,
    );
  }
}

/// Firebase Auth manager for PawTable
///
/// Provides a clean abstraction over firebase_auth with PawTable-specific
/// user profile management.
class AuthManager {
  AuthManager({fb_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // =========================================================================
  // AUTH STATE
  // =========================================================================

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _auth.authStateChanges().map(
        (user) {
          if (user == null) return AuthState.unsigned;
          if (user.isAnonymous) return AuthState.anonymous;
          return AuthState.authenticated;
        },
      );

  /// Current auth state (non-streaming)
  AuthState get currentState {
    final user = _auth.currentUser;
    if (user == null) return AuthState.unsigned;
    if (user.isAnonymous) return AuthState.anonymous;
    return AuthState.authenticated;
  }

  /// Current user (nullable)
  fb_auth.User? get currentUser => _auth.currentUser;

  /// Current user ID (nullable)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Whether user is signed in
  bool get isAuthenticated => _auth.currentUser != null;

  // =========================================================================
  // SIGN UP
  // =========================================================================

  /// Create a new account with email and password
  ///
  /// Creates the auth account and the Firestore user profile simultaneously.
  Future<PTUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create auth account
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(displayName.trim());

      // Create Firestore profile
      final user = PTUser(
        uid: result.user!.uid,
        email: email.trim().toLowerCase(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // =========================================================================
  // SIGN IN
  // =========================================================================

  /// Sign in with email and password
  Future<PTUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return await _getOrCreateUser();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in anonymously (for free trial without account)
  Future<PTUser> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      final uid = _auth.currentUser!.uid;
      return PTUser(
        uid: uid,
        createdAt: DateTime.now(),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    } catch (e) {
      throw Exception('Anonymous sign in failed: $e');
    }
  }

  /// Google sign-in (placeholder — requires google_sign_in package)
  ///
  /// To implement:
  /// 1. Add google_sign_in to pubspec.yaml
  /// 2. Configure Google Sign-In in Firebase Console
  /// 3. Implement the OAuth flow below
  Future<PTUser?> signInWithGoogle() async {
    // TODO: Integrate google_sign_in
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // final GoogleAuthCredentials googleAuth =
    //     await googleUser!.authentication;
    // final OAuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // final userCredential = await _auth.signInWithCredential(credential);
    // return await _getOrCreateUser();
    throw UnsupportedError(
      'Google sign-in not yet implemented. Use email sign-in instead.',
    );
  }

  // =========================================================================
  // SIGN OUT
  // =========================================================================

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // =========================================================================
  // PASSWORD
  // =========================================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    }
  }

  /// Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    }
  }

  /// Update email
  ///
  /// NOTE: This sends a verification email to the new address.
  /// The email is not changed until the user clicks the link.
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim().toLowerCase());
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'pendingEmail': newEmail.trim().toLowerCase()});
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    }
  }

  // =========================================================================
  // ACCOUNT MANAGEMENT
  // =========================================================================

  /// Delete user account and all associated data
  ///
  /// WARNING: This is irreversible. All user data will be permanently deleted.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');

    try {
      final userId = user.uid;

      // Delete pets (and their subcollections)
      final petsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();
      for (final petDoc in petsSnapshot.docs) {
        final subcollections = [
          'feeding_logs',
          'health_logs',
          'vaccinations',
          'medications',
          'weight_logs',
        ];
        for (final coll in subcollections) {
          final snap = await petDoc.reference.collection(coll).get();
          for (final doc in snap.docs) {
            await doc.reference.delete();
          }
        }
      }

      // Delete pets collection
      for (final petDoc in petsSnapshot.docs) {
        await petDoc.reference.delete();
      }

      // Delete family members
      final familySnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('family_members')
          .get();
      for (final doc in familySnap.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Delete auth account
      await user.delete();
    } catch (e) {
      // If Firestore delete fails, attempt to delete auth account anyway
      try {
        await user.delete();
      } catch (_) {
        rethrow;
      }
    }
  }

  /// Upgrade anonymous account to permanent account (email link)
  ///
  /// This is the recommended flow for converting anonymous users:
  /// 1. User starts with anonymous sign-in
  /// 2. When they want to save data, they link email/password
  /// 3. Their anonymous data is preserved
  Future<void> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = fb_auth.EmailAuthProvider.credential(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await _auth.currentUser?.linkWithCredential(credential);
      await _auth.currentUser?.updateDisplayName(
        _auth.currentUser?.displayName ?? email.split('@').first,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getUserMessage(e.code),
      );
    }
  }

  // =========================================================================
  // USER PROFILE
  // =========================================================================

  /// Get user profile from Firestore
  Future<PTUser?> getUser() async {
    try {
      final doc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        return PTUser.fromFirestore(doc);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUser({
    String? displayName,
    String? photoURL,
    String? preferredWeightUnit,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['displayName'] = displayName.trim();
        await _auth.currentUser?.updateDisplayName(displayName.trim());
      }
      if (photoURL != null) {
        updates['photoURL'] = photoURL;
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
      if (preferredWeightUnit != null) {
        updates['preferredWeightUnit'] = preferredWeightUnit;
      }
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Set premium status
  Future<void> setPremium(bool isPremium) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({'isPremium': isPremium});
    } catch (e) {
      throw Exception('Failed to update premium status: $e');
    }
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Get or create a user document from Firestore
  Future<PTUser> _getOrCreateUser() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return PTUser.fromFirestore(doc);
    }

    // Create user profile
    final user = PTUser(
      uid: uid,
      email: _auth.currentUser?.email,
      displayName: _auth.currentUser?.displayName,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  /// Map Firebase error codes to user-friendly messages
  String _getUserMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-argument':
        return 'The email address format is not valid.';
      case 'invalid-credential':
        return 'Invalid sign-in credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'internal-error':
        return 'An internal error occurred. Please try again.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}

/// Exception thrown for Firebase auth errors
class FirebaseAuthException implements Exception {
  final String code;
  final String? message;

  const FirebaseAuthException({
    required this.code,
    this.message,
  });

  @override
  String toString() {
    if (message != null) return 'FirebaseAuth: $message';
    return 'FirebaseAuth: $code';
  }
}
