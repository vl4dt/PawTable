import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../core/storage/database_helper.dart';
import '../core/billing/billing_service.dart';

/// Dependency injection providers
///
/// All services are provided here so they can be injected anywhere
/// in the app using Riverpod's `ref.watch` or `ref.read`.

// Storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final databaseServiceProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Billing
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref);
});

/// Async provider that initializes all services on app start
final initializationProvider = FutureProvider<void>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  await storageService.init();

  // Firebase initialization will happen later
  // when Firebase is configured

  return;
});

/// Top-level provider that watches all initializations
final appServiceProvider = Provider<void>((ref) {
  ref.watch(initializationProvider);
  ref.watch(storageServiceProvider);
  ref.watch(databaseServiceProvider);
  ref.watch(billingServiceProvider);
});
