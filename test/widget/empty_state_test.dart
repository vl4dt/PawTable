import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/shared/widgets/loading_indicator.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EmptyState(title: 'No pets added yet'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify empty state renders
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No pets added yet'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EmptyState(
                title: 'No data',
                subtitle: 'Add a pet to get started',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Add a pet to get started'), findsOneWidget);
    });

    testWidgets('hides subtitle when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const EmptyState(
                title: 'No data',
                subtitle: null,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      // No subtitle text should appear
      expect(find.text('Add a pet to get started'), findsNothing);
    });

    testWidgets('shows action button when callback and text provided',
        (WidgetTester tester) async {
      var actionTaken = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EmptyState(
                title: 'No pets',
                subtitle: 'Add your first pet',
                buttonText: 'Add Pet',
                onButtonTap: () => actionTaken = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap action button
      final actionFinder = find.widgetWithText(ElevatedButton, 'Add Pet');
      expect(actionFinder, findsOneWidget);

      await tester.tap(actionFinder);
      await tester.pump();

      expect(actionTaken, isTrue);
    });

    testWidgets('does not show action button when callback is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const EmptyState(
                title: 'No pets',
                buttonText: 'Add Pet',
                onButtonTap: null,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify title is shown
      expect(find.text('No pets'), findsOneWidget);

      // Verify no action button
      expect(find.widgetWithText(ElevatedButton, 'Add Pet'), findsNothing);
    });

    testWidgets('does not show action button when button text is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EmptyState(
                title: 'No pets',
                buttonText: null,
                onButtonTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No pets'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders with custom icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const EmptyState(
                title: 'Nothing here',
                icon: Icons.pets,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify empty state renders
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('renders with default inbox icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const EmptyState(
                title: 'Empty',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders in list view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  EmptyState(title: 'Empty list'),
                  Text('Footer'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Empty list'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });
  });
}
