import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/pages/create_ebd_quarter_page.dart';

class _MockEbdRepository extends Mock implements EbdRepository {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockEbdRepository repository;
  late _MockAuthCubit authCubit;

  const profile = UserProfile(
    user: UserProfileUser(id: 'u1', name: 'Abner', email: 'a@test.com'),
    membership: UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
    positions: [],
    church: UserProfileChurch(id: 'c1', name: 'Atos Logos'),
    branch: UserProfileBranch(id: 'branch-1', name: 'Sede'),
  );

  setUp(() {
    repository = _MockEbdRepository();
    authCubit = _MockAuthCubit();
    when(
      () => authCubit.state,
    ).thenReturn(const AuthState.authenticated(profile: profile));

    if (getIt.isRegistered<EbdCubit>()) {
      getIt.unregister<EbdCubit>();
    }
    if (getIt.isRegistered<EbdRepository>()) {
      getIt.unregister<EbdRepository>();
    }
    getIt.registerFactory<EbdCubit>(() => EbdCubit(repository: repository));
    getIt.registerLazySingleton<EbdRepository>(() => repository);
    when(() => repository.getSetupOptions()).thenAnswer(
      (_) async => const EbdSetupOptions(
        activeQuarter: EbdQuarterOption(id: 'quarter-1', name: '2026.2'),
        teachers: [
          EbdPersonOption(
            memberId: 'teacher-1',
            name: 'Pr. Ricardo Oliveira',
            role: 'MEMBER',
          ),
        ],
        students: [
          EbdPersonOption(
            memberId: 'student-1',
            name: 'André Luis Cavalcanti',
            role: 'MEMBER',
          ),
          EbdPersonOption(
            memberId: 'student-2',
            name: 'Beatriz Souza Ramos',
            role: 'MEMBER',
          ),
        ],
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
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const Scaffold(body: CreateEbdQuarterPage()),
      ),
    );
  }

  group('CreateEbdQuarterPage', () {
    testWidgets('should render the new EBD quarter setup screen', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Dados Base'), findsOneWidget);
      expect(find.text('Matrícula'), findsOneWidget);
      expect(find.text('Cronograma'), findsOneWidget);
      expect(find.text('Configurar Novo Trimestre'), findsOneWidget);
      expect(find.text('Nome da Revista'), findsOneWidget);
      expect(find.text('Trimestre / Ano'), findsOneWidget);
      expect(find.text('Data de Início'), findsOneWidget);
      expect(find.text('Professores'), findsOneWidget);
      expect(find.text('Pr. Ricardo Oliveira'), findsOneWidget);
      expect(find.text('Matrícula de Membros'), findsOneWidget);
      expect(find.text('André Luis Cavalcanti'), findsOneWidget);
      expect(find.text('Temas das Lições'), findsOneWidget);
      expect(find.text('Salvar e Iniciar Classe'), findsOneWidget);
    });

    testWidgets(
      'should create the EBD class using magazine name and user branch',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        when(
          () => repository.createClass(
            name: any(named: 'name'),
            branchId: any(named: 'branchId'),
            targetAudience: any(named: 'targetAudience'),
            quarterId: any(named: 'quarterId'),
            quarterName: any(named: 'quarterName'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        ).thenAnswer(
          (_) async => const EbdClass(
            id: 'class-1',
            churchId: 'c1',
            branchId: 'branch-1',
            name: 'O Fruto do Espírito',
          ),
        );
        when(() => repository.getClasses()).thenAnswer((_) async => const []);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex: O Fruto do Espírito'),
          'O Fruto do Espírito',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'mm/dd/yyyy'),
          '04/05/2026',
        );
        await tester.tap(find.byKey(const Key('ebd_person_teacher-1')));
        await tester.tap(find.byKey(const Key('select_all_ebd_students')));
        await tester.pump();
        for (var index = 2; index <= 13; index++) {
          await tester.scrollUntilVisible(
            find.widgetWithText(
              TextFormField,
              'Lição $index: Título da lição...',
            ),
            500,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.enterText(
            find.widgetWithText(
              TextFormField,
              'Lição $index: Título da lição...',
            ),
            'Tema $index',
          );
        }
        await tester.scrollUntilVisible(
          find.byType(ElevatedButton).last,
          900,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('save_ebd_class_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        verify(
          () => repository.createClass(
            name: 'O Fruto do Espírito',
            branchId: 'branch-1',
            targetAudience: 'Geral',
            quarterId: 'quarter-1',
            quarterName: '2026.2',
            teacherIds: ['teacher-1'],
            studentIds: ['student-1', 'student-2'],
            lessons: any(named: 'lessons'),
          ),
        ).called(1);
        expect(find.text('Classe iniciada com sucesso'), findsOneWidget);
      },
    );
  });
}
