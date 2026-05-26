import 'package:flutter_test/flutter_test.dart';
import 'package:pawtable/core/utils/constants.dart';

void main() {
  group('AppConstants.appMetadata', () {
    test('has correct app name', () {
      expect(AppConstants.appName, 'PawTable');
    });

    test('has correct tagline', () {
      expect(AppConstants.tagline, 'Your Pet, At Your Table');
    });

    test('has correct package ID', () {
      expect(AppConstants.packageId, 'com.pawtable');
    });

    test('has correct bundle ID', () {
      expect(AppConstants.bundleId, 'com.pawtable.app');
    });
  });

  group('AppConstants.storage', () {
    test('has Hive box names', () {
      expect(AppConstants.settingsBox, 'settings');
      expect(AppConstants.petsBox, 'pets');
      expect(AppConstants.healthBox, 'health');
      expect(AppConstants.feedingBox, 'feeding');
      expect(AppConstants.vaccinationsBox, 'vaccinations');
      expect(AppConstants.medicationsBox, 'medications');
      expect(AppConstants.weightBox, 'weight');
      expect(AppConstants.familyBox, 'family');
    });

    test('has correct database name', () {
      expect(AppConstants.databaseName, 'pawtable.db');
    });
  });

  group('AppConstants.freeTierLimits', () {
    test('has correct free pet limit', () {
      expect(AppConstants.maxFreePets, 1);
    });

    test('has correct free family members limit', () {
      expect(AppConstants.maxFreeFamilyMembers, 2);
    });

    test('has correct free feeding logs limit', () {
      expect(AppConstants.maxFreeFeedingLogs, 30);
    });

    test('has correct free health logs limit', () {
      expect(AppConstants.maxFreeHealthLogs, 20);
    });
  });

  group('AppConstants.premiumPlans', () {
    test('has correct plan IDs', () {
      expect(AppConstants.premiumPlanId, 'monthly');
      expect(AppConstants.premiumPlanAnnualId, 'annual');
      expect(AppConstants.familyPlanId, 'family-annual');
    });

    test('has correct RevenueCat product IDs', () {
      expect(AppConstants.revenueCatMonthly, 'com.pawtable.monthly');
      expect(AppConstants.revenueCatAnnual, 'com.pawtable.annual');
      expect(AppConstants.revenueCatFamily, 'com.pawtable.family');
    });
  });

  group('AppConstants.defaults', () {
    test('has correct default weight unit', () {
      expect(AppConstants.defaultWeightUnit, 'kg');
    });

    test('has correct default food unit', () {
      expect(AppConstants.defaultFoodUnit, 'g');
    });

    test('has correct default dosage unit', () {
      expect(AppConstants.defaultDosageUnit, 'mg');
    });

    test('has correct default temperature unit', () {
      expect(AppConstants.defaultTemperatureUnit, 'celsius');
    });

    test('has correct default reminder hours', () {
      expect(AppConstants.defaultReminderHours, 24);
    });

    test('has correct default theme', () {
      expect(AppConstants.defaultTheme, 'system');
    });
  });

  group('AppConstants.dateFormats', () {
    test('has ISO 8601 pattern', () {
      expect(AppConstants.iso8601Pattern, "yyyy-MM-dd'T'HH:mm:ss.SSS");
    });

    test('has full date pattern', () {
      expect(AppConstants.fullDatePattern, 'MMMM d, yyyy');
    });

    test('has short date pattern', () {
      expect(AppConstants.shortDatePattern, 'MMM d');
    });

    test('has time pattern', () {
      expect(AppConstants.timePattern, 'h:mm a');
    });
  });

  group('AppConstants.vaccinationIntervals', () {
    test('has rabies interval', () {
      expect(AppConstants.rabiesIntervalMonths, 12);
    });

    test('has DHPP interval', () {
      expect(AppConstants.dhppIntervalMonths, 12);
    });

    test('has bordetella interval', () {
      expect(AppConstants.bordetellaIntervalMonths, 6);
    });

    test('has FVRCP interval', () {
      expect(AppConstants.fvrCpIntervalMonths, 12);
    });
  });

  group('AppConstants.feedingSchedules', () {
    test('has puppy/kitten feeding frequency', () {
      expect(AppConstants.puppyKittenFeedings, 3);
    });

    test('has adult dog feeding frequency', () {
      expect(AppConstants.adultDogFeedings, 2);
    });

    test('has adult cat feeding frequency', () {
      expect(AppConstants.adultCatFeedings, 2);
    });

    test('has senior pet feeding frequency', () {
      expect(AppConstants.seniorPetFeedings, 2);
    });
  });

  group('AppConstants.medicationFrequencies', () {
    test('has once daily', () {
      expect(AppConstants.onceDaily, 'once_daily');
    });

    test('has twice daily', () {
      expect(AppConstants.twiceDaily, 'twice_daily');
    });

    test('has three times daily', () {
      expect(AppConstants.threeTimesDaily, 'three_times_daily');
    });

    test('has every 8 hours', () {
      expect(AppConstants.every8Hours, 'every_8_hours');
    });

    test('has as needed', () {
      expect(AppConstants.asNeeded, 'as_needed');
    });
  });

  group('AppConstants.healthLogTypes', () {
    test('has general log type', () {
      expect(AppConstants.healthLogGeneral, 'general');
    });

    test('has illness log type', () {
      expect(AppConstants.healthLogIllness, 'illness');
    });

    test('has surgery log type', () {
      expect(AppConstants.healthLogSurgery, 'surgery');
    });

    test('has vet visit log type', () {
      expect(AppConstants.healthLogVetVisit, 'vet_visit');
    });
  });

  group('AppConstants.medicationRoutes', () {
    test('has oral route', () {
      expect(AppConstants.routeOral, 'oral');
    });

    test('has topical route', () {
      expect(AppConstants.routeTopical, 'topical');
    });

    test('has injectable route', () {
      expect(AppConstants.routeInjectable, 'injectable');
    });
  });

  group('AppConstants.errorMessages', () {
    test('has default error message', () {
      expect(AppConstants.defaultErrorMessage, 'Something went wrong. Please try again.');
    });

    test('has network error message', () {
      expect(AppConstants.networkErrorMessage, 'No internet connection. Please check your network settings.');
    });

    test('has timeout error message', () {
      expect(AppConstants.timeoutErrorMessage, 'Request timed out. Please try again.');
    });
  });

  group('AppConstants.analyticsEvents', () {
    test('has onboarding complete event', () {
      expect(AppConstants.eventOnboardingComplete, 'onboarding_complete');
    });

    test('has pet added event', () {
      expect(AppConstants.eventPetAdded, 'pet_added');
    });

    test('has feeding logged event', () {
      expect(AppConstants.eventFeedingLogged, 'feeding_logged');
    });

    test('has vaccination logged event', () {
      expect(AppConstants.eventVaccinationLogged, 'vaccination_logged');
    });

    test('has weight logged event', () {
      expect(AppConstants.eventWeightLogged, 'weight_logged');
    });
  });

  group('AppConstants.sharing', () {
    test('has support email', () {
      expect(AppConstants.supportEmail, 'support@pawtable.com');
    });

    test('has privacy policy URL', () {
      expect(AppConstants.privacyPolicyUrl, 'https://pawtable.com/privacy');
    });

    test('has terms of service URL', () {
      expect(AppConstants.termsOfServiceUrl, 'https://pawtable.com/terms');
    });

    test('has Android app store URL', () {
      expect(AppConstants.appStoreUrlAndroid, contains('play.google.com'));
    });

    test('has iOS app store URL', () {
      expect(AppConstants.appStoreUrlIos, contains('apps.apple.com'));
    });
  });
}
