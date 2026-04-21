import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_state.dart';
import 'package:atos_logos_mobile/features/profile/presentation/pages/member_profile_page.dart';
import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late MockProfileCubit mockCubit;

  final profile = const MemberProfile(
    id: 'p1',
    userId: 'u1',
    churchId: 'c1',
    registrationNumber: '2026-ABCD-001',
    birthDate: '1990-05-12',
    baptismDate: '2018-05-12',
    admissionDate: '2015-10-01',
    user: MemberProfileUser(
      id: 'u1',
      name: 'Ana Beatriz Silva',
      email: 'ana@test.com',
      phone: '11987654321',
    ),
  );

  setUp(() {
    mockCubit = MockProfileCubit();
  });

  Widget buildSubject(ProfileState state) {
    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
    when(() => mockCubit.loadMemberProfile(any())).thenAnswer((_) async {});
    return MaterialApp(
      home: BlocProvider<ProfileCubit>.value(
        value: mockCubit,
        child: const MemberProfilePage(profileId: 'p1'),
      ),
    );
  }

  group('MemberProfilePage - Loading state', () {
    testWidgets(
        'should display CircularProgressIndicator when state is loading',
        (tester) async {
      await tester.pumpWidget(buildSubject(const ProfileState.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('MemberProfilePage - Loaded state', () {
    testWidgets('should display member name when loaded', (tester) async {
      await tester.pumpWidget(
        buildSubject(ProfileState.loaded(profile: profile)),
      );
      await tester.pump();
      expect(find.text('Ana Beatriz Silva'), findsOneWidget);
    });

    testWidgets('should display phone and email when loaded', (tester) async {
      await tester.pumpWidget(
        buildSubject(ProfileState.loaded(profile: profile)),
      );
      await tester.pump();
      expect(find.text('11987654321'), findsOneWidget);
      expect(find.text('ana@test.com'), findsOneWidget);
    });

    testWidgets('should display Dados Pessoais section title',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(ProfileState.loaded(profile: profile)),
      );
      await tester.pump();
      expect(find.text('Dados Pessoais'), findsOneWidget);
    });

    testWidgets(
        'should display Ações da Secretaria section and action card titles',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(ProfileState.loaded(profile: profile)),
      );
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Ações da Secretaria'),
        200,
      );
      expect(find.text('Ações da Secretaria'), findsOneWidget);
      expect(find.text('Carta de Recomendação'), findsOneWidget);
      expect(find.text('Certificado EBD'), findsOneWidget);
    });
  });

  group('MemberProfilePage - Error state', () {
    testWidgets('should display error message when state is error',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(const ProfileState.error(message: 'Erro ao carregar')),
      );
      expect(find.text('Erro ao carregar'), findsOneWidget);
    });
  });
}
