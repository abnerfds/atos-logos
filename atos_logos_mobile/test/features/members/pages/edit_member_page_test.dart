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
import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/edit_member_page.dart';
import 'package:atos_logos_mobile/features/positions/data/positions_repository.dart';
import 'package:atos_logos_mobile/features/positions/domain/models/position.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_state.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class MockMembersCubit extends MockCubit<MembersState>
    implements MembersCubit {}

class MockPositionsRepo extends Mock implements PositionsRepository {}

class MockBranchesRepo extends Mock implements BranchesRepository {}

void main() {
  late MockProfileCubit mockProfile;
  late MockMembersCubit mockMembers;
  late MockPositionsRepo mockPositions;
  late MockBranchesRepo mockBranches;

  const userId = 'u1';
  const profileId = 'p1';
  const profile = MemberProfile(
    id: profileId,
    userId: userId,
    churchId: 'c1',
    birthDate: '1990-05-20',
    admissionDate: '2020-03-15',
    user: MemberProfileUser(
      id: userId,
      name: 'Ana Silva',
      email: 'ana@example.com',
      phone: '+5511999999999',
      cpf: '12345678900',
    ),
  );

  setUp(() {
    mockProfile = MockProfileCubit();
    mockMembers = MockMembersCubit();
    mockPositions = MockPositionsRepo();
    mockBranches = MockBranchesRepo();

    when(() => mockProfile.state)
        .thenReturn(const ProfileState.loaded(profile: profile));
    when(() => mockProfile.loadMemberProfileByUserId(any()))
        .thenAnswer((_) async {});
    when(() => mockMembers.state).thenReturn(const MembersState.initial());
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
    when(() => mockMembers.inactivateMemberByUserId(any()))
        .thenAnswer((_) async {});
    when(() => mockPositions.getPositions()).thenAnswer((_) async => const [
          Position(id: 'p1', churchId: 'c1', name: 'Pastor'),
        ]);
    when(() => mockBranches.getBranches()).thenAnswer((_) async => const [
          Branch(id: 'b1', name: 'Sede', isHeadquarters: true),
        ]);

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
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ProfileCubit>.value(value: mockProfile),
            BlocProvider<MembersCubit>.value(value: mockMembers),
          ],
          child: const EditMemberPage(userId: userId),
        ),
      ),
    );
  }

  group('EditMemberPage - Layout', () {
    testWidgets(
        'should populate the form controllers with the loaded member user fields',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Ana Silva'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'ana@example.com'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, '+5511999999999'),
        findsOneWidget,
      );
    });

    testWidgets(
        'should render the "Zona de Perigo" section with an "Inativar Membro" button',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Zona de Perigo'), findsOneWidget);
      expect(find.text('Inativar Membro'), findsOneWidget);
    });
  });

  group('EditMemberPage - Save', () {
    testWidgets(
        'should call MembersCubit.updateMemberUserData with the trimmed form values when Salvar Registro is tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Salvar Registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Registro'));
      await tester.pumpAndSettle();

      verify(() => mockMembers.updateMemberUserData(
            userId: userId,
            name: 'Ana Silva',
            email: 'ana@example.com',
            phone: '+5511999999999',
            cpf: '12345678900',
            rg: any(named: 'rg'),
            sex: any(named: 'sex'),
            civilStatus: any(named: 'civilStatus'),
            fatherName: any(named: 'fatherName'),
            motherName: any(named: 'motherName'),
          )).called(1);
    });

    testWidgets(
        'should show a SnackBar with the backend message when the save fails with an AppException',
        (tester) async {
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
          )).thenThrow(NetworkException('E-mail já cadastrado'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar Registro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Registro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('E-mail já cadastrado'), findsOneWidget);
      // Page stays mounted — no silent pop on error
      expect(find.text('Editar Membro'), findsOneWidget);
    });
  });

  group('EditMemberPage - Identity fields', () {
    const richProfile = MemberProfile(
      id: profileId,
      userId: userId,
      churchId: 'c1',
      birthDate: '1990-05-20',
      admissionDate: '2020-03-15',
      consecrationDate: '2022-11-30',
      user: MemberProfileUser(
        id: userId,
        name: 'Ana Silva',
        email: 'ana@example.com',
        phone: '+5511999999999',
        cpf: '12345678900',
        rg: 'MG-9876543',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'Carlos Silva',
        motherName: 'Beatriz Silva',
      ),
    );

    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    setUp(() {
      // Override the file-level mock so the page receives the richer profile.
      when(() => mockProfile.state)
          .thenReturn(const ProfileState.loaded(profile: richProfile));
    });

    testWidgets(
        'should pre-fill RG, Pai, Mae and Data de Consagracao from the loaded profile',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'MG-9876543'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Carlos Silva'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Beatriz Silva'),
        findsOneWidget,
      );
      expect(
        // The edit page renders dates in Brazilian dd/MM/yyyy so the
        // secretary reads them naturally; `_toIsoDate` converts back to
        // ISO on save.
        find.widgetWithText(TextFormField, '30/11/2022'),
        findsOneWidget,
      );
    });

    testWidgets(
        'should pre-fill Sexo and Estado Civil dropdowns with the wire-mapped labels',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The selected dropdown value renders its label inline.
      expect(find.text('Feminino'), findsWidgets);
      expect(find.text('Casado(a)'), findsWidgets);
    });

    testWidgets(
        'should forward edited identity fields to MembersCubit.updateMemberUserData',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Edit RG.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'MG-9876543'),
        'SP-1112223',
      );
      // Edit Pai / Mae.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Carlos Silva'),
        'Carlos Silva Jr.',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Beatriz Silva'),
        'Beatriz Silva Jr.',
      );

      // Switch Sex from Feminino to Masculino.
      await tester
          .ensureVisible(find.byType(DropdownButtonFormField<Sex>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<Sex>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masculino').last);
      await tester.pumpAndSettle();

      // Switch CivilStatus from Casado(a) to Solteiro(a).
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<CivilStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<CivilStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solteiro(a)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Salvar Registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Registro'));
      await tester.pumpAndSettle();

      verify(() => mockMembers.updateMemberUserData(
            userId: userId,
            name: 'Ana Silva',
            email: 'ana@example.com',
            phone: '+5511999999999',
            cpf: '12345678900',
            rg: 'SP-1112223',
            sex: 'MALE',
            civilStatus: 'SINGLE',
            fatherName: 'Carlos Silva Jr.',
            motherName: 'Beatriz Silva Jr.',
          )).called(1);
    });
  });

  group('EditMemberPage - Date fields (regression: dates were silently dropped on save)',
      () {
    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
        'should pre-fill the date TextFields in Brazilian dd/MM/yyyy so the secretary reads them naturally',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Profile ships birthDate='1990-05-20' and admissionDate='2020-03-15';
      // the page must render them as '20/05/1990' and '15/03/2020'.
      expect(
        find.widgetWithText(TextFormField, '20/05/1990'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, '15/03/2020'),
        findsOneWidget,
      );
    });

    testWidgets(
        'tapping Salvar with unchanged dates issues PATCH /member-profiles/:profileId with the SAME ISO values (round-trip, not silent drop)',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Salvar Registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Registro'));
      await tester.pumpAndSettle();

      // Even when the secretary does not re-tap a date, the pre-filled
      // dd/MM/yyyy is re-converted to ISO and forwarded — so the date
      // columns survive every save instead of being silently wiped.
      verify(() => mockMembers.updateMemberProfile(
            profileId: profileId,
            birthDate: '1990-05-20',
            baptismDate: null,
            admissionDate: '2020-03-15',
            consecrationDate: null,
          )).called(1);
    });
  });

  group('EditMemberPage - Inactivate', () {
    testWidgets(
        'should open the confirmation dialog and call MembersCubit.inactivateMemberByUserId when confirmed',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Inativar Membro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inativar Membro'));
      await tester.pumpAndSettle();

      // Dialog is open — confirm the action
      expect(find.text('Inativar Membro?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Inativar'));
      await tester.pumpAndSettle();

      verify(() => mockMembers.inactivateMemberByUserId(userId)).called(1);
    });

    testWidgets(
        'should show the backend guard message when the Last-Admin guard blocks inactivation',
        (tester) async {
      when(() => mockMembers.inactivateMemberByUserId(userId)).thenThrow(
        NetworkException('Cannot remove or demote the last admin of this church'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Inativar Membro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inativar Membro'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Inativar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Cannot remove or demote the last admin of this church'),
        findsOneWidget,
      );
      // Page stays mounted so the secretary can take another action
      expect(find.text('Editar Membro'), findsOneWidget);
    });
  });
}
