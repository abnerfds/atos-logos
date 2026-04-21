import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/branches/data/branches_repository.dart';
import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_cubit.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_state.dart';

class MockBranchesRepository extends Mock implements BranchesRepository {}

void main() {
  late MockBranchesRepository mockRepository;

  setUp(() {
    mockRepository = MockBranchesRepository();
  });

  final branches = [
    const Branch(id: '1', name: 'Sede Central', isHeadquarters: true),
    const Branch(id: '2', name: 'Filial Norte', isHeadquarters: false),
  ];

  group('BranchesCubit - loadBranches', () {
    blocTest<BranchesCubit, BranchesState>(
      'should emit loading then loaded on success',
      build: () {
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadBranches(),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should emit loading then error on failure',
      build: () {
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenThrow(NetworkException('Erro de rede'));
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadBranches(),
      expect: () => [
        const BranchesState.loading(),
        const BranchesState.error(message: 'Erro de rede'),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should forward the current query as q after a previous search call (preserves filter across reloads)',
      build: () {
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) async {
        await cubit.search('Sede');
        await cubit.loadBranches(); // second reload — no new search arg
      },
      verify: (_) {
        // search('Sede') → first call with q: 'Sede'; second loadBranches
        // → should also carry q: 'Sede' (preserved filter).
        verify(() => mockRepository.getBranches(q: 'Sede')).called(2);
      },
    );
  });

  group('BranchesCubit - search (server-side)', () {
    blocTest<BranchesCubit, BranchesState>(
      'should reload with the given q value and emit [loading, loaded with searchQuery set]',
      build: () {
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.search('Filial'),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches, searchQuery: 'Filial'),
      ],
      verify: (_) {
        verify(() => mockRepository.getBranches(q: 'Filial')).called(1);
      },
    );

    blocTest<BranchesCubit, BranchesState>(
      'should forward q as null when the query is empty (reset filter)',
      build: () {
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.search(''),
      verify: (_) {
        verify(() => mockRepository.getBranches(q: null)).called(1);
      },
    );
  });

  group('BranchesCubit - updateBranch', () {
    blocTest<BranchesCubit, BranchesState>(
      'should reload the list after a successful update (so the edited row reflects new data)',
      build: () {
        when(() => mockRepository.updateBranch(
              id: any(named: 'id'),
              name: any(named: 'name'),
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
            )).thenAnswer((_) async => branches.first);
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.updateBranch(id: 'b1', name: 'Renomeada'),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should rethrow when the update fails so the edit page can SnackBar the server message (no error state emitted)',
      build: () {
        when(() => mockRepository.updateBranch(
              id: any(named: 'id'),
              name: any(named: 'name'),
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
            )).thenThrow(NetworkException('Branch not found'));
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.updateBranch(id: 'b1', name: 'X'),
      errors: () => [isA<NetworkException>()],
      expect: () => <BranchesState>[],
    );
  });

  group('BranchesCubit - promoteToHeadquarters', () {
    blocTest<BranchesCubit, BranchesState>(
      'should reload the list after a successful promotion (so the HQ badge moves to the new row)',
      build: () {
        when(() => mockRepository.promoteToHeadquarters(any()))
            .thenAnswer((_) async => branches.first);
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.promoteToHeadquarters('b2'),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should rethrow the 409 "already headquarters" guard without emitting an error state (page surfaces the SnackBar)',
      build: () {
        when(() => mockRepository.promoteToHeadquarters(any())).thenThrow(
          NetworkException('Branch is already the headquarters'),
        );
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.promoteToHeadquarters('b1'),
      errors: () => [isA<NetworkException>()],
      expect: () => <BranchesState>[],
    );
  });

  group('BranchesCubit - deleteBranch', () {
    blocTest<BranchesCubit, BranchesState>(
      'should reload the list after a successful delete',
      build: () {
        when(() => mockRepository.deleteBranch(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getBranches(q: any(named: 'q')))
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.deleteBranch('b2'),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should rethrow the Last-HQ guard message when the backend refuses (no error state emitted)',
      build: () {
        when(() => mockRepository.deleteBranch(any())).thenThrow(
          NetworkException('Cannot delete the headquarters branch'),
        );
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.deleteBranch('b1'),
      errors: () => [isA<NetworkException>()],
      expect: () => <BranchesState>[],
    );
  });

  group('BranchesCubit - createBranch', () {
    blocTest<BranchesCubit, BranchesState>(
      'should reload branches after successful creation',
      build: () {
        when(() => mockRepository.createBranch(
              name: any(named: 'name'),
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
            )).thenAnswer((_) async => branches[1]);
        when(() => mockRepository.getBranches())
            .thenAnswer((_) async => branches);
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createBranch(name: 'Filial Norte'),
      expect: () => [
        const BranchesState.loading(),
        BranchesState.loaded(branches: branches),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should emit [loading, error] with the AppException message when createBranch fails',
      build: () {
        when(() => mockRepository.createBranch(
              name: any(named: 'name'),
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
            )).thenThrow(NetworkException('Erro ao criar congregação'));
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createBranch(name: 'Filial Ruim'),
      expect: () => [
        const BranchesState.loading(),
        const BranchesState.error(message: 'Erro ao criar congregação'),
      ],
    );

    blocTest<BranchesCubit, BranchesState>(
      'should emit [loading, error] with a generic PT-BR message when createBranch throws a non-AppException',
      build: () {
        when(() => mockRepository.createBranch(
              name: any(named: 'name'),
              country: any(named: 'country'),
              state: any(named: 'state'),
              city: any(named: 'city'),
              neighborhood: any(named: 'neighborhood'),
              street: any(named: 'street'),
              number: any(named: 'number'),
            )).thenThrow(const FormatException('bad JSON'));
        return BranchesCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.createBranch(name: 'Filial'),
      expect: () => [
        const BranchesState.loading(),
        const BranchesState.error(message: 'Erro inesperado'),
      ],
    );
  });
}
