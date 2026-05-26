/// PawTable app-wide constants
///
/// All magic numbers, default values, and configuration constants
/// are defined here to avoid scattering them across the codebase.
class AppConstants {
  AppConstants._();

  // =========================================================================
  // APP METADATA
  // =========================================================================

  /// App display name
  static const String appName = 'PawTable';

  /// App tagline
  static const String tagline = 'Your Pet, At Your Table';

  /// Package name (Android)
  static const String packageId = 'com.pawtable';

  /// Bundle ID (iOS)
  static const String bundleId = 'com.pawtable.app';

  // =========================================================================
  // STORAGE
  // =========================================================================

  /// Hive box names
  static const String settingsBox = 'settings';
  static const String petsBox = 'pets';
  static const String healthBox = 'health';
  static const String feedingBox = 'feeding';
  static const String vaccinationsBox = 'vaccinations';
  static const String medicationsBox = 'medications';
  static const String weightBox = 'weight';
  static const String familyBox = 'family';

  /// SQLite database file name
  static const String databaseName = 'pawtable.db';

  // =========================================================================
  // FREE TIER LIMITS
  // =========================================================================

  /// Maximum pets allowed in free tier
  static const int maxFreePets = 1;

  /// Maximum family members allowed in free tier
  static const int maxFreeFamilyMembers = 2;

  /// Maximum feeding logs per pet (free tier)
  static const int maxFreeFeedingLogs = 30;

  /// Maximum health logs per pet (free tier)
  static const int maxFreeHealthLogs = 20;

  // =========================================================================
  // PREMIUM FEATURES
  // =========================================================================

  /// Premium plan ID (monthly)
  static const String premiumPlanId = 'monthly';

  /// Premium plan ID (annual)
  static const String premiumPlanAnnualId = 'annual';

  /// Family plan ID
  static const String familyPlanId = 'family-annual';

  /// RevenueCat product IDs
  static const String revenueCatMonthly = 'com.pawtable.monthly';
  static const String revenueCatAnnual = 'com.pawtable.annual';
  static const String revenueCatFamily = 'com.pawtable.family';

  // =========================================================================
  // DEFAULT VALUES
  // =========================================================================

  /// Default weight unit (metric)
  static const String defaultWeightUnit = 'kg';

  /// Default food amount unit
  static const String defaultFoodUnit = 'g';

  /// Default medication dosage unit
  static const String defaultDosageUnit = 'mg';

  /// Default temperature unit (Celsius)
  static const String defaultTemperatureUnit = 'celsius';

  /// Default notification reminder hours
  static const int defaultReminderHours = 24;

  /// Default theme mode
  static const String defaultTheme = 'system';

  // =========================================================================
  // DATE & TIME
  // =========================================================================

  /// ISO 8601 format pattern
  static const String iso8601Pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS";

  /// Full date format pattern
  static const String fullDatePattern = 'MMMM d, yyyy';

  /// Short date format pattern
  static const String shortDatePattern = 'MMM d';

  /// Time format pattern
  static const String timePattern = 'h:mm a';

  /// Date-time format pattern
  static const String dateTimePattern = 'MMM d, h:mm a';

  // =========================================================================
  // VACCINATION INTERVALS (months)
  // =========================================================================

  /// Rabies vaccination interval
  static const int rabiesIntervalMonths = 12;

  /// DHPP (dog) vaccination interval
  static const int dhppIntervalMonths = 12;

  /// Bordetella (dog) vaccination interval
  static const int bordetellaIntervalMonths = 6;

  /// FVRCP (cat) vaccination interval
  static const int fvrCpIntervalMonths = 12;

  /// FeLV (cat) vaccination interval
  static const int felvIntervalMonths = 12;

  /// Core vaccination interval (general)
  static const int coreVaccineIntervalMonths = 12;

  // =========================================================================
  // FEEDING SCHEDULES
  // =========================================================================

  /// Puppies/kittens feeding frequency (times per day)
  static const int puppyKittenFeedings = 3;

  /// Adult dog feeding frequency (times per day)
  static const int adultDogFeedings = 2;

  /// Adult cat feeding frequency (times per day)
  static const int adultCatFeedings = 2;

  /// Senior pet feeding frequency (times per day)
  static const int seniorPetFeedings = 2;

  // =========================================================================
  // MEDICATION FREQUENCIES
  // =========================================================================

  /// Once daily
  static const String onceDaily = 'once_daily';

  /// Twice daily
  static const String twiceDaily = 'twice_daily';

  /// Three times daily
  static const String threeTimesDaily = 'three_times_daily';

  /// Every 8 hours
  static const String every8Hours = 'every_8_hours';

  /// Every 12 hours
  static const String every12Hours = 'every_12_hours';

  /// Weekly
  static const String weekly = 'weekly';

  /// Monthly
  static const String monthly = 'monthly';

  /// As needed
  static const String asNeeded = 'as_needed';

  // =========================================================================
  // HEALTH LOG TYPES
  // =========================================================================

  /// General health log
  static const String healthLogGeneral = 'general';

  /// Illness log
  static const String healthLogIllness = 'illness';

  /// Injury log
  static const String healthLogInjury = 'injury';

  /// Surgery log
  static const String healthLogSurgery = 'surgery';

  /// Vet visit log
  static const String healthLogVetVisit = 'vet_visit';

  /// Behavior log
  static const String healthLogBehavior = 'behavior';

  // =========================================================================
  // MEDICATION ROUTES
  // =========================================================================

  /// Oral
  static const String routeOral = 'oral';

  /// Topical
  static const String routeTopical = 'topical';

  /// Injectable
  static const String routeInjectable = 'injectable';

  /// Ophthalmic (eye drops)
  static const String routeOphthalmic = 'ophthalmic';

  /// Otic (ear drops)
  static const String routeOtic = 'otic';

  /// Inhalant
  static const String routeInhalant = 'inhalant';

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Default error message
  static const String defaultErrorMessage = 'Something went wrong. Please try again.';

  /// Network error message
  static const String networkErrorMessage = 'No internet connection. Please check your network settings.';

  /// Timeout error message
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';

  // =========================================================================
  // ANALYTICS EVENT NAMES
  // =========================================================================

  /// User completed onboarding
  static const String eventOnboardingComplete = 'onboarding_complete';

  /// User added a pet
  static const String eventPetAdded = 'pet_added';

  /// User logged feeding
  static const String eventFeedingLogged = 'feeding_logged';

  /// User logged vaccination
  static const String eventVaccinationLogged = 'vaccination_logged';

  /// User logged medication
  static const String eventMedicationLogged = 'medication_logged';

  /// User logged weight
  static const String eventWeightLogged = 'weight_logged';

  /// User viewed premium page
  static const String eventPremiumViewed = 'premium_viewed';

  /// User started subscription
  static const String eventSubscriptionStarted = 'subscription_started';

  /// User completed subscription
  static const String eventSubscriptionCompleted = 'subscription_completed';

  // =========================================================================
  // SHARING
  // =========================================================================

  /// App store URL (Google Play)
  static const String appStoreUrlAndroid = 'https://play.google.com/store/apps/details?id=$packageId';

  /// App store URL (Apple App Store)
  static const String appStoreUrlIos = 'https://apps.apple.com/app/pawtable/idplaceholder';

  /// Support email
  static const String supportEmail = 'support@pawtable.com';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://pawtable.com/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://pawtable.com/terms';
}
