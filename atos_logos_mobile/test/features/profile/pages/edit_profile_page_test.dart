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
      phone: '119',
      cpf: '123',
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
        'should display every personal-data field label when the page renders',
        (tester) async {
      // Given / When — the page is pumped with a known authenticated user
      await tester.pumpWidget(buildSubject());

      // Then — all four personal-section labels are visible
      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('CPF'), findsOneWidget);
      expect(find.text('TELEFONE'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
    });

    testWidgets(
        'should display every address field label when the page renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — all the address-section labels are visible
      expect(find.text('PAÍS'), findsOneWidget);
      expect(find.text('ESTADO'), findsOneWidget);
      expect(find.text('CIDADE'), findsOneWidget);
      expect(find.text('BAIRRO'), findsOneWidget);
    });

    testWidgets(
        'should display the SALVAR submit button when the page renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('SALVAR'),
        200,
        scrollable: scrollable,
      );

      // Then — the button is reachable in the scroll view
      expect(find.text('SALVAR'), findsOneWidget);
    });
  });

  group('EditProfilePage - Pre-fill', () {
    testWidgets(
        'should pre-fill every text field with the authenticated user profile data',
        (tester) async {
      // Given / When — the page is pumped and reads the auth profile on init
      await tester.pumpWidget(buildSubject());

      // Then — each field's controller value matches the profile we injected
      final textFields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      final values = textFields.map((f) => f.controller?.text).toList();
      expect(values, contains('Ana'));
      expect(values, contains('ana@test.com'));
      expect(values, contains('119'));
      expect(values, contains('123')); // cpf
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
      // Given — the page is rendered with a stub cubit
      when(() => mockProfileCubit.updateMyProfile(any()))
          .thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      final scrollable = find.byType(Scrollable).first;

      // When — the user edits the name (with surrounding whitespace) and taps SALVAR
      await tester.enterText(find.byType(TextFormField).first, '  Ana Updated  ');
      await tester.scrollUntilVisible(
        find.text('SALVAR'),
        200,
        scrollable: scrollable,
      );
      await tester.tap(find.text('SALVAR'));
      await tester.pump();

      // Then — the cubit is called with the trimmed value
      final captured =
          verify(() => mockProfileCubit.updateMyProfile(captureAny())).captured;
      final payload = captured.single as Map<String, dynamic>;
      expect(payload['name'], 'Ana Updated');
      // And the other original fields round-trip untouched
      expect(payload['email'], 'ana@test.com');
      expect(payload['city'], 'São Paulo');
    });

    testWidgets(
        'should NOT call ProfileCubit.updateMyProfile while the cubit is already saving',
        (tester) async {
      // Given — the cubit is in the saving state (SALVAR label is replaced
      // by a spinner, so we scroll to the button type, not its label).
      when(() => mockProfileCubit.state).thenReturn(const ProfileState.saving());
      when(() => mockProfileCubit.updateMyProfile(any()))
          .thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        200,
        scrollable: scrollable,
      );

      // When / Then — the FilledButton's onPressed is null during saving
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('EditProfilePage - States', () {
    testWidgets(
        'should display a progress indicator inside the submit button while the cubit state is saving',
        (tester) async {
      // Given — the cubit is in its saving state
      when(() => mockProfileCubit.state).thenReturn(const ProfileState.saving());

      // When — the page is pumped
      await tester.pumpWidget(buildSubject());
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        200,
        scrollable: scrollable,
      );

      // Then — a spinner is shown instead of the SALVAR label
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SALVAR'), findsNothing);
    });

    testWidgets(
        'should show an error snackbar when the cubit transitions to an error state',
        (tester) async {
      // Given — the cubit stream will emit an error state after pump
      whenListen(
        mockProfileCubit,
        Stream.fromIterable(const [
          ProfileState.error(message: 'Erro ao salvar'),
        ]),
        initialState: const ProfileState.initial(),
      );

      // When — the page is pumped and the listener reacts
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Then — an error snackbar carrying the message is shown
      expect(find.text('Erro ao salvar'), findsOneWidget);
    });

    testWidgets(
        'should show a success snackbar when the cubit transitions to a saved state',
        (tester) async {
      // Given — the cubit stream will emit saved after pump
      whenListen(
        mockProfileCubit,
        Stream.fromIterable(const [ProfileState.saved()]),
        initialState: const ProfileState.initial(),
      );

      // When — the page is pumped and the listener reacts
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Then — the success snackbar is visible
      expect(find.text('Perfil salvo com sucesso'), findsOneWidget);
    });
  });
}
