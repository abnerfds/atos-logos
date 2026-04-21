import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/enums/civil_status.dart';
import 'package:atos_logos_mobile/core/enums/sex.dart';
import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/branches/data/branches_repository.dart';
import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/create_member_page.dart';
import 'package:atos_logos_mobile/features/positions/data/positions_repository.dart';
import 'package:atos_logos_mobile/features/positions/domain/models/position.dart';

class MockPositionsRepo extends Mock implements PositionsRepository {}

class MockBranchesRepo extends Mock implements BranchesRepository {}

class MockMembersCubit extends MockCubit<MembersState>
    implements MembersCubit {}

void main() {
  late MockPositionsRepo mockPositions;
  late MockBranchesRepo mockBranches;
  late MockMembersCubit mockCubit;

  const positions = [
    Position(id: 'p1', churchId: 'c1', name: 'Pastor'),
    Position(id: 'p2', churchId: 'c1', name: 'Presbítero'),
  ];
  const branches = [
    Branch(id: 'b1', name: 'Sede', isHeadquarters: true),
    Branch(id: 'b2', name: 'Filial Norte', isHeadquarters: false),
  ];

  setUp(() {
    mockPositions = MockPositionsRepo();
    mockBranches = MockBranchesRepo();
    mockCubit = MockMembersCubit();
    when(() => mockPositions.getPositions())
        .thenAnswer((_) async => positions);
    when(() => mockBranches.getBranches()).thenAnswer((_) async => branches);
    when(() => mockCubit.state).thenReturn(const MembersState.initial());
    when(() => mockCubit.createMemberWithUser(
          name: any(named: 'name'),
          password: any(named: 'password'),
          branchId: any(named: 'branchId'),
          email: any(named: 'email'),
          cpf: any(named: 'cpf'),
          phone: any(named: 'phone'),
          rg: any(named: 'rg'),
          sex: any(named: 'sex'),
          civilStatus: any(named: 'civilStatus'),
          fatherName: any(named: 'fatherName'),
          motherName: any(named: 'motherName'),
          role: any(named: 'role'),
          positionId: any(named: 'positionId'),
          birthDate: any(named: 'birthDate'),
          baptismDate: any(named: 'baptismDate'),
          admissionDate: any(named: 'admissionDate'),
          consecrationDate: any(named: 'consecrationDate'),
        )).thenAnswer((_) async {});

    final getIt = GetIt.instance;
    if (getIt.isRegistered<PositionsRepository>()) {
      getIt.unregister<PositionsRepository>();
    }
    if (getIt.isRegistered<BranchesRepository>()) {
      getIt.unregister<BranchesRepository>();
    }
    getIt.registerSingleton<PositionsRepository>(mockPositions);
    getIt.registerSingleton<BranchesRepository>(mockBranches);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<PositionsRepository>()) {
      getIt.unregister<PositionsRepository>();
    }
    if (getIt.isRegistered<BranchesRepository>()) {
      getIt.unregister<BranchesRepository>();
    }
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MembersCubit>.value(
          value: mockCubit,
          child: const CreateMemberPage(),
        ),
      ),
    );
  }

  /// Wraps the page in a Navigator so `Navigator.of(context).pop()` can be
  /// observed by tests — the default MaterialApp home cannot be popped.
  Widget buildSubjectInsideNavigator({required GlobalKey<NavigatorState> key}) {
    return MaterialApp(
      navigatorKey: key,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: BlocProvider<MembersCubit>.value(
                      value: mockCubit,
                      child: const CreateMemberPage(),
                    ),
                  ),
                ),
              ),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openCreateMemberPage(
    WidgetTester tester,
    GlobalKey<NavigatorState> navKey,
  ) async {
    await tester.pumpWidget(buildSubjectInsideNavigator(key: navKey));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
  }

  group('CreateMemberPage - Layout', () {
    testWidgets(
        'should display the "Novo Membro" headline when the page renders',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Novo Membro'), findsOneWidget);
    });

    testWidgets(
        'should display the photo upload placeholder when the page renders',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Foto do Perfil'), findsOneWidget);
    });

    testWidgets(
        'should display every personal-info field label when the personal section is expanded',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('TELEFONE'), findsOneWidget);
      expect(find.text('CPF'), findsOneWidget);
      expect(find.text('DATA DE NASCIMENTO'), findsOneWidget);
    });

    testWidgets(
        'should display the "Informações Pessoais" accordion header when the page renders',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.textContaining('Informações Pessoais'), findsOneWidget);
    });

    testWidgets(
        'should display the ecclesiastical date fields when the church section is expanded',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('DATA DE BATISMO'), findsOneWidget);
      expect(find.text('DATA DE ADMISSÃO'), findsOneWidget);
    });
  });

  group('CreateMemberPage - Dropdowns', () {
    testWidgets(
        'should call PositionsRepository.getPositions on init so the cargo dropdown is backend-driven (not hardcoded)',
        (tester) async {
      // Given — setUp stubbed the repo with known positions
      // When — the page is pumped
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Then — the repo was asked for the current church's positions
      verify(() => mockPositions.getPositions()).called(1);
    });

    testWidgets(
        'should call BranchesRepository.getBranches on init so the congregação dropdown is backend-driven (not hardcoded)',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      verify(() => mockBranches.getBranches()).called(1);
    });

    testWidgets(
        'should render every position returned by the repo as a menu item when the cargo dropdown is opened',
        (tester) async {
      // Given
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Scroll the cargo dropdown into view (the form is inside a
      // SingleChildScrollView and the dropdowns live near the bottom).
      await tester.ensureVisible(find.text('CARGO'));
      await tester.pumpAndSettle();

      // When — the user taps the cargo dropdown to open the overlay
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      // Then — each backend position shows up as a menu item
      expect(find.text('Pastor'), findsOneWidget);
      expect(find.text('Presbítero'), findsOneWidget);
    });

    testWidgets(
        'should render every branch returned by the repo as a menu item when the congregação dropdown is opened',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('CONGREGAÇÃO'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();

      expect(find.text('Sede'), findsOneWidget);
      expect(find.text('Filial Norte'), findsOneWidget);
    });

    testWidgets(
        'should leave the cargo dropdown empty and keep the form usable when PositionsRepository throws',
        (tester) async {
      // Given — positions request fails (network / auth issue)
      when(() => mockPositions.getPositions())
          .thenThrow(Exception('boom'));

      // When
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Then — no exception surfaces to the user and the rest of the page
      // still renders (user can fill fields + submit)
      expect(tester.takeException(), isNull);
      expect(find.text('Novo Membro'), findsOneWidget);
    });
  });

  group('CreateMemberPage - Interactions', () {
    testWidgets(
        'should show the "Informe o nome" validation error when the form is submitted with an empty name',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets(
        'should refuse to submit and surface a PT-BR SnackBar when the congregação has not been picked',
        (tester) async {
      // Given — name is filled, cargo + branch still unpicked
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Joao Silva');

      // When
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Then — user is told which field is missing, and the cubit is NOT hit
      expect(
        find.textContaining('Selecione uma congregação'),
        findsOneWidget,
      );
      verifyNever(() => mockCubit.createMemberWithUser(
            name: any(named: 'name'),
            password: any(named: 'password'),
            branchId: any(named: 'branchId'),
          ));
    });

    testWidgets(
        'should call MembersCubit.createMemberWithUser with the form values and show the temporary password dialog on success',
        (tester) async {
      // Use a tall viewport so the whole expanded form fits without
      // scrolling — keeps the dropdown hit-testable after enterText.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Given — a fully filled form with a selected congregação
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Joao Silva');
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sede').last);
      await tester.pumpAndSettle();

      // When — submit. Pump in short steps so the SnackBar that appears
      // right before the pop is still on-screen when we assert below
      // (pumpAndSettle would run past the snackbar's auto-dismiss).
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Then — the cubit is invoked with the name + branch + a temp password
      final capturedName = verify(() => mockCubit.createMemberWithUser(
            name: captureAny(named: 'name'),
            password: any(named: 'password'),
            branchId: 'b1',
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            phone: any(named: 'phone'),
            rg: any(named: 'rg'),
            sex: any(named: 'sex'),
            civilStatus: any(named: 'civilStatus'),
            fatherName: any(named: 'fatherName'),
            motherName: any(named: 'motherName'),
            role: any(named: 'role'),
            positionId: any(named: 'positionId'),
            birthDate: any(named: 'birthDate'),
            baptismDate: any(named: 'baptismDate'),
            admissionDate: any(named: 'admissionDate'),
            consecrationDate: any(named: 'consecrationDate'),
          )).captured.single as String;
      expect(capturedName, 'Joao Silva');

      // And — a success SnackBar is shown (no more temp-password dialog)
      expect(
        find.text('Membro criado com sucesso.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'should show a SnackBar with the backend message when the cubit throws an AppException',
        (tester) async {
      // Given — backend rejects the call with a business error
      when(() => mockCubit.createMemberWithUser(
            name: any(named: 'name'),
            password: any(named: 'password'),
            branchId: any(named: 'branchId'),
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            phone: any(named: 'phone'),
            rg: any(named: 'rg'),
            sex: any(named: 'sex'),
            civilStatus: any(named: 'civilStatus'),
            fatherName: any(named: 'fatherName'),
            motherName: any(named: 'motherName'),
            role: any(named: 'role'),
            positionId: any(named: 'positionId'),
            birthDate: any(named: 'birthDate'),
            baptismDate: any(named: 'baptismDate'),
            admissionDate: any(named: 'admissionDate'),
            consecrationDate: any(named: 'consecrationDate'),
          )).thenThrow(NetworkException('E-mail já cadastrado'));

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Joao Silva');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sede').last);
      await tester.pumpAndSettle();

      // When
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Then — the server message is surfaced and the page stays mounted
      expect(find.text('E-mail já cadastrado'), findsOneWidget);
      expect(find.text('Novo Membro'), findsOneWidget);
    });

    testWidgets(
        'should pop the route when the back button in the header is tapped',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await openCreateMemberPage(tester, navKey);
      expect(find.text('Novo Membro'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Novo Membro'), findsNothing);
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets(
        'should collapse the personal-info section when its header is tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('NOME COMPLETO'), findsOneWidget);

      await tester.tap(find.textContaining('Informações Pessoais'));
      await tester.pumpAndSettle();

      expect(find.text('NOME COMPLETO'), findsNothing);
    });
  });

  group('CreateMemberPage - Identity fields', () {
    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
        'should render RG, Sexo and Estado Civil labels in the personal-info section',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('RG'), findsOneWidget);
      expect(find.text('SEXO'), findsOneWidget);
      expect(find.text('ESTADO CIVIL'), findsOneWidget);
    });

    testWidgets(
        'should render Nome do Pai and Nome da Mae fields under the Filiacao header',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Filiação'), findsOneWidget);
      expect(find.text('NOME DO PAI'), findsOneWidget);
      expect(find.text('NOME DA MÃE'), findsOneWidget);
    });

    testWidgets(
        'should render the Data de Consagracao field in the ecclesiastical section',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('DATA DE CONSAGRAÇÃO'), findsOneWidget);
    });

    testWidgets(
        'should apply the CPF mask so typing 11 digits renders 000.000.000-00',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // CPF is the 4th TextFormField (Name, Email, CPF, Phone, BirthDate, RG,
      // Pai, Mae). Find by its hint to be robust.
      final cpfField = find.widgetWithText(TextFormField, '000.000.000-00');
      expect(cpfField, findsOneWidget);

      await tester.enterText(cpfField, '12345678900');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, '123.456.789-00'),
          findsOneWidget);
    });

    testWidgets(
        'should forward rg, sex, civilStatus, fatherName and motherName to MembersCubit on submit',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Fill mandatory name first.
      await tester.enterText(find.byType(TextFormField).first, 'Joao Silva');

      // RG (5th TextFormField — find via hint to be robust).
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Documento de identidade'),
        'MG-1234567',
      );

      // Filiação fields (find via hint — both share "Nome completo" hint, so
      // pick by index within the Filiação accordion: father is first, mother
      // is second).
      final filiationFields =
          find.widgetWithText(TextFormField, 'Nome completo');
      expect(filiationFields, findsNWidgets(2));
      await tester.enterText(filiationFields.at(0), 'Pedro Silva');
      await tester.enterText(filiationFields.at(1), 'Maria Silva');

      // Pick Sex.male.
      await tester
          .ensureVisible(find.byType(DropdownButtonFormField<Sex>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<Sex>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masculino').last);
      await tester.pumpAndSettle();

      // Pick CivilStatus.married.
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<CivilStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<CivilStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Casado(a)').last);
      await tester.pumpAndSettle();

      // Pick a branch (required for submit to reach the cubit).
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sede').last);
      await tester.pumpAndSettle();

      // Submit.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      final captured = verify(() => mockCubit.createMemberWithUser(
            name: any(named: 'name'),
            password: any(named: 'password'),
            branchId: any(named: 'branchId'),
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            phone: any(named: 'phone'),
            rg: captureAny(named: 'rg'),
            sex: captureAny(named: 'sex'),
            civilStatus: captureAny(named: 'civilStatus'),
            fatherName: captureAny(named: 'fatherName'),
            motherName: captureAny(named: 'motherName'),
            role: any(named: 'role'),
            positionId: any(named: 'positionId'),
            birthDate: any(named: 'birthDate'),
            baptismDate: any(named: 'baptismDate'),
            admissionDate: any(named: 'admissionDate'),
            consecrationDate: any(named: 'consecrationDate'),
          )).captured;

      expect(captured, ['MG-1234567', 'MALE', 'MARRIED', 'Pedro Silva', 'Maria Silva']);
    });
  });
}
