import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../core/storage/database_helper.dart';
import '../core/billing/billing_service.dart';
import '../features/pets/domain/repositories/pet_repository.dart';
import '../features/pets/presentation/providers/pet_provider.dart';
import 'app_module.dart';

/// Dependency injection providers
///
/// All services are provided here so they can be injected anywhere
/// in the app using Riverpod's `ref.watch` or `ref.read`.

// Storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return getIt<StorageService>();
});

final databaseServiceProvider = Provider<DatabaseHelper>((ref) {
  return getIt<DatabaseHelper>();
});

// Billing
final billingServiceProvider = Provider<BillingService>((ref) {
  return getIt<BillingService>();
});

// Pet repository
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return getIt<PetRepository>();
});

/// Async provider that initializes all services on app start
final initializationProvider = FutureProvider<void>((ref) async {
  configureDependencies('dev');

  final storageService = ref.read(storageServiceProvider);
  await storageService.init();

  return;
});

/// Top-level provider that watches all initializations
final appServiceProvider = Provider<void>((ref) {
  ref.watch(initializationProvider);
  ref.watch(storageServiceProvider);
  ref.watch(databaseServiceProvider);
  ref.watch(billingServiceProvider);
  ref.watch(petRepositoryProvider);
  ref.watch(petListProvider);
});
