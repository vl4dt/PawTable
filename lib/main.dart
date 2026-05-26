import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/themes.dart';
import 'core/navigation/routes.dart';
import 'shared/providers/app_state_provider.dart';
import 'shared/widgets/app_initializer.dart';

/// PawTable — Your Pet, At Your Table
///
/// Main entry point. Initializes Flutter, sets up Riverpod,
/// configures the theme and router, and runs the app.
///
/// Architecture: Clean Architecture with Riverpod state management.
/// See PROJECT-DESIGN.md for full architecture details.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase (see PROJECT-DESIGN.md)
  // await Firebase.initializeApp();

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
              return AppInitializer(child: child);
            }
            return child!;
          },
        );
      },
    );
  }
}
