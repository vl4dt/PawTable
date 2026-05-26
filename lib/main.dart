import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_service.dart';
import 'core/sentry/sentry_service.dart';
import 'core/theme/themes.dart';
import 'core/navigation/routes.dart';
import 'shared/providers/app_state_provider.dart';
import 'shared/widgets/app_initializer.dart';

/// PawTable — Your Pet, At Your Table
///
/// Main entry point. Initializes Sentry, Firebase, and sets up Riverpod,
/// configures the theme and router, and runs the app.
///
/// Architecture: Clean Architecture with Riverpod state management.
/// See PROJECT-DESIGN.md for full architecture details.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry crash reporting (graceful degradation if DSN is empty)
  final sentryService = SentryService();
  final String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  try {
    await sentryService.initialize(
      dsn: sentryDsn,
      tracesSampleRate: 1.0,
    );
  } catch (e) {
    debugPrint('Sentry init failed: $e');
  }

  // Initialize Firebase (gracefully skips if config is placeholder)
  final firebaseService = FirebaseService();
  try {
    await firebaseService.initialize();
  } catch (e) {
    // App continues in offline-only mode
    debugPrint('Firebase init failed (offline mode): $e');
  }

  runApp(
    ProviderScope(
      child: PawTableApp(),
    ),
  );
}

class PawTableApp extends StatelessWidget {
  const PawTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);

        return MaterialApp.router(
          title: 'PawTable',
          debugShowCheckedModeBanner: false,
          theme: PawThemes.lightTheme,
          darkTheme: PawThemes.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          builder: (context, child) {
            if (child != null) {
              return SentryErrorBoundary(
                child: AppInitializer(child: child),
                fallbackBuilder: (ctx, err) => _buildFallback(ctx, err),
              );
            }
            return child!;
          },
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context, dynamic error) {
    return MaterialApp(
      title: 'PawTable',
      debugShowCheckedModeBanner: false,
      theme: PawThemes.lightTheme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Something went wrong. Please restart the app.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Future.microtask(
                  () => throw Exception('Restart requested'),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
