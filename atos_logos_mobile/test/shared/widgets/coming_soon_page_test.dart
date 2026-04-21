import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/shared/widgets/coming_soon_page.dart';

void main() {
  group('ComingSoonPage', () {
    testWidgets('should display "Em breve" title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );
      expect(find.text('Em breve'), findsOneWidget);
    });

    testWidgets('should display subtitle message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );
      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsOneWidget,
      );
    });

    testWidgets('should display an icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should accept optional custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ComingSoonPage(title: 'Notificações')),
        ),
      );
      expect(find.text('Notificações'), findsOneWidget);
    });
  });
}
