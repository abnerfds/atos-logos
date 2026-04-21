import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/members/data/members_repository.dart';
import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';
import 'package:atos_logos_mobile/features/members/domain/models/membership.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';

class MockMembersRepository extends Mock implements MembersRepository {}

void main() {
  late MockMembersRepository mockRepository;

  setUp(() {
    mockRepository = MockMembersRepository();
  });

  final memberships = [
    const Membership(
      id: 'mem-1',
      userId: 'user-1',
      churchId: 'church-1',
      branchId: 'branch-1',
      role: 'ADMIN',
      status: 'ACTIVE',
      user: MembershipUser(id: 'user-1', name: 'Pastor John'),
      branch: MembershipBranch(id: 'branch-1', name: 'HQ'),
    ),
  ];

  final membershipPage = MembershipPage(
    data: memberships,
    total: 1,
    page: 1,
    limit: 20,
  );

  group('MembersCubit', () {
    test('initial state is MembersState.initial', () {
      final cubit = MembersCubit(repository: mockRepository);
      expect(cubit.state, const MembersState.initial());
      cubit.close();
    });

    blocTest<MembersCubit, MembersState>(
      'emits [loading, loaded] when loadMembers succeeds',
      build: () {
        when(() => mockRepository.getMemberships(page: 1, limit: 20))
            .thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadMembers(),
      expect: () => [
        const MembersState.loading(),
        MembersState.loaded(members: memberships, total: 1, page: 1),
      ],
    );

    blocTest<MembersCubit, MembersState>(
      'emits [loading, error] when loadMembers fails',
      build: () {
        when(() => mockRepository.getMemberships(page: 1, limit: 20))
            .thenThrow(NetworkException('Erro ao carregar'));
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadMembers(),
      expect: () => [
        const MembersState.loading(),
        const MembersState.error(message: 'Erro ao carregar'),
      ],
    );

    blocTest<MembersCubit, MembersState>(
      'emits [loading, loaded] when createMembership succeeds and reloads',
      build: () {
        when(() => mockRepository.createMembership(
              userId: 'user-2',
              branchId: 'branch-1',
              role: 'MEMBER',
            )).thenAnswer((_) async => memberships.first);
        when(() => mockRepository.getMemberships(page: 1, limit: 20))
            .thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createMembership(
        userId: 'user-2',
        branchId: 'branch-1',
        role: 'MEMBER',
      ),
      expect: () => [
        const MembersState.loading(),
        MembersState.loaded(members: memberships, total: 1, page: 1),
      ],
    );
  });

  group('MembersCubit - identity & consecration pass-through', () {
    blocTest<MembersCubit, MembersState>(
      'createMemberWithUser should forward the new identity + consecration params to the repository',
      build: () {
        // Given — repo accepts the call and the post-create reload succeeds
        when(() => mockRepository.createMemberWithUser(
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
            )).thenAnswer((_) async => <String, dynamic>{});
        when(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: any(named: 'q'),
            )).thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      // When
      act: (cubit) => cubit.createMemberWithUser(
        name: 'Ana',
        password: 'tmp-123456',
        branchId: 'b1',
        rg: 'MG-12.345.678',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'João',
        motherName: 'Maria',
        consecrationDate: '2022-11-01',
      ),
      verify: (_) {
        // Then — the cubit forwards every new param verbatim
        verify(() => mockRepository.createMemberWithUser(
              name: 'Ana',
              password: 'tmp-123456',
              branchId: 'b1',
              email: null,
              cpf: null,
              phone: null,
              rg: 'MG-12.345.678',
              sex: 'FEMALE',
              civilStatus: 'MARRIED',
              fatherName: 'João',
              motherName: 'Maria',
              role: null,
              positionId: null,
              birthDate: null,
              baptismDate: null,
              admissionDate: null,
              consecrationDate: '2022-11-01',
            )).called(1);
      },
    );

    blocTest<MembersCubit, MembersState>(
      'updateMemberUserData should forward the new identity params to the repository',
      build: () {
        // Given
        when(() => mockRepository.updateMemberUserData(
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
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
              complement: any(named: 'complement'),
              branchId: any(named: 'branchId'),
              positionId: any(named: 'positionId'),
            )).thenAnswer((_) async => <String, dynamic>{});
        when(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: any(named: 'q'),
            )).thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      // When
      act: (cubit) => cubit.updateMemberUserData(
        userId: 'u1',
        rg: 'MG-12.345.678',
        sex: 'MALE',
        civilStatus: 'SINGLE',
        fatherName: 'José',
        motherName: 'Maria',
      ),
      verify: (_) {
        // Then — the cubit forwards the new params verbatim
        verify(() => mockRepository.updateMemberUserData(
              userId: 'u1',
              name: null,
              email: null,
              phone: null,
              cpf: null,
              rg: 'MG-12.345.678',
              sex: 'MALE',
              civilStatus: 'SINGLE',
              fatherName: 'José',
              motherName: 'Maria',
              country: null,
              state: null,
              city: null,
              neighborhood: null,
              street: null,
              number: null,
              complement: null,
              branchId: null,
              positionId: null,
            )).called(1);
      },
    );

    blocTest<MembersCubit, MembersState>(
      'updateMemberProfile should forward the date fields to the repository (enables the secretary to actually save birth/baptism/admission/consecration changes)',
      build: () {
        when(() => mockRepository.updateMemberProfile(
              profileId: any(named: 'profileId'),
              birthDate: any(named: 'birthDate'),
              baptismDate: any(named: 'baptismDate'),
              admissionDate: any(named: 'admissionDate'),
              consecrationDate: any(named: 'consecrationDate'),
            )).thenAnswer((_) async => const MemberProfile(
              id: 'p1',
              userId: 'u1',
              churchId: 'c1',
            ));
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.updateMemberProfile(
        profileId: 'p1',
        birthDate: '1990-05-20',
        baptismDate: '2010-04-12',
        admissionDate: '2020-03-15',
        consecrationDate: '2022-11-30',
      ),
      verify: (_) {
        verify(() => mockRepository.updateMemberProfile(
              profileId: 'p1',
              birthDate: '1990-05-20',
              baptismDate: '2010-04-12',
              admissionDate: '2020-03-15',
              consecrationDate: '2022-11-30',
            )).called(1);
      },
    );
  });

  group('MembersCubit - search (server-side)', () {
    blocTest<MembersCubit, MembersState>(
      'should forward the query as q to the repository and emit [loading, loaded] with the new searchQuery',
      build: () {
        // `any<int?>(named: 'page')` matches the default page arg so the
        // seeded searchQuery state flows through loadMembers correctly.
        when(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: any(named: 'q'),
            )).thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.searchImmediate('Pastor'),
      expect: () => [
        const MembersState.loading(),
        MembersState.loaded(
          members: memberships,
          total: 1,
          page: 1,
          searchQuery: 'Pastor',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getMemberships(
              page: 1,
              limit: 20,
              q: 'Pastor',
            )).called(1);
      },
    );

    blocTest<MembersCubit, MembersState>(
      'should omit q from the repo call when the query is empty (reset filter)',
      build: () {
        when(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: any(named: 'q'),
            )).thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.searchImmediate(''),
      verify: (_) {
        verify(() => mockRepository.getMemberships(
              page: 1,
              limit: 20,
              q: null,
            )).called(1);
      },
    );

    blocTest<MembersCubit, MembersState>(
      'should debounce successive keystrokes and only fire ONE repo call with the final query',
      // Given — three rapid calls mimic the user typing "Ana" letter by letter.
      // The debounce must collapse them into a single request for "Ana".
      build: () {
        when(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: any(named: 'q'),
            )).thenAnswer((_) async => membershipPage);
        return MembersCubit(repository: mockRepository);
      },
      act: (cubit) async {
        cubit.search('A');
        cubit.search('An');
        cubit.search('Ana');
        // Wait longer than the 300ms debounce so the timer fires exactly once.
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      verify: (_) {
        verify(() => mockRepository.getMemberships(
              page: 1,
              limit: 20,
              q: 'Ana',
            )).called(1);
        verifyNever(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: 'A',
            ));
        verifyNever(() => mockRepository.getMemberships(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              q: 'An',
            ));
      },
    );
  });
}
