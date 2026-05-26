import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawtable/shared/widgets/quick_log_button.dart';

void main() {
  group('QuickLogButton', () {
    testWidgets('renders button with icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickLogButton(
                  icon: Icons.restaurant,
                  label: 'Feed',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify button renders
      expect(find.byType(QuickLogButton), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickLogButton(
                  icon: Icons.restaurant,
                  label: 'Feed',
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap the button
      await tester.tap(find.byType(QuickLogButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('uses custom icon color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickLogButton(
                  icon: Icons.restaurant,
                  label: 'Feed',
                  iconColor: Colors.red,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify button is rendered
      expect(find.byType(QuickLogButton), findsOneWidget);
    });

    testWidgets('handles long label text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickLogButton(
                  icon: Icons.restaurant,
                  label: 'A Very Long Label That Should Be Handled',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify button is rendered
      expect(find.byType(QuickLogButton), findsOneWidget);
    });

    testWidgets('renders as InkWell',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickLogButton(
                  icon: Icons.medication,
                  label: 'Meds',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify InkWell is part of the widget tree
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('renders multiple buttons in a row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  QuickLogButton(
                    icon: Icons.restaurant,
                    label: 'Feed',
                    onTap: () {},
                  ),
                  QuickLogButton(
                    icon: Icons.medication,
                    label: 'Meds',
                    onTap: () {},
                  ),
                  QuickLogButton(
                    icon: Icons.scale,
                    label: 'Weight',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify all buttons render
      expect(find.byType(QuickLogButton), findsNWidgets(3));
    });
  });

  group('QuickActionRow', () {
    testWidgets('renders list of quick log buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickActionRow(
                buttons: [
                  QuickLogButton(
                    icon: Icons.restaurant,
                    label: 'Feed',
                    onTap: () {},
                  ),
                  QuickLogButton(
                    icon: Icons.medication,
                    label: 'Meds',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify QuickActionRow renders
      expect(find.byType(QuickActionRow), findsOneWidget);
      expect(find.byType(QuickLogButton), findsNWidgets(2));
    });

    testWidgets('renders horizontal scrollable list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickActionRow(
                buttons: List.generate(
                  5,
                  (index) => QuickLogButton(
                    icon: Icons.pets,
                    label: 'Action $index',
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify QuickActionRow renders
      expect(find.byType(QuickActionRow), findsOneWidget);
      expect(find.byType(QuickLogButton), findsNWidgets(5));

      // Verify it uses ListView for horizontal scrolling
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders single button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickActionRow(
                buttons: [
                  QuickLogButton(
                    icon: Icons.restaurant,
                    label: 'Feed',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(QuickActionRow), findsOneWidget);
      expect(find.byType(QuickLogButton), findsOneWidget);
    });

    testWidgets('renders empty buttons list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const QuickActionRow(buttons: []),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(QuickActionRow), findsOneWidget);
      expect(find.byType(QuickLogButton), findsNothing);
    });
  });
}
