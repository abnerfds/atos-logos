import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/profile/data/profile_repository.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:atos_logos_mobile/features/profile/presentation/cubit/profile_state.dart';
import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  final profile = MemberProfile(
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

  group('ProfileCubit - loadMemberProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'should emit loading then loaded on success',
      build: () {
        when(() => mockRepository.getMemberProfile('p1'))
            .thenAnswer((_) async => profile);
        return ProfileCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadMemberProfile('p1'),
      expect: () => [
        const ProfileState.loading(),
        ProfileState.loaded(profile: profile),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'should emit loading then error on failure',
      build: () {
        when(() => mockRepository.getMemberProfile('p1'))
            .thenThrow(NetworkException('Erro'));
        return ProfileCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadMemberProfile('p1'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.error(message: 'Erro'),
      ],
    );
  });

  group('ProfileCubit - updateMyProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'should emit saving then saved on success',
      build: () {
        when(() => mockRepository.updateMyProfile(any()))
            .thenAnswer((_) async => {});
        return ProfileCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.updateMyProfile({'name': 'Ana Updated'}),
      expect: () => [
        const ProfileState.saving(),
        const ProfileState.saved(),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'should emit saving then error on failure',
      build: () {
        when(() => mockRepository.updateMyProfile(any()))
            .thenThrow(NetworkException('Erro ao salvar'));
        return ProfileCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.updateMyProfile({'name': 'Ana'}),
      expect: () => [
        const ProfileState.saving(),
        const ProfileState.error(message: 'Erro ao salvar'),
      ],
    );
  });
}
