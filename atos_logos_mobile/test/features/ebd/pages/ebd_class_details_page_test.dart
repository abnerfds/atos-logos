import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_class_details_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/pages/ebd_class_details_page.dart';

class _MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late _MockEbdRepository repository;

  const classDetail = EbdClassDetail(
    id: 'cls-1',
    name: 'As Parábolas de Jesus',
    teacherName: 'Prof. Ricardo Mendes',
    quarterName: '4º Trimestre 2023',
  );

  final lessons = [
    EbdLesson(
      id: 'lesson-1',
      classId: 'cls-1',
      number: 1,
      theme: 'O Semeador e os Solos',
      scheduledDate: DateTime(2023, 10, 1),
      isCompleted: true,
    ),
    EbdLesson(
      id: 'lesson-2',
      classId: 'cls-1',
      number: 2,
      theme: 'O Joio e o Trigo',
      scheduledDate: DateTime(2023, 10, 8),
      isCompleted: true,
    ),
    EbdLesson(
      id: 'lesson-3',
      classId: 'cls-1',
      number: 3,
      theme: 'A Pérola de Grande Valor',
      scheduledDate: DateTime.now(),
      isCompleted: false,
    ),
    EbdLesson(
      id: 'lesson-4',
      classId: 'cls-1',
      number: 4,
      theme: 'O Credor Incompassivo',
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
  ];

  void stubAll() {
    when(
      () => repository.getClassDetail('cls-1'),
    ).thenAnswer((_) async => classDetail);
    when(
      () => repository.getLessons('cls-1'),
    ).thenAnswer((_) async => lessons);
  }

  setUp(() {
    repository = _MockEbdRepository();
    if (getIt.isRegistered<EbdClassDetailsCubit>()) {
      getIt.unregister<EbdClassDetailsCubit>();
    }
    getIt.registerFactory<EbdClassDetailsCubit>(
      () => EbdClassDetailsCubit(repository: repository),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<EbdClassDetailsCubit>()) {
      await getIt.unregister<EbdClassDetailsCubit>();
    }
  });

  group('EbdClassDetailsPage', () {
    testWidgets('should render class info and lessons from backend', (
      tester,
    ) async {
      stubAll();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EbdClassDetailsPage(classId: 'cls-1')),
        ),
      );
      await tester.pump();

      expect(find.text('ESCOLA BÍBLICA DOMINICAL'), findsOneWidget);
      expect(find.text('As Parábolas de Jesus'), findsOneWidget);
      expect(find.text('Prof. Ricardo Mendes'), findsOneWidget);
      expect(find.text('4º Trimestre 2023'), findsOneWidget);
      expect(find.text('Cronograma de Lições'), findsOneWidget);
      expect(find.text('O Semeador e os Solos'), findsOneWidget);
      expect(find.text('O Joio e o Trigo'), findsOneWidget);
      expect(find.text('A Pérola de Grande Valor'), findsOneWidget);
    });

    testWidgets('should show loading indicator while fetching', (
      tester,
    ) async {
      stubAll();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EbdClassDetailsPage(classId: 'cls-1')),
        ),
      );
      // Before pump — cubit emits loading synchronously
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to attendance when lesson card is tapped', (
      tester,
    ) async {
      stubAll();

      final router = GoRouter(
        initialLocation: '/details',
        routes: [
          GoRoute(
            path: '/details',
            builder: (context, state) => const Scaffold(
              body: EbdClassDetailsPage(classId: 'cls-1'),
            ),
          ),
          GoRoute(
            path: '/ebd/classes/:id/lessons/:lessonId/attendance',
            builder: (context, state) =>
                const Scaffold(body: Text('ATTENDANCE_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.byKey(const Key('take_attendance_button')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(const Key('take_attendance_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('take_attendance_button')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('ATTENDANCE_PAGE'), findsOneWidget);
    });

    testWidgets('should show edit card and navigate to edit page', (
      tester,
    ) async {
      stubAll();

      final router = GoRouter(
        initialLocation: '/details',
        routes: [
          GoRoute(
            path: '/details',
            builder: (context, state) => const Scaffold(
              body: EbdClassDetailsPage(classId: 'cls-1'),
            ),
          ),
          GoRoute(
            path: '/ebd/classes/:id/edit',
            builder: (context, state) =>
                const Scaffold(body: Text('EDIT_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pump();

      // Edit card is visible
      await tester.scrollUntilVisible(
        find.text('Deseja alterar os dados deste trimestre?'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Deseja alterar os dados deste trimestre?'), findsOneWidget);
      expect(find.byKey(const Key('edit_ebd_class_button')), findsOneWidget);

      // Tapping navigates to edit page
      await tester.tap(find.byKey(const Key('edit_ebd_class_button')));
      await tester.pumpAndSettle();

      expect(find.text('EDIT_PAGE'), findsOneWidget);
    });
  });
}
