import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App route definitions for PawTable
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String pets = '/pets';
  static const String petDetail = '/pets/:id';
  static const String track = '/track';
  static const String healthDetail = '/health/:petId';
  static const String calendar = '/calendar';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String profile = '/profile';

  static const List<String> tabRoutes = [
    home,
    track,
    calendar,
    family,
  ];
}

/// GoRouter configuration (placeholder — to be filled as features are implemented)
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    // Onboarding (shown once)
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (_, _) => const _PlaceholderWidget('Onboarding'),
      routes: [
        // To be added: pet type selection, breed selection, pet name entry
      ],
    ),
    // Main app (bottom navigation)
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (_, _) => const _PlaceholderWidget('Home'),
        ),
        GoRoute(
          path: AppRoutes.track,
          name: 'track',
          builder: (_, _) => const _PlaceholderWidget('Track'),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          builder: (_, _) => const _PlaceholderWidget('Calendar'),
        ),
        GoRoute(
          path: AppRoutes.family,
          name: 'family',
          builder: (_, _) => const _PlaceholderWidget('Family'),
        ),
      ],
    ),
    // Full-screen routes
    GoRoute(
      path: AppRoutes.pets,
      name: 'pets',
      builder: (_, _) => const _PlaceholderWidget('Pets List'),
    ),
    GoRoute(
      path: AppRoutes.petDetail,
      name: 'pet-detail',
      builder: (_, _) => const _PlaceholderWidget('Pet Detail'),
    ),
    GoRoute(
      path: AppRoutes.healthDetail,
      name: 'health-detail',
      builder: (_, _) => const _PlaceholderWidget('Health Detail'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (_, _) => const _PlaceholderWidget('Settings'),
    ),
    GoRoute(
      path: AppRoutes.premium,
      name: 'premium',
      builder: (_, _) => const _PlaceholderWidget('Premium'),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (_, _) => const _PlaceholderWidget('Profile'),
    ),
  ],
);

class _PlaceholderWidget extends StatelessWidget {
  final String title;
  const _PlaceholderWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
