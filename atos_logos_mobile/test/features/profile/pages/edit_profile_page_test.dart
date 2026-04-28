import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_state.dart';
import 'package:atos_logos_mobile/features/profile/presentation/pages/edit_profile_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockProfileCubit mockProfileCubit;

  final userProfile = UserProfile(
    user: const UserProfileUser(
      id: 'u1',
      name: 'Ana',
      email: 'ana@test.com',
      phone: '11999998888',
      cpf: '12345678901',
      country: 'Brasil',
      state: 'SP',
      city: 'São Paulo',
      neighborhood: 'Jardins',
      street: 'Rua das Flores',
      number: '123',
    ),
    membership: const UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
    positions: const [],
    church: const UserProfileChurch(id: 'c1', name: 'Igreja'),
    branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockProfileCubit = MockProfileCubit();

    // fetchProfile is always called on initState — stub it to update state
    when(() => mockAuthCubit.fetchProfile()).thenAnswer((_) async {
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(profile: userProfile));
    });

    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(profile: userProfile));
    when(() => mockProfileCubit.state)
        .thenReturn(const ProfileState.initial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<ProfileCubit>.value(value: mockProfileCubit),
        ],
        child: const EditProfilePage(),
      ),
    );
  }

  group('EditProfilePage - Layout', () {
    testWidgets(
        'should display every personal-data field label after loading',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(); // allow fetchProfile to complete

      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('CPF'), findsOneWidget);
      expect(find.text('TELEFONE'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
    });

    testWidgets(
        'should display every address field label after loading',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('PAÍS'), findsOneWidget);
      expect(find.text('ESTADO'), findsOneWidget);
      expect(find.text('CIDADE'), findsOneWidget);
      expect(find.text('BAIRRO'), findsOneWidget);
    });

    testWidgets(
        'should display the SALVAR submit button after loading',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('SALVAR'),
        200,
        scrollable: scrollable,
      );
      expect(find.text('SALVAR'), findsOneWidget);
    });
  });

  group('EditProfilePage - Pre-fill', () {
    testWidgets(
        'should pre-fill every text field with fresh profile data from fetchProfile',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(); // fetchProfile completes → _populateFromAuthCubit

      final textFields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      final values = textFields.map((f) => f.controller?.text).toList();
      expect(values, contains('Ana'));
      expect(values, contains('ana@test.com'));
      // CPF and phone are pre-filled with mask applied
      expect(values, contains('123.456.789-01'));
      expect(values, contains('(11) 99999-8888'));
      expect(values, contains('Brasil'));
      expect(values, contains('SP'));
      expect(values, contains('São Paulo'));
      expect(values, contains('Jardins'));
      expect(values, contains('Rua das Flores'));
    });
  });

  group('EditProfilePage - Submit', () {
    testWidgets(
        'should forward trimmed edited values to ProfileCubit.updateMyProfile when SALVAR is tapped',
        (tester) async {
      when(() => mockProfileCubit.updateMyProfile(any()))
          .thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final scrollable = find.byType(Scrollable).first;
      await tester.enterText(
        find.byType(TextFormField).first,
        '  Ana Updated  ',
      );
      await tester.scrollUntilVisible(
        find.text('SALVAR'),
        200,
        scrollable: scrollable,
      );
      await tester.tap(find.text('SALVAR'));
      await tester.pump();

      final captured =
          verify(() => mockProfileCubit.updateMyProfile(captureAny())).captured;
      final payload = captured.single as Map<String, dynamic>;
      expect(payload['name'], 'Ana Updated');
      expect(payload['email'], 'ana@test.com');
      expect(payload['city'], 'São Paulo');
    });

    testWidgets(
        'should NOT call ProfileCubit.updateMyProfile while the cubit is already saving',
        (tester) async {
      when(() => mockProfileCubit.state).thenReturn(const ProfileState.saving());
      when(() => mockProfileCubit.updateMyProfile(any()))
          .thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        200,
        scrollable: scrollable,
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('EditProfilePage - States', () {
    testWidgets(
        'should display a progress indicator inside the submit button while saving',
        (tester) async {
      when(() => mockProfileCubit.state).thenReturn(const ProfileState.saving());
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        200,
        scrollable: scrollable,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SALVAR'), findsNothing);
    });

    testWidgets(
        'should show an error snackbar when the cubit transitions to an error state',
        (tester) async {
      whenListen(
        mockProfileCubit,
        Stream.fromIterable(const [
          ProfileState.error(message: 'Erro ao salvar'),
        ]),
        initialState: const ProfileState.initial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Erro ao salvar'), findsOneWidget);
    });

    testWidgets(
        'should show a success snackbar when the cubit transitions to a saved state',
        (tester) async {
      whenListen(
        mockProfileCubit,
        Stream.fromIterable(const [ProfileState.saved()]),
        initialState: const ProfileState.initial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Perfil salvo com sucesso'), findsOneWidget);
    });
  });
}
