import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/events/data/events_repository.dart';
import 'package:atos_logos_mobile/features/events/domain/models/event.dart';
import 'package:atos_logos_mobile/features/events/presentation/cubit/events_cubit.dart';
import 'package:atos_logos_mobile/features/events/presentation/cubit/events_state.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  late MockEventsRepository mockRepository;

  setUp(() {
    mockRepository = MockEventsRepository();
  });

  const events = [
    Event(id: 'ev-1', churchId: 'c-1', title: 'Culto Domingo', startsAt: '2026-04-06T10:00:00Z', type: 'SERVICE'),
    Event(id: 'ev-2', churchId: 'c-1', title: 'EBD', startsAt: '2026-04-06T09:00:00Z', type: 'EBD'),
  ];
  const eventPage = EventPage(data: events, total: 2, page: 1, limit: 20);

  group('EventsCubit', () {
    test('initial state is EventsState.initial', () {
      final cubit = EventsCubit(repository: mockRepository);
      expect(cubit.state, const EventsState.initial());
      cubit.close();
    });

    blocTest<EventsCubit, EventsState>(
      'emits [loading, loaded] when loadEvents succeeds',
      build: () {
        when(() => mockRepository.getEvents(page: 1, limit: 20))
            .thenAnswer((_) async => eventPage);
        return EventsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        const EventsState.loading(),
        const EventsState.loaded(events: events, total: 2, page: 1),
      ],
    );

    blocTest<EventsCubit, EventsState>(
      'emits [loading, error] when loadEvents fails',
      build: () {
        when(() => mockRepository.getEvents(page: 1, limit: 20))
            .thenThrow(NetworkException('Erro ao carregar'));
        return EventsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        const EventsState.loading(),
        const EventsState.error(message: 'Erro ao carregar'),
      ],
    );

    blocTest<EventsCubit, EventsState>(
      'emits [loading, loaded] when createEvent succeeds and reloads',
      build: () {
        when(() => mockRepository.createEvent(
              title: 'Novo Culto', startsAt: '2026-04-07T10:00:00Z', type: 'SERVICE',
            )).thenAnswer((_) async => events.first);
        when(() => mockRepository.getEvents(page: 1, limit: 20))
            .thenAnswer((_) async => eventPage);
        return EventsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createEvent(title: 'Novo Culto', startsAt: '2026-04-07T10:00:00Z', type: 'SERVICE'),
      expect: () => [
        const EventsState.loading(),
        const EventsState.loaded(events: events, total: 2, page: 1),
      ],
    );
  });
}
