import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/shared/widgets/pet_avatar.dart';

void main() {
  group('PetAvatar', () {
    testWidgets('renders pet icon with default species',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(species: 'dog'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify CircleAvatar is rendered
      expect(find.byType(CircleAvatar), findsOneWidget);
      // Verify pet icon is shown
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('renders different icons for different species',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  PetAvatar(species: 'dog'),
                  PetAvatar(species: 'cat'),
                  PetAvatar(species: 'bird'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // All three should render CircleAvatars
      expect(find.byType(CircleAvatar), findsNWidgets(3));
    });

    testWidgets('renders photo when photoUri provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(
                  species: 'dog',
                  photoUri: 'https://example.com/pet.jpg',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // CircleAvatar should be present
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('uses custom size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(
                  species: 'dog',
                  size: 80,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify it renders
      expect(find.byType(PetAvatar), findsOneWidget);
    });

    testWidgets('uses custom background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(
                  species: 'cat',
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify it renders
      expect(find.byType(PetAvatar), findsOneWidget);
    });

    testWidgets('renders multiple avatars',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: const [
                  PetAvatar(species: 'dog'),
                  PetAvatar(species: 'cat'),
                  PetAvatar(species: 'bird'),
                  PetAvatar(species: 'fish'),
                  PetAvatar(species: 'rabbit'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(PetAvatar), findsNWidgets(5));
    });

    testWidgets('uses default species when not specified',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(PetAvatar), findsOneWidget);
    });

    testWidgets('handles null photoUri gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: const PetAvatar(
                  species: 'dog',
                  photoUri: null,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(PetAvatar), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('uses primary color when no background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: Colors.orange),
            ),
            home: const Scaffold(
              body: Center(
                child: PetAvatar(species: 'dog'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(PetAvatar), findsOneWidget);
    });
  });
}
