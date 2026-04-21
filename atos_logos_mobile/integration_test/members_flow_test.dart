import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/enums/civil_status.dart';
import 'package:atos_logos_mobile/core/enums/sex.dart';
import 'package:atos_logos_mobile/features/branches/data/branches_repository.dart';
import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';
import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/create_member_page.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/edit_member_page.dart';
import 'package:atos_logos_mobile/features/positions/data/positions_repository.dart';
import 'package:atos_logos_mobile/features/positions/domain/models/position.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_state.dart';

// Widget-level integration test — exercises the create + edit Member flow
// end-to-end through the UI layer, with all backend access mocked. Lives
// under integration_test/ so it can also be invoked on a real device with
// `flutter test integration_test/members_flow_test.dart`, which boots the
// integration_test binding (see main()).
//
// We intentionally do NOT bring up the full app router / Dio / secure
// storage stack here: the value-add of this file is verifying that the new
// identity fields (RG, Sexo, Estado Civil, Pai, Mãe, Data de Consagração)
// are wired from the form to the cubit and back into the edit pre-fill.

class MockPositionsRepo extends Mock implements PositionsRepository {}

class MockBranchesRepo extends Mock implements BranchesRepository {}

class MockMembersCubit extends MockCubit<MembersState>
    implements MembersCubit {}

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockPositionsRepo mockPositions;
  late MockBranchesRepo mockBranches;
  late MockMembersCubit mockMembers;
  late MockProfileCubit mockProfile;

  const userId = 'u1';
  const positions = [
    Position(id: 'p1', churchId: 'c1', name: 'Pastor'),
  ];
  const branches = [
    Branch(id: 'b1', name: 'Sede', isHeadquarters: true),
  ];

  setUp(() {
    mockPositions = MockPositionsRepo();
    mockBranches = MockBranchesRepo();
    mockMembers = MockMembersCubit();
    mockProfile = MockProfileCubit();

    when(() => mockPositions.getPositions())
        .thenAnswer((_) async => positions);
    when(() => mockBranches.getBranches()).thenAnswer((_) async => branches);

    when(() => mockMembers.state).thenReturn(const MembersState.initial());
    when(() => mockMembers.createMemberWithUser(
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

    when(() => mockProfile.loadMemberProfileByUserId(any()))
        .thenAnswer((_) async {});

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

  testWidgets(
      'create-member happy path: fill new identity fields, submit, see success SnackBar, '
      'then navigate to edit and see the pre-fill', (tester) async {
    // Tall viewport so the entire form fits without needing intermediate
    // scrolls between every field.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // -------- Step 1: a tiny "members hub" surface that opens
    // CreateMemberPage when the secretary taps "+ Novo Membro". This
    // mirrors the production navigation from MembersPage → /create-member
    // without bringing up the full router + auth shell.
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Secretaria')),
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: BlocProvider<MembersCubit>.value(
                        value: mockMembers,
                        child: const CreateMemberPage(),
                      ),
                    ),
                  ),
                ),
                child: const Text('+ Novo Membro'),
              ),
            ),
          ),
        ),
      ),
    );

    // -------- Step 2: tap the entry to navigate to CreateMemberPage.
    await tester.tap(find.text('+ Novo Membro'));
    await tester.pumpAndSettle();
    expect(find.text('Novo Membro'), findsOneWidget);

    // -------- Step 3: fill the form.
    await tester.enterText(find.byType(TextFormField).first, 'Joao Silva');
    await tester.enterText(
      find.widgetWithText(TextFormField, '000.000.000-00'),
      '12345678900',
    );
    // CPF mask should kick in.
    expect(find.widgetWithText(TextFormField, '123.456.789-00'),
        findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Documento de identidade'),
      'MG-1234567',
    );
    final filiationFields =
        find.widgetWithText(TextFormField, 'Nome completo');
    expect(filiationFields, findsNWidgets(2));
    await tester.enterText(filiationFields.at(0), 'Pedro Silva');
    await tester.enterText(filiationFields.at(1), 'Maria Silva');

    // Sex.
    await tester.ensureVisible(find.byType(DropdownButtonFormField<Sex>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Sex>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masculino').last);
    await tester.pumpAndSettle();

    // CivilStatus.
    await tester.ensureVisible(
        find.byType(DropdownButtonFormField<CivilStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<CivilStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casado(a)').last);
    await tester.pumpAndSettle();

    // Branch (required).
    await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sede').last);
    await tester.pumpAndSettle();

    // -------- Step 4: submit and verify the cubit got the new fields +
    // a success SnackBar appeared.
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    final captured = verify(() => mockMembers.createMemberWithUser(
          name: captureAny(named: 'name'),
          password: any(named: 'password'),
          branchId: 'b1',
          email: any(named: 'email'),
          cpf: captureAny(named: 'cpf'),
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

    expect(captured, [
      'Joao Silva',
      '123.456.789-00',
      'MG-1234567',
      'MALE',
      'MARRIED',
      'Pedro Silva',
      'Maria Silva',
    ]);

    expect(find.text('Membro criado com sucesso.'), findsOneWidget);

    // -------- Step 5: navigate to EditMemberPage and verify the new
    // fields are pre-filled from the (mocked) profile fetch.
    const editProfile = MemberProfile(
      id: 'p1',
      userId: userId,
      churchId: 'c1',
      birthDate: '1990-05-12',
      admissionDate: '2020-01-15',
      consecrationDate: '2022-11-30',
      user: MemberProfileUser(
        id: userId,
        name: 'Joao Silva',
        email: 'joao@example.com',
        phone: '+5511988887777',
        cpf: '12345678900',
        rg: 'MG-1234567',
        sex: 'MALE',
        civilStatus: 'MARRIED',
        fatherName: 'Pedro Silva',
        motherName: 'Maria Silva',
      ),
    );
    when(() => mockProfile.state)
        .thenReturn(const ProfileState.loaded(profile: editProfile));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: mockProfile),
              BlocProvider<MembersCubit>.value(value: mockMembers),
            ],
            child: const EditMemberPage(userId: userId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar Membro'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'MG-1234567'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Pedro Silva'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Maria Silva'), findsOneWidget);
    // Dates render in Brazilian dd/MM/yyyy (converted from the ISO on
    // pre-fill) so the secretary reads them naturally.
    expect(find.widgetWithText(TextFormField, '12/05/1990'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '15/01/2020'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '30/11/2022'), findsOneWidget);
    // Selected dropdown labels render inline.
    expect(find.text('Masculino'), findsWidgets);
    expect(find.text('Casado(a)'), findsWidgets);

    // -------- Step 6: stub the two save calls and tap "Salvar Registro".
    // The regression this guards against: dates used to be rendered but
    // NOT sent on save — consecrationDate etc. just disappeared.
    when(() => mockMembers.updateMemberUserData(
          userId: any(named: 'userId'),
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          cpf: any(named: 'cpf'),
          rg: any(named: 'rg'),
          sex: any(named: 'sex'),
          civilStatus: any(named: 'civilStatus'),
          fatherName: any(named: 'fatherName'),
          motherName: any(named: 'motherName'),
        )).thenAnswer((_) async {});
    when(() => mockMembers.updateMemberProfile(
          profileId: any(named: 'profileId'),
          birthDate: any(named: 'birthDate'),
          baptismDate: any(named: 'baptismDate'),
          admissionDate: any(named: 'admissionDate'),
          consecrationDate: any(named: 'consecrationDate'),
        )).thenAnswer((_) async {});

    await tester.ensureVisible(find.text('Salvar Registro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar Registro'));
    await tester.pumpAndSettle();

    // Both PATCH calls fired, and the dates round-trip back as ISO.
    verify(() => mockMembers.updateMemberProfile(
          profileId: 'p1',
          birthDate: '1990-05-12',
          baptismDate: null,
          admissionDate: '2020-01-15',
          consecrationDate: '2022-11-30',
        )).called(1);

    // Identity fields (rg, sex, civilStatus, fatherName, motherName) must
    // also be forwarded on save — the regression this guards against is
    // the edit page calling updateMemberUserData without those fields,
    // causing them to be silently dropped even though they were pre-filled.
    final capturedEdit = verify(() => mockMembers.updateMemberUserData(
          userId: captureAny(named: 'userId'),
          name: captureAny(named: 'name'),
          email: captureAny(named: 'email'),
          phone: captureAny(named: 'phone'),
          cpf: captureAny(named: 'cpf'),
          rg: captureAny(named: 'rg'),
          sex: captureAny(named: 'sex'),
          civilStatus: captureAny(named: 'civilStatus'),
          fatherName: captureAny(named: 'fatherName'),
          motherName: captureAny(named: 'motherName'),
        )).captured;

    // Indices: userId, name, email, phone, cpf, rg, sex, civilStatus,
    // fatherName, motherName
    expect(capturedEdit[0], userId);
    expect(capturedEdit[5], 'MG-1234567');   // rg
    expect(capturedEdit[6], 'MALE');          // sex
    expect(capturedEdit[7], 'MARRIED');       // civilStatus
    expect(capturedEdit[8], 'Pedro Silva');   // fatherName
    expect(capturedEdit[9], 'Maria Silva');   // motherName
  });
}
