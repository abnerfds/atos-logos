import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/pages/ebd_page.dart';

class _MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late _MockEbdRepository repository;

  const classes = [
    EbdClass(
      id: 'cls-1',
      churchId: 'c-1',
      branchId: 'b-1',
      name: 'As Parábolas de Jesus',
      branch: EbdClassBranch(id: 'b-1', name: 'Sede'),
      teacherName: 'Pr. Ricardo Santos',
      enrolledCount: 42,
      certificateAvailable: true,
    ),
    EbdClass(
      id: 'cls-2',
      churchId: 'c-1',
      branchId: 'b-1',
      name: 'Epístola aos Efésios',
      branch: EbdClassBranch(id: 'b-1', name: 'Sede'),
      teacherName: 'Dra. Marta Oliveira',
      enrolledCount: 28,
    ),
  ];

  setUp(() {
    repository = _MockEbdRepository();
    if (getIt.isRegistered<EbdCubit>()) {
      getIt.unregister<EbdCubit>();
    }
    if (getIt.isRegistered<EbdRepository>()) {
      getIt.unregister<EbdRepository>();
    }
    getIt.registerFactory<EbdCubit>(() => EbdCubit(repository: repository));
    getIt.registerLazySingleton<EbdRepository>(() => repository);
    // Stub quarter summary to avoid unhandled async errors in tests
    when(() => repository.getQuarterSummary()).thenAnswer(
      (_) async => const EbdQuarterSummary(
        totalStudents: 141,
        activeClasses: 2,
        averageFrequency: 82,
        totalTeachers: 12,
      ),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<EbdCubit>()) {
      await getIt.unregister<EbdCubit>();
    }
    if (getIt.isRegistered<EbdRepository>()) {
      await getIt.unregister<EbdRepository>();
    }
  });

  Widget buildSubject() {
    return const MaterialApp(home: Scaffold(body: EbdPage()));
  }

  group('EbdPage', () {
    testWidgets('should render the EBD management dashboard when classes load', (
      tester,
    ) async {
      when(() => repository.getClasses()).thenAnswer((_) async => classes);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('MÓDULO LIDERANÇA'), findsOneWidget);
      expect(find.text('Escola Bíblica Dominical'), findsOneWidget);
      expect(
        find.text(
          'Gerencie as classes, currículos e o engajamento dos alunos para o trimestre atual.',
        ),
        findsOneWidget,
      );
      expect(find.text('Nova Classe/Revista'), findsOneWidget);
      expect(find.text('Classes Ativas'), findsOneWidget);
      expect(find.text('Histórico de Trimestres'), findsOneWidget);

      expect(find.text('As Parábolas de Jesus'), findsOneWidget);
      expect(find.text('Pr. Ricardo Santos'), findsOneWidget);
      expect(find.byKey(const Key('certificate_cls-1')), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Epístola aos Efésios'), findsOneWidget);
      expect(find.text('Dra. Marta Oliveira'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);

      await tester.drag(find.byType(Scrollable), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Visão Geral do Trimestre'), findsOneWidget);
      // Metrics show '—' while summary loads (getQuarterSummary not stubbed here)
      expect(find.text('2'), findsWidgets); // active classes count
    });

    testWidgets('should keep the existing empty state when no classes exist', (
      tester,
    ) async {
      when(() => repository.getClasses()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Nenhuma turma de EBD'), findsOneWidget);
    });

    testWidgets(
      'should navigate to new quarter setup from the primary action',
      (tester) async {
        when(() => repository.getClasses()).thenAnswer((_) async => classes);
        final router = GoRouter(
          initialLocation: '/ebd',
          routes: [
            GoRoute(
              path: '/ebd',
              builder: (context, state) => const Scaffold(body: EbdPage()),
            ),
            GoRoute(
              path: '/ebd/new-quarter',
              builder: (context, state) =>
                  const Scaffold(body: Text('NEW_EBD_QUARTER')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Nova Classe/Revista'));
        await tester.pumpAndSettle();

        expect(find.text('NEW_EBD_QUARTER'), findsOneWidget);
      },
    );
  });
}
