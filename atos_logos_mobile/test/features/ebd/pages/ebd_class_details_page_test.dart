import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:atos_logos_mobile/features/ebd/presentation/pages/ebd_class_details_page.dart';

void main() {
  group('EbdClassDetailsPage', () {
    testWidgets('should render class identity and lessons timeline', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EbdClassDetailsPage())),
      );

      expect(find.text('ESCOLA BÍBLICA DOMINICAL'), findsOneWidget);
      expect(find.text('As Parábolas de Jesus'), findsOneWidget);
      expect(find.text('Prof. Ricardo Mendes'), findsOneWidget);
      expect(find.text('4º Trimestre 2023'), findsOneWidget);
      expect(find.text('Cronograma de Lições'), findsOneWidget);
      expect(find.text('O Semeador e os Solos'), findsOneWidget);
      expect(find.text('O Joio e o Trigo'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('A Pérola de Grande Valor'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('A Pérola de Grande Valor'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Ver todas as 13 lições'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Ver todas as 13 lições'), findsOneWidget);
    });

    testWidgets('should navigate to attendance from the highlighted lesson', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/details',
        routes: [
          GoRoute(
            path: '/details',
            builder: (context, state) =>
                const Scaffold(body: EbdClassDetailsPage()),
          ),
          GoRoute(
            path: '/ebd/classes/:id/lessons/:lessonId/attendance',
            builder: (context, state) =>
                const Scaffold(body: Text('ATTENDANCE_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.scrollUntilVisible(
        find.byKey(const Key('take_attendance_button')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('take_attendance_button')));
      await tester.pumpAndSettle();

      expect(find.text('ATTENDANCE_PAGE'), findsOneWidget);
    });
  });
}
