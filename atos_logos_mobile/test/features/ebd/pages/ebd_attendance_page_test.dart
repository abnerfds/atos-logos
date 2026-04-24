import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_attendance_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/pages/ebd_attendance_page.dart';

class _MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late _MockEbdRepository repository;

  final students = [
    EbdAttendanceEntry(memberId: 'u-1', name: 'Adriano Silva', isPresent: true),
    EbdAttendanceEntry(
      memberId: 'u-2',
      name: 'Beatriz Oliveira',
      isPresent: false,
    ),
    EbdAttendanceEntry(
      memberId: 'u-3',
      name: 'Carlos Eduardo',
      isPresent: false,
    ),
    EbdAttendanceEntry(
      memberId: 'u-4',
      name: 'Daniela Santos',
      isPresent: true,
    ),
  ];

  setUp(() {
    repository = _MockEbdRepository();
    if (getIt.isRegistered<EbdAttendanceCubit>()) {
      getIt.unregister<EbdAttendanceCubit>();
    }
    getIt.registerFactory<EbdAttendanceCubit>(
      () => EbdAttendanceCubit(repository: repository),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<EbdAttendanceCubit>()) {
      await getIt.unregister<EbdAttendanceCubit>();
    }
  });

  Future<void> setTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget buildSubject() {
    return const MaterialApp(
      home: Scaffold(
        body: EbdAttendancePage(classId: 'cls-1', lessonId: 'lesson-4'),
      ),
    );
  }

  group('EbdAttendancePage', () {
    testWidgets(
      'should render lesson call sheet with students and footer controls',
      (tester) async {
        await setTallSurface(tester);
        when(
          () => repository.getLessonAttendance('lesson-4'),
        ).thenAnswer((_) async => students);

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Chamada da Lição'), findsOneWidget);
        expect(find.text('Marcar todos como presentes'), findsOneWidget);
        expect(find.text('LISTA DE ALUNOS'), findsOneWidget);
        expect(find.text('Adriano Silva'), findsOneWidget);
        expect(find.text('Beatriz Oliveira'), findsOneWidget);
        expect(find.text('Carlos Eduardo'), findsOneWidget);
        expect(find.text('Daniela Santos'), findsOneWidget);
        expect(find.text('OFERTA DA CLASSE'), findsOneWidget);
        expect(find.text('Finalizar Chamada'), findsOneWidget);
      },
    );

    testWidgets(
      'should mark all students as present when the bulk action is tapped',
      (tester) async {
        await setTallSurface(tester);
        when(
          () => repository.getLessonAttendance('lesson-4'),
        ).thenAnswer((_) async => students);

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        // Initially Beatriz and Carlos are absent
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

    testWidgets('should show loading indicator while fetching', (
      tester,
    ) async {
      // Use a completer so we control when the future resolves
      when(
        () => repository.getLessonAttendance('lesson-4'),
      ).thenAnswer((_) async => students);

      await tester.pumpWidget(buildSubject());
      // Before pump — cubit emits loading synchronously
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
