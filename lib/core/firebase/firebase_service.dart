/// PawTable unified Firebase service
///
/// Orchestrates Firebase initialization, Auth, and Firestore into a
/// single service with a clean public API.
///
/// Usage:
/// ```dart
/// final firebaseService = FirebaseService();
/// await firebaseService.initialize();
/// final userId = firebaseService.currentUser?.uid;
/// ```
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_manager.dart';
import 'firestore_manager.dart';
import 'firebase_options.dart';

/// PawTable unified Firebase service
///
/// Initializes Firebase, manages authentication, and provides access
/// to Firestore operations scoped to the current user.
class FirebaseService {
  FirebaseService() {
    _auth = AuthManager();
    _firestore = FirestoreManager();
  }

  FirebaseApp? _firebaseApp;

  late final AuthManager _auth;
  late final FirestoreManager _firestore;

  // =========================================================================
  // INITIALIZATION
  // =========================================================================

  /// Initialize Firebase with default options
  ///
  /// Call this before any other Firebase operations. Typically done
  /// in main.dart's main() function.
  ///
  /// In development, if Firebase configuration is not available (placeholder
  /// values), initialization will be skipped and the app will continue
  /// in offline-only mode.
  Future<void> initialize() async {
    try {
      // Check if we have real Firebase config (not placeholder values)
      final options = DefaultFirebaseOptions.currentPlatform;
      final hasRealConfig = !options.apiKey.startsWith('YOUR_');

      if (!hasRealConfig) {
        // Log a warning but don't fail — app works in offline mode
        debugPrint(
          '[FirebaseService] Firebase config contains placeholder values. '
          'Running in offline-only mode. Set up Firebase with '
          '`flutterfire configure` to enable cloud features.',
        );
        return;
      }

      // Initialize Firebase
      _firebaseApp = await Firebase.initializeApp();

      debugPrint(
        '[FirebaseService] Firebase initialized successfully '
        '(app: ${_firebaseApp?.name})',
      );

      // Enable offline persistence via settings
      await _firestore.enablePersistence();

      // Listen for auth state changes
      _auth.authStateChanges.listen(_onAuthStateChanged);
    } on FirebaseException catch (e) {
      debugPrint('[FirebaseService] Firebase initialization failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirebaseService] Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Initialize Firebase with custom options (for multi-app setups)
  Future<void> initializeWithOptions(FirebaseOptions options) async {
    _firebaseApp = await Firebase.initializeApp(
      name: 'pawtable',
      options: options,
    );

    debugPrint(
      '[FirebaseService] Firebase initialized with custom options '
      '(app: ${_firebaseApp?.name})',
    );

    await _firestore.enablePersistence();
    _auth.authStateChanges.listen(_onAuthStateChanged);
  }

  // =========================================================================
  // AUTH
  // =========================================================================

  /// Get the auth manager
  AuthManager get auth => _auth;

  /// Get the current user ID
  String? get currentUserId => _auth.currentUserId;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.isAuthenticated;

  /// Get current auth state
  AuthState get authState => _auth.currentState;

  // =========================================================================
  // FIRESTORE
  // =========================================================================

  /// Get the firestore manager
  FirestoreManager get firestore => _firestore;

  // =========================================================================
  // AUTH STATE HANDLER
  // =========================================================================

  /// Handle auth state changes
  void _onAuthStateChanged(AuthState state) {
    switch (state) {
      case AuthState.authenticated:
        _updateLastSignIn();
        break;
      case AuthState.anonymous:
        // User is signed in anonymously — no profile update needed
        break;
      case AuthState.unsigned:
        // User signed out — nothing to do
        break;
    }
  }

  /// Update the last sign-in timestamp
  Future<void> _updateLastSignIn() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      await _firestore.updateUserProfile(userId, {
        'lastSignInAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('[FirebaseService] Failed to update last sign-in: $e');
    }
  }

  // =========================================================================
  // CONVENIENCE METHODS
  // =========================================================================

  /// Sign up and initialize Firebase in one call
  Future<Map<String, dynamic>> signUpAndInitialize({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await initialize();
    final user = await _auth.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return {
      'success': true,
      'userId': user.uid,
      'email': user.email,
    };
  }

  /// Sign in and ensure Firebase is initialized
  Future<Map<String, dynamic>> signInWithCheck({
    required String email,
    required String password,
  }) async {
    await initialize();
    final user = await _auth.signIn(
      email: email,
      password: password,
    );
    return {
      'success': true,
      'userId': user.uid,
      'email': user.email,
    };
  }

  /// Sign out and clear local state
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _firebaseApp != null; // ignore:unnecessary_null_comparison
}

// =========================================================================
// RIVERPOD PROVIDERS
// =========================================================================

/// Firebase service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Auth state provider — streams the current auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.auth.authStateChanges;
});

/// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.currentUserId;
});

/// Authenticated provider — true when user is signed in
final isAuthenticatedProvider = Provider<bool>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.isAuthenticated;
});
