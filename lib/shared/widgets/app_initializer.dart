import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart' show initializationProvider;
import '../../main.dart' show PawTableApp;

/// App initializer widget
///
/// Handles app startup sequence:
/// 1. Initialize Firebase (gracefully skips if config is placeholder)
/// 2. Initialize DI container (GetIt)
/// 3. Initialize local storage (Hive, SQLite)
/// 4. Load user preferences
/// 5. Check for pending syncs
/// 6. Display splash screen until ready
class AppInitializer extends ConsumerWidget {
  final Widget child;
  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(initializationProvider);

    return initialization.when(
      data: (_) => child,
      loading: () => const SplashScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}

/// Splash screen shown during app initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'PawTable',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Pet, At Your Table',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown if initialization fails
class ErrorScreen extends StatelessWidget {
  final dynamic error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Re-run the app without the initializer
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const PawTableApp(),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
