import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/shared/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders circular progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator renders
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows centered layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify it's wrapped in a Center widget
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('shows custom message when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingIndicator(message: 'Loading pets...'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator renders
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading pets...'), findsOneWidget);
    });

    testWidgets('hides message when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator renders but no message
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('uses custom size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingIndicator(size: 80),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator renders
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('can be used in column',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  Text('Previous content'),
                  LoadingIndicator(message: 'Loading...'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });
  });
}
