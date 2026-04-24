import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/ebd/presentation/pages/ebd_attendance_page.dart';

void main() {
  group('EbdAttendancePage', () {
    Future<void> setTallSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    testWidgets(
      'should render lesson call sheet with students and footer controls',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: EbdAttendancePage())),
        );

        expect(find.text('Lição 04: O Bom Samaritano'), findsOneWidget);
        expect(find.text('Data: 26/04/2026'), findsOneWidget);
        expect(find.text('Marcar todos como presentes'), findsOneWidget);
        expect(find.text('LISTA DE ALUNOS'), findsOneWidget);
        expect(find.text('Adriano Silva'), findsOneWidget);
        expect(find.text('Beatriz Oliveira'), findsOneWidget);
        expect(find.text('Carlos Eduardo'), findsOneWidget);
        expect(find.text('Daniela Santos'), findsOneWidget);
        expect(find.text('VISITANTES'), findsNothing);
        expect(find.text('OFERTA DA CLASSE'), findsOneWidget);
        expect(find.text('Finalizar Chamada'), findsOneWidget);
      },
    );

    testWidgets(
      'should mark all students as present when the bulk action is tapped',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: EbdAttendancePage())),
        );

        expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);
        expect(tester.widget<Switch>(find.byType(Switch).at(2)).value, isFalse);

        await tester.tap(find.text('Marcar todos como presentes'));
        await tester.pump();

        for (var index = 0; index < 4; index++) {
          expect(
            tester.widget<Switch>(find.byType(Switch).at(index)).value,
            isTrue,
          );
        }
      },
    );

    testWidgets('should show confirmation on finish without visitor controls', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EbdAttendancePage())),
      );

      expect(find.byKey(const Key('visitors_increment')), findsNothing);

      await tester.tap(find.text('Finalizar Chamada'));
      await tester.pump();

      expect(find.text('Chamada finalizada'), findsOneWidget);
    });
  });
}
