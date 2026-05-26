import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/shared/widgets/loading_indicator.dart'
    as paw_widgets;

void main() {
  group('PawTable ErrorWidget', () {
    testWidgets('renders error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: paw_widgets.ErrorWidget(message: 'Something went wrong'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify error widget renders
      expect(find.byType(paw_widgets.ErrorWidget), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: paw_widgets.ErrorWidget(message: 'Error occurred'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify error icon is shown
      expect(find.byType(paw_widgets.ErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when callback provided',
        (WidgetTester tester) async {
      var retried = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: paw_widgets.ErrorWidget(
                message: 'Connection failed',
                onRetry: () => retried = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap retry button
      final retryFinder = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryFinder, findsOneWidget);

      await tester.tap(retryFinder);
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('does not show retry button when callback is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: paw_widgets.ErrorWidget(
                message: 'Error without retry',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify error message is shown
      expect(find.text('Error without retry'), findsOneWidget);

      // Verify no retry button
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsNothing);
    });

    testWidgets('renders in list view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  paw_widgets.ErrorWidget(message: 'Network error'),
                  Text('Item 1'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(paw_widgets.ErrorWidget), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
