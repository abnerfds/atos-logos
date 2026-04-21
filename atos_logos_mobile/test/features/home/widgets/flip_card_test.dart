import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/features/home/presentation/widgets/flip_card.dart';

void main() {
  group('FlipCard', () {
    testWidgets('should show front side by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );
      expect(find.text('Front'), findsOneWidget);
    });

    testWidgets('should flip to back on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('should flip back to front on second tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();
      expect(find.text('Front'), findsOneWidget);
    });
  });
}
