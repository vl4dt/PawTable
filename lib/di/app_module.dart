import 'package:get_it/get_it.dart';
import '../core/storage/database_helper.dart';
import '../core/storage/storage_service.dart';
import '../core/billing/billing_service.dart';
import '../features/pets/data/data_sources/pet_local_data_source.dart';
import '../features/pets/data/repositories/pet_repository_impl.dart';
import '../features/pets/domain/repositories/pet_repository.dart';
import '../features/onboarding/domain/services/onboarding_service.dart';
import '../features/gamification/domain/services/achievement_unlock_service.dart';
import '../features/gamification/data/repositories/achievement_count_providers.dart';
import '../features/gamification/data/repositories/achievement_event_repository_impl.dart';
import '../features/gamification/domain/repositories/achievement_event_repository.dart';
import '../features/gamification/domain/repositories/milestone_repository.dart';
import '../features/gamification/data/repositories/milestone_repository_impl.dart';
import '../features/gamification/data/repositories/streak_repository_impl.dart';
import '../features/gamification/domain/repositories/streak_repository.dart';
import '../features/family/data/repositories/family_repository_impl.dart';
import '../features/family/data/repositories/invite_repository_impl.dart';
import '../features/family/data/repositories/activity_feed_repository_impl.dart';
import '../features/family/domain/repositories/family_repository.dart';
import '../features/family/domain/repositories/invite_repository.dart';
import '../features/family/domain/repositories/activity_feed_repository.dart';
import '../features/pets/data/repositories/shared_pet_profile_repository_impl.dart';
import '../features/pets/domain/repositories/shared_pet_profile_repository.dart';
import '../features/pets/data/repositories/pet_sitter_access_repository_impl.dart';
import '../features/pets/domain/repositories/pet_sitter_access_repository.dart';
import '../features/family/data/services/firestore_sync_service.dart';
import '../features/family/domain/repositories/sync_repository.dart';

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
    )

    // Gamification (Streaks + Milestones + Achievement System)
    ..registerFactory<StreakRepository>(
      () => StreakRepositoryImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<MilestoneRepository>(
      () => MilestoneRepositoryImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<AchievementEventRepository>(
      () => AchievementEventRepositoryImpl(
        dbHelper: getIt<DatabaseHelper>(),
      ),
    )
    ..registerFactory<FeedingCountProvider>(
      () => FeedingCountProviderImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<HealthCountProvider>(
      () => HealthCountProviderImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<MedicationCountProvider>(
      () => MedicationCountProviderImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<WeightCountProvider>(
      () => WeightCountProviderImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<BehaviorCountProvider>(
      () => BehaviorCountProviderImpl(dbHelper: getIt<DatabaseHelper>()),
    )

    // Family Collaboration
    ..registerFactory<FamilyRepository>(
      () => FamilyRepositoryImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<InviteRepository>(
      () => InviteRepositoryImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<ActivityFeedRepository>(
      () => ActivityFeedRepositoryImpl(dbHelper: getIt<DatabaseHelper>()),
    )
    ..registerFactory<SharedPetProfileRepository>(
      () => SharedPetProfileRepositoryImpl(
        dbHelper: getIt<DatabaseHelper>(),
      ),
    )
    ..registerFactory<PetSitterAccessRepository>(
      () => PetSitterAccessRepositoryImpl(
        dbHelper: getIt<DatabaseHelper>(),
      ),
    )
    ..registerLazySingleton<FamilySyncRepository>(
      () => FirestoreSyncService(
        userId: 'user-current',
      ),
    );
}
