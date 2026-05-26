import 'package:get_it/get_it.dart';
import '../core/storage/database_helper.dart';
import '../core/storage/storage_service.dart';
import '../core/billing/billing_service.dart';
import '../features/pets/data/data_sources/pet_local_data_source.dart';
import '../features/pets/data/repositories/pet_repository_impl.dart';
import '../features/pets/domain/repositories/pet_repository.dart';
import '../features/onboarding/domain/services/onboarding_service.dart';

/// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Configure dependency injection
void configureDependencies(String env) {
  // Storage layer
  getIt
    ..registerFactory<StorageService>(() => StorageService())
    ..registerLazySingleton<DatabaseHelper>(() => DatabaseHelper())

    // Billing
    ..registerFactory<BillingService>(
      () => BillingService(),
    )

    // Pet data source
    ..registerFactory<PetLocalDataSource>(
      () => PetLocalDataSource(
        dbHelper: getIt<DatabaseHelper>(),
        storageService: getIt<StorageService>(),
      ),
    )

    // Pet repository
    ..registerFactory<PetRepository>(
      () => PetRepositoryImpl(dataSource: getIt<PetLocalDataSource>()),
    )

    // Onboarding
    ..registerFactory<OnboardingService>(
      () => OnboardingService(storageService: getIt<StorageService>()),
    );
}
