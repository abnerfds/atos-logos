import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/positions/data/positions_repository.dart';
import 'package:atos_logos_mobile/features/positions/domain/models/position.dart';
import 'package:atos_logos_mobile/features/positions/presentation/cubit/positions_cubit.dart';
import 'package:atos_logos_mobile/features/positions/presentation/cubit/positions_state.dart';

class MockPositionsRepository extends Mock implements PositionsRepository {}

void main() {
  late MockPositionsRepository mockRepository;

  setUp(() {
    mockRepository = MockPositionsRepository();
  });

  const positions = [
    Position(
      id: 'pos-1',
      churchId: 'church-1',
      name: 'Pastor',
      users: [
        PositionUserPivot(
          id: 'pu-1',
          userId: 'user-1',
          positionId: 'pos-1',
          user: PositionUserInfo(id: 'user-1', name: 'John'),
        ),
      ],
    ),
    Position(
      id: 'pos-2',
      churchId: 'church-1',
      name: 'Diacono',
      users: [],
    ),
  ];

  group('PositionsCubit', () {
    test('initial state is PositionsState.initial', () {
      final cubit = PositionsCubit(repository: mockRepository);
      expect(cubit.state, const PositionsState.initial());
      cubit.close();
    });

    blocTest<PositionsCubit, PositionsState>(
      'emits [loading, loaded] when loadPositions succeeds',
      build: () {
        when(() => mockRepository.getPositions())
            .thenAnswer((_) async => positions);
        return PositionsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPositions(),
      expect: () => [
        const PositionsState.loading(),
        const PositionsState.loaded(positions: positions),
      ],
    );

    blocTest<PositionsCubit, PositionsState>(
      'emits [loading, error] when loadPositions fails',
      build: () {
        when(() => mockRepository.getPositions())
            .thenThrow(NetworkException('Erro ao carregar'));
        return PositionsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadPositions(),
      expect: () => [
        const PositionsState.loading(),
        const PositionsState.error(message: 'Erro ao carregar'),
      ],
    );

    blocTest<PositionsCubit, PositionsState>(
      'emits [loading, loaded] when createPosition succeeds and reloads',
      build: () {
        when(() => mockRepository.createPosition('Presbitero'))
            .thenAnswer((_) async => positions.first);
        when(() => mockRepository.getPositions())
            .thenAnswer((_) async => positions);
        return PositionsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createPosition('Presbitero'),
      expect: () => [
        const PositionsState.loading(),
        const PositionsState.loaded(positions: positions),
      ],
    );

    blocTest<PositionsCubit, PositionsState>(
      'emits [loading, loaded] when deletePosition succeeds and reloads',
      build: () {
        when(() => mockRepository.deletePosition('pos-2'))
            .thenAnswer((_) async {});
        when(() => mockRepository.getPositions())
            .thenAnswer((_) async => [positions.first]);
        return PositionsCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.deletePosition('pos-2'),
      expect: () => [
        const PositionsState.loading(),
        PositionsState.loaded(positions: [positions.first]),
      ],
    );
  });
}
