import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_class_details_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/pages/edit_ebd_class_page.dart';

class _MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late _MockEbdRepository repository;

  // ── Fixtures ──────────────────────────────────────────────────────────────

  const classDetail = EbdClassDetail(
    id: 'cls-1',
    name: 'As Parábolas de Jesus',
    teacherName: 'Prof. Ricardo Mendes',
    quarterName: '4º Trimestre 2023',
    targetAudience: 'Adultos',
    teachers: [EbdTeacherRef(id: 'teacher-1', name: 'Prof. Ricardo Mendes')],
  );

  final lessons = List.generate(
    13,
    (i) => EbdLesson(
      id: 'lesson-${i + 1}',
      classId: 'cls-1',
      number: i + 1,
      theme: 'Tema ${i + 1}',
      scheduledDate: DateTime(2023, 10, 1).add(Duration(days: i * 7)),
      isCompleted: i < 2,
    ),
  );

  const setupOptions = EbdSetupOptions(
    teachers: [
      EbdPersonOption(
        memberId: 'teacher-1',
        name: 'Prof. Ricardo Mendes',
        role: 'MEMBER',
      ),
    ],
    students: [
      EbdPersonOption(memberId: 'student-1', name: 'André Luis', role: 'MEMBER'),
    ],
  );

  // ── Setup / Teardown ──────────────────────────────────────────────────────

  void stubAll() {
    when(() => repository.getClassDetail('cls-1'))
        .thenAnswer((_) async => classDetail);
    when(() => repository.getLessons('cls-1'))
        .thenAnswer((_) async => lessons);
    when(() => repository.getSetupOptions())
        .thenAnswer((_) async => setupOptions);
    when(() => repository.getEnrollmentIds('cls-1'))
        .thenAnswer((_) async => ['student-1']);
  }

  setUp(() {
    repository = _MockEbdRepository();
    if (getIt.isRegistered<EbdCubit>()) getIt.unregister<EbdCubit>();
    if (getIt.isRegistered<EbdClassDetailsCubit>()) {
      getIt.unregister<EbdClassDetailsCubit>();
    }
    if (getIt.isRegistered<EbdRepository>()) {
      getIt.unregister<EbdRepository>();
    }
    getIt.registerFactory<EbdCubit>(() => EbdCubit(repository: repository));
    getIt.registerFactory<EbdClassDetailsCubit>(
      () => EbdClassDetailsCubit(repository: repository),
    );
    getIt.registerLazySingleton<EbdRepository>(() => repository);
  });

  tearDown(() async {
    if (getIt.isRegistered<EbdCubit>()) await getIt.unregister<EbdCubit>();
    if (getIt.isRegistered<EbdClassDetailsCubit>()) {
      await getIt.unregister<EbdClassDetailsCubit>();
    }
    if (getIt.isRegistered<EbdRepository>()) {
      await getIt.unregister<EbdRepository>();
    }
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/edit',
      routes: [
        GoRoute(
          path: '/edit',
          builder: (_, __) =>
              const Scaffold(body: EditEbdClassPage(classId: 'cls-1')),
        ),
        GoRoute(
          path: '/ebd/classes/:id',
          builder: (_, __) => const Scaffold(body: Text('DETAILS_PAGE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  // ── Tests ─────────────────────────────────────────────────────────────────

  group('EditEbdClassPage', () {
    testWidgets('should render the edit form with pre-filled class data', (
      tester,
    ) async {
      stubAll();

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Header and title
      expect(find.text('Editar Classe'), findsOneWidget);
      expect(find.text('Dados Base'), findsOneWidget);

      // Pre-filled name and target audience via controller text
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields[0].controller?.text, 'As Parábolas de Jesus');
      expect(fields[1].controller?.text, 'Adultos');

      // Teacher pre-selected (shown in the list)
      expect(find.text('Prof. Ricardo Mendes'), findsWidgets);

      // Lesson themes pre-filled in controllers
      expect(_lessonControllerText(tester, 0), 'Tema 1');
    });

    testWidgets('should show loading indicator while fetching class data', (
      tester,
    ) async {
      stubAll();

      await tester.pumpWidget(buildSubject());
      // Before pumpAndSettle — async load in progress
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets(
      'should call repository.updateClass with edited name on save',
      (tester) async {
        // Use a tall surface so all form fields and the save button are visible
        // without needing to scroll, avoiding flaky scrollUntilVisible behavior.
        await tester.binding.setSurfaceSize(const Size(430, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        stubAll();
        when(
          () => repository.updateClass(
            classId: any(named: 'classId'),
            name: any(named: 'name'),
            targetAudience: any(named: 'targetAudience'),
            quarterName: any(named: 'quarterName'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        ).thenAnswer((_) async {});
        when(() => repository.getClasses()).thenAnswer((_) async => []);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Edit the name
        await tester.enterText(
          find.byType(TextFormField).first,
          'As Parábolas Editadas',
        );

        // Tap save button (visible without scrolling on the tall surface)
        await tester.tap(find.byKey(const Key('save_edit_ebd_class_button')));
        await tester.pumpAndSettle();

        verify(
          () => repository.updateClass(
            classId: 'cls-1',
            name: 'As Parábolas Editadas',
            targetAudience: any(named: 'targetAudience'),
            quarterName: any(named: 'quarterName'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        ).called(1);

        expect(find.text('Classe atualizada com sucesso'), findsOneWidget);
      },
    );

    testWidgets(
      'should not call updateClass when no teacher is selected',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Class with no pre-selected teachers
        when(() => repository.getClassDetail('cls-1')).thenAnswer(
          (_) async => const EbdClassDetail(
            id: 'cls-1',
            name: 'Classe Sem Professor',
            teachers: [],
          ),
        );
        when(() => repository.getLessons('cls-1'))
            .thenAnswer((_) async => lessons);
        when(() => repository.getSetupOptions())
            .thenAnswer((_) async => setupOptions);
        when(() => repository.getEnrollmentIds('cls-1'))
            .thenAnswer((_) async => []);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_edit_ebd_class_button')));
        await tester.pump();

        // updateClass must NOT be called when there are no teachers
        verifyNever(
          () => repository.updateClass(
            classId: any(named: 'classId'),
            name: any(named: 'name'),
            targetAudience: any(named: 'targetAudience'),
            quarterName: any(named: 'quarterName'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        );
      },
    );

    testWidgets('should navigate back when back button is tapped', (
      tester,
    ) async {
      stubAll();

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('edit_ebd_class_back_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('DETAILS_PAGE'), findsOneWidget);
    });
  });
}

/// Helper: get the text of the lesson TextFormField at [index] (0-based).
/// Lesson fields start after the 4 header fields (name, audience, quarter, date).
String _lessonControllerText(WidgetTester tester, int lessonIndex) {
  final fields = tester
      .widgetList<TextFormField>(find.byType(TextFormField))
      .toList();
  // 0=name, 1=audience, 2=quarter, 3=date, 4..16=lessons
  return fields[4 + lessonIndex].controller?.text ?? '';
}
