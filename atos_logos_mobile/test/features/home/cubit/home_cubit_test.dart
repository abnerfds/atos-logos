import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/home/data/home_repository.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/upcoming_event.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  const testChurch = Church(
    id: 'church-1',
    name: 'Grace Church',
    activePlan: 'free',
  );

  final testBirthdays = BirthdaysResponse(
    data: [
      BirthdayMember(id: '1', name: 'Ana', birthDate: '1995-04-12'),
    ],
    month: 4,
  );

  final testEvents = [
    UpcomingEvent(
      id: '1',
      title: 'Culto',
      startsAt: DateTime.utc(2026, 4, 12, 19, 30),
      branchName: 'Sede Central',
      type: 'SERVICE',
    ),
  ];

  group('HomeCubit - initial state', () {
    test('should start in HomeState.initial', () {
      final cubit = HomeCubit(repository: mockRepository);
      expect(cubit.state, const HomeState.initial());
      cubit.close();
    });
  });

  group('HomeCubit - loadDashboard happy paths', () {
    blocTest<HomeCubit, HomeState>(
      'should emit [loading, loaded] with typed events when every repository call succeeds',
      build: () {
        when(() => mockRepository.getMyChurch())
            .thenAnswer((_) async => testChurch);
        when(() => mockRepository.getBirthdays())
            .thenAnswer((_) async => testBirthdays);
        when(() => mockRepository.getUpcomingEvents())
            .thenAnswer((_) async => testEvents);
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: testBirthdays.data,
          upcomingEvents: testEvents,
        ),
      ],
    );
  });

  group('HomeCubit - loadDashboard partial failures', () {
    blocTest<HomeCubit, HomeState>(
      'should emit [loading, error] when the mandatory church fetch fails',
      build: () {
        when(() => mockRepository.getMyChurch())
            .thenThrow(NetworkException('Erro de rede'));
        when(() => mockRepository.getBirthdays())
            .thenAnswer((_) async => testBirthdays);
        when(() => mockRepository.getUpcomingEvents())
            .thenAnswer((_) async => testEvents);
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        const HomeState.error('Erro de rede'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should fall back to an empty birthdays list when the birthdays fetch fails (UX: avoid blanking dashboard)',
      build: () {
        when(() => mockRepository.getMyChurch())
            .thenAnswer((_) async => testChurch);
        when(() => mockRepository.getBirthdays())
            .thenThrow(NetworkException('Failed'));
        when(() => mockRepository.getUpcomingEvents())
            .thenAnswer((_) async => testEvents);
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: const [],
          upcomingEvents: testEvents,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should fall back to an empty events list when the upcoming-events fetch fails (UX: avoid blanking dashboard)',
      build: () {
        when(() => mockRepository.getMyChurch())
            .thenAnswer((_) async => testChurch);
        when(() => mockRepository.getBirthdays())
            .thenAnswer((_) async => testBirthdays);
        when(() => mockRepository.getUpcomingEvents())
            .thenThrow(NetworkException('Failed'));
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: testBirthdays.data,
          upcomingEvents: const [],
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should emit [loading, error] with a generic PT-BR message when getMyChurch throws a non-AppException (e.g., malformed JSON)',
      build: () {
        // Given — the repository throws a raw FormatException (not an
        // AppException). Without a generic catch, this would escape the
        // cubit as an unhandled future error and the UI would be stuck on
        // loading forever.
        when(() => mockRepository.getMyChurch())
            .thenThrow(const FormatException('bad JSON'));
        when(() => mockRepository.getBirthdays())
            .thenAnswer((_) async => testBirthdays);
        when(() => mockRepository.getUpcomingEvents())
            .thenAnswer((_) async => testEvents);
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        const HomeState.error('Erro inesperado ao carregar dashboard'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should fall back to empty birthdays AND empty events when both auxiliary fetches fail',
      build: () {
        when(() => mockRepository.getMyChurch())
            .thenAnswer((_) async => testChurch);
        when(() => mockRepository.getBirthdays())
            .thenThrow(NetworkException('Birthdays failed'));
        when(() => mockRepository.getUpcomingEvents())
            .thenThrow(NetworkException('Events failed'));
        return HomeCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: const [],
          upcomingEvents: const [],
        ),
      ],
    );
  });
}
