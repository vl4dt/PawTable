import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/colors.dart';
import '../../shared/providers/app_state_provider.dart';
import '../../features/pets/presentation/views/pet_list_view.dart';
import '../../features/pets/presentation/views/pet_detail_view.dart';
import '../../features/pets/presentation/views/add_pet_view.dart';
import '../../features/feeding/presentation/views/feeding_view.dart';
import '../../features/health/presentation/views/health_view.dart';
import '../../features/vaccinations/presentation/views/vaccination_view.dart';
import '../../features/medications/presentation/views/medication_view.dart';
import '../../features/tracking/presentation/views/tracking_view.dart';
import '../../features/calendar/presentation/views/calendar_view.dart';
import '../../features/family/presentation/views/family_view.dart';
import '../../features/premium/presentation/views/premium_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';
import '../../features/home/presentation/views/home_dashboard.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/gamification/presentation/views/streak_view.dart';

// =========================================================================
// Route Definitions
// =========================================================================

/// Centralized route constants
///
/// All path segments, names, and deep-link prefixes are defined here
/// for consistency across the app.
class AppRoutes {
  AppRoutes._();

  // Deep link prefix
  static const String deepLinkPrefix = 'pawtable://';

  // Top-level paths
  static const String onboarding = '/onboarding';
  static const String onboardingWelcome = '$onboarding/welcome';
  static const String onboardingPetSetup = '$onboarding/setup';
  static const String onboardingComplete = '$onboarding/complete';

  // Shell (bottom nav) paths
  static const String home = '/home';
  static const String feed = '/feed';
  static const String track = '/track';
  static const String calendar = '/calendar';
  static const String family = '/family';

  // Full-screen / detail paths
  static const String pets = '/pets';
  static const String petDetail = '/pets/:petId';
  static const String petEdit = '/pets/:petId/edit';
  static const String addPet = '/pets/add';
  static const String petPhotos = '/pets/:petId/photos';
  static const String feeding = '/feed/:petId';
  static const String health = '/health/:petId';
  static const String vaccinations = '/vaccinations/:petId';
  static const String medications = '/medications/:petId';
  static const String tracking = '/tracking/:petId';
  static const String streaks = '/streaks';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String profile = '/profile';

  // Tab bar indices
  static const int tabHome = 0;
  static const int tabFeed = 1;
  static const int tabTrack = 2;
  static const int tabCalendar = 3;
  static const int tabFamily = 4;

  // Tab labels
  static const List<String> tabLabels = [
    'Home',
    'Feed',
    'Track',
    'Calendar',
    'Family',
  ];

  // Tab icons
  static const List<IconData> tabIcons = [
    Icons.home_rounded,
    Icons.restaurant_rounded,
    Icons.trending_up_rounded,
    Icons.calendar_month_rounded,
    Icons.family_restroom_rounded,
  ];
}

// =========================================================================
// Navigation State Tracker (for ShellRoute)
// =========================================================================

/// Tracks the current bottom nav index based on the current location
///
/// This widget is used inside the ShellRoute to sync the bottom nav
/// selection with the URL path.
class _BottomNavTracker extends ConsumerWidget {
  final Widget child;
  const _BottomNavTracker({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).matchedLocation;

    int currentIndex = AppRoutes.tabHome;
    if (location.startsWith(AppRoutes.feed)) currentIndex = AppRoutes.tabFeed;
    if (location.startsWith(AppRoutes.track)) currentIndex = AppRoutes.tabTrack;
    if (location.startsWith(AppRoutes.calendar)) currentIndex = AppRoutes.tabCalendar;
    if (location.startsWith(AppRoutes.family)) currentIndex = AppRoutes.tabFamily;

    return _PawTableShell(
      currentIndex: currentIndex,
      onTabSelected: (index) {
        switch (index) {
          case AppRoutes.tabHome:
            context.go(AppRoutes.home);
            break;
          case AppRoutes.tabFeed:
            context.go(AppRoutes.feed);
            break;
          case AppRoutes.tabTrack:
            context.go(AppRoutes.track);
            break;
          case AppRoutes.tabCalendar:
            context.go(AppRoutes.calendar);
            break;
          case AppRoutes.tabFamily:
            context.go(AppRoutes.family);
            break;
        }
      },
      child: child,
    );
  }
}

/// Shell widget with bottom navigation bar
class _PawTableShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget child;

  const _PawTableShell({
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: PawTableColors.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: AppRoutes.tabLabels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return BottomNavigationBarItem(
            icon: Icon(AppRoutes.tabIcons[index]),
            activeIcon: Icon(AppRoutes.tabIcons[index]),
            label: label,
          );
        }).toList(),
      ),
    );
  }
}

// =========================================================================
// GoRouter Configuration
// =========================================================================

/// Main GoRouter instance for the PawTable app
///
/// Structure:
/// 1. Onboarding flow (conditional, shown if not completed)
/// 2. Shell route with bottom navigation (5 tabs)
/// 3. Full-screen routes (pet detail, settings, premium, etc.)
///
/// Deep linking: pawtable://feed/:petId, pawtable://pets/:petId, etc.
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.onboardingWelcome,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    // Get the provider container from the BuildContext
    final container = ProviderScope.containerOf(context, listen: false);
    final isComplete = container.read(isOnboardingProvider);

    // If not onboarding and not complete, redirect to onboarding
    if (!isComplete &&
        !state.matchedLocation.startsWith(AppRoutes.onboarding) &&
        state.matchedLocation != AppRoutes.home) {
      return AppRoutes.onboardingWelcome;
    }

    // If onboarding is complete and user tries to access onboarding, go to home
    if (isComplete && state.matchedLocation.startsWith(AppRoutes.onboarding)) {
      return AppRoutes.home;
    }

    return null; // No redirect needed
  },
  routes: [
    // =========================================================================
    // Onboarding Routes
    // =========================================================================
    GoRoute(
      path: AppRoutes.onboardingWelcome,
      name: 'onboarding-welcome',
      builder: (context, state) => const OnboardingView(),
    ),

    // =========================================================================
    // Shell Route (Bottom Navigation)
    // =========================================================================
    ShellRoute(
      builder: (context, state, child) {
        return _BottomNavTracker(child: child);
      },
      routes: [
        // Home tab
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeDashboard(),
          routes: [],
        ),
        // Feed tab
        GoRoute(
          path: AppRoutes.feed,
          name: 'feed',
          builder: (context, state) => const FeedingView(petId: 'default'),
        ),
        // Track tab
        GoRoute(
          path: AppRoutes.track,
          name: 'track',
          builder: (context, state) => const TrackingView(petId: 'default'),
        ),
        // Calendar tab
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          builder: (context, state) => const CalendarView(),
        ),
        // Family tab
        GoRoute(
          path: AppRoutes.family,
          name: 'family',
          builder: (context, state) => const FamilyView(),
        ),
      ],
    ),

    // =========================================================================
    // Full-Screen Routes
    // =========================================================================

    // Pet list
    GoRoute(
      path: AppRoutes.pets,
      name: 'pets',
      builder: (context, state) => const PetListView(),
    ),

    // Add pet
    GoRoute(
      path: AppRoutes.addPet,
      name: 'add-pet',
      builder: (context, state) => const AddPetView(),
    ),

    // Pet detail
    GoRoute(
      path: AppRoutes.petDetail,
      name: 'pet-detail',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return PetDetailView(petId: petId);
      },
    ),

    // Pet edit
    GoRoute(
      path: AppRoutes.petEdit,
      name: 'pet-edit',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return AddPetView(editPetId: petId);
      },
    ),



    // Feeding detail
    GoRoute(
      path: AppRoutes.feeding,
      name: 'feeding',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return FeedingView(petId: petId);
      },
    ),

    // Health detail
    GoRoute(
      path: AppRoutes.health,
      name: 'health',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return HealthView(petId: petId);
      },
    ),

    // Vaccinations
    GoRoute(
      path: AppRoutes.vaccinations,
      name: 'vaccinations',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return VaccinationView(petId: petId);
      },
    ),

    // Medications
    GoRoute(
      path: AppRoutes.medications,
      name: 'medications',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return MedicationView(petId: petId);
      },
    ),

    // Tracking
    GoRoute(
      path: AppRoutes.tracking,
      name: 'tracking',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return TrackingView(petId: petId);
      },
    ),

    // Streaks
    GoRoute(
      path: AppRoutes.streaks,
      name: 'streaks',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? 'default';
        return StreakView(petId: petId);
      },
    ),

    // Premium / upgrade
    GoRoute(
      path: AppRoutes.premium,
      name: 'premium',
      builder: (context, state) => const PremiumView(),
    ),

    // Profile / settings
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileView(),
    ),

    // Settings
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
);

// =========================================================================
// Navigation Helper Extension
// =========================================================================

/// Extension on BuildContext for convenient navigation
///
/// Provides typed navigation methods with automatic path building.
/// Example:
/// ```dart
/// context.navigateToPetDetail('pet-123');
/// context.navigateToFeeding('pet-123');
/// ```
extension NavigationX on BuildContext {
  /// Navigate to streaks page
  void navigateToStreaks(String petId) {
    go('${AppRoutes.streaks}?petId=$petId', extra: petId);
  }

  /// Navigate to pet detail page
  void navigateToPetDetail(String petId) {
    go(AppRoutes.petDetail, extra: petId);
  }

  /// Navigate to pet edit page
  void navigateToPetEdit(String petId) {
    go(AppRoutes.petEdit, extra: petId);
  }

  /// Navigate to feeding page
  void navigateToFeeding(String petId) {
    go(AppRoutes.feeding, extra: petId);
  }

  /// Navigate to health page
  void navigateToHealth(String petId) {
    go(AppRoutes.health, extra: petId);
  }

  /// Navigate to vaccinations page
  void navigateToVaccinations(String petId) {
    go(AppRoutes.vaccinations, extra: petId);
  }

  /// Navigate to medications page
  void navigateToMedications(String petId) {
    go(AppRoutes.medications, extra: petId);
  }

  /// Navigate to tracking page
  void navigateToTracking(String petId) {
    go(AppRoutes.tracking, extra: petId);
  }

  /// Navigate to premium/upgrade page
  void navigateToPremium() {
    go(AppRoutes.premium);
  }

  /// Navigate to profile/settings page
  void navigateToProfile() {
    go(AppRoutes.profile);
  }

  /// Navigate to home tab
  void navigateToHome() {
    go(AppRoutes.home);
  }

  /// Navigate to feed tab
  void navigateToFeed() {
    go(AppRoutes.feed);
  }

  /// Navigate to track tab
  void navigateToTrack() {
    go(AppRoutes.track);
  }

  /// Navigate to calendar tab
  void navigateToCalendar() {
    go(AppRoutes.calendar);
  }

  /// Navigate to family tab
  void navigateToFamily() {
    go(AppRoutes.family);
  }

  /// Navigate to pet list
  void navigateToPets() {
    go(AppRoutes.pets);
  }

  /// Navigate to add pet
  void navigateToAddPet() {
    go(AppRoutes.addPet);
  }

  /// Navigate to pet photo gallery
  void navigateToPetPhotos(String petId, {String petName = 'Pet'}) {
    go('${AppRoutes.petPhotos}?name=$petName', extra: petId);
  }

  /// Navigate to onboarding welcome
  void navigateToOnboardingWelcome() {
    go(AppRoutes.onboardingWelcome);
  }

  /// Pop to the previous route
  void popToPrevious() {
    pop();
  }

  /// Replace the current route
  void replaceWith(String route) {
    replace(route);
  }
}
