import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/visitors/data/visitors_repository.dart';
import 'package:atos_logos_mobile/features/visitors/domain/models/visitor.dart';
import 'package:atos_logos_mobile/features/visitors/presentation/cubit/visitors_cubit.dart';
import 'package:atos_logos_mobile/features/visitors/presentation/cubit/visitors_state.dart';

class MockVisitorsRepository extends Mock implements VisitorsRepository {}

void main() {
  late MockVisitorsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitorsRepository();
  });

  const visitors = [
    Visitor(id: 'v-1', churchId: 'c-1', name: 'Maria Silva', phone: '11999999999', createdAt: '2026-04-03T10:00:00Z'),
    Visitor(id: 'v-2', churchId: 'c-1', name: 'Jose Santos', createdAt: '2026-04-02T10:00:00Z'),
  ];
  const visitorPage = VisitorPage(data: visitors, total: 2, page: 1, limit: 20);

  group('VisitorsCubit', () {
    test('initial state is VisitorsState.initial', () {
      final cubit = VisitorsCubit(repository: mockRepository);
      expect(cubit.state, const VisitorsState.initial());
      cubit.close();
    });

    blocTest<VisitorsCubit, VisitorsState>(
      'emits [loading, loaded] when loadVisitors succeeds',
      build: () {
        when(() => mockRepository.getVisitors(page: 1, limit: 20))
            .thenAnswer((_) async => visitorPage);
        return VisitorsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadVisitors(),
      expect: () => [
        const VisitorsState.loading(),
        const VisitorsState.loaded(visitors: visitors, total: 2, page: 1),
      ],
    );

    blocTest<VisitorsCubit, VisitorsState>(
      'emits [loading, error] when loadVisitors fails',
      build: () {
        when(() => mockRepository.getVisitors(page: 1, limit: 20))
            .thenThrow(NetworkException('Erro ao carregar'));
        return VisitorsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadVisitors(),
      expect: () => [
        const VisitorsState.loading(),
        const VisitorsState.error(message: 'Erro ao carregar'),
      ],
    );

    blocTest<VisitorsCubit, VisitorsState>(
      'emits [loading, loaded] when createVisitor succeeds and reloads',
      build: () {
        when(() => mockRepository.createVisitor(name: 'Ana Costa'))
            .thenAnswer((_) async => visitors.first);
        when(() => mockRepository.getVisitors(page: 1, limit: 20))
            .thenAnswer((_) async => visitorPage);
        return VisitorsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createVisitor(name: 'Ana Costa'),
      expect: () => [
        const VisitorsState.loading(),
        const VisitorsState.loaded(visitors: visitors, total: 2, page: 1),
      ],
    );
  });
}
