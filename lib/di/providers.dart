import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/storage_service.dart';
import '../core/storage/database_helper.dart';
import '../core/billing/billing_service.dart';
import '../core/adapters/hive_adapters.dart';
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
///
/// 1. Registers Hive value adapters for typed storage.
/// 2. Initializes the GetIt DI container.
/// 3. Opens all Hive boxes via StorageService.
/// 4. Returns when all initialization is complete.
final initializationProvider = FutureProvider<void>((ref) async {
  // 1. Register Hive adapters (must be done before opening any boxes)
  registerAdapters();

  // 2. Configure DI container
  configureDependencies('dev');

  // 3. Initialize storage (opens all Hive boxes)
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
