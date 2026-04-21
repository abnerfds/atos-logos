import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_state.dart';

class MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late MockEbdRepository mockRepository;

  setUp(() {
    mockRepository = MockEbdRepository();
  });

  const classes = [
    EbdClass(id: 'cls-1', churchId: 'c-1', branchId: 'b-1', name: 'Adultos',
        branch: EbdClassBranch(id: 'b-1', name: 'Sede')),
    EbdClass(id: 'cls-2', churchId: 'c-1', branchId: 'b-1', name: 'Jovens',
        branch: EbdClassBranch(id: 'b-1', name: 'Sede')),
  ];

  group('EbdCubit', () {
    test('initial state is EbdState.initial', () {
      final cubit = EbdCubit(repository: mockRepository);
      expect(cubit.state, const EbdState.initial());
      cubit.close();
    });

    blocTest<EbdCubit, EbdState>(
      'emits [loading, loaded] when loadClasses succeeds',
      build: () {
        when(() => mockRepository.getClasses()).thenAnswer((_) async => classes);
        return EbdCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadClasses(),
      expect: () => [
        const EbdState.loading(),
        const EbdState.loaded(classes: classes),
      ],
    );

    blocTest<EbdCubit, EbdState>(
      'emits [loading, error] when loadClasses fails',
      build: () {
        when(() => mockRepository.getClasses()).thenThrow(NetworkException('Erro'));
        return EbdCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadClasses(),
      expect: () => [
        const EbdState.loading(),
        const EbdState.error(message: 'Erro'),
      ],
    );
  });
}
