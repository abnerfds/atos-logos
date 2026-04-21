import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/members_page.dart';
import 'package:atos_logos_mobile/features/members/domain/models/membership.dart';

class MockMembersCubit extends MockCubit<MembersState>
    implements MembersCubit {}

void main() {
  late MockMembersCubit mockCubit;

  final testMembers = [
    const Membership(
      id: '1',
      userId: 'u1',
      churchId: 'c1',
      branchId: 'b1',
      role: 'ADMIN',
      status: 'ACTIVE',
      user: MembershipUser(id: 'u1', name: 'Ricardo Oliveira'),
      branch: MembershipBranch(id: 'b1', name: 'Sede'),
    ),
    const Membership(
      id: '2',
      userId: 'u2',
      churchId: 'c1',
      branchId: 'b1',
      role: 'MEMBER',
      status: 'ACTIVE',
      user: MembershipUser(id: 'u2', name: 'Ana Paula Santos'),
      branch: MembershipBranch(id: 'b1', name: 'Sede'),
    ),
  ];

  setUp(() {
    mockCubit = MockMembersCubit();
  });

  Widget buildSubject(MembersState state) {
    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
    return MaterialApp(
      home: BlocProvider<MembersCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: MembersPage()),
      ),
    );
  }

  group('MembersPage - Layout', () {
    testWidgets('should display page title', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));
      expect(find.text('Secretaria'), findsOneWidget);
    });

    testWidgets('should display 3 tabs', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));
      expect(find.text('Membros'), findsOneWidget);
      expect(find.text('Visitantes'), findsOneWidget);
      expect(find.text('EBD'), findsOneWidget);
    });

    testWidgets('should display member names', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));
      expect(find.text('Ricardo Oliveira'), findsOneWidget);
      expect(find.text('Ana Paula Santos'), findsOneWidget);
    });

    testWidgets('should display FAB', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
