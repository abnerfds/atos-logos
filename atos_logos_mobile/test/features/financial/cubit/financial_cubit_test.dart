import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/financial/data/financial_repository.dart';
import 'package:atos_logos_mobile/features/financial/domain/models/financial.dart';
import 'package:atos_logos_mobile/features/financial/presentation/cubit/financial_cubit.dart';
import 'package:atos_logos_mobile/features/financial/presentation/cubit/financial_state.dart';

class MockFinancialRepository extends Mock implements FinancialRepository {}

void main() {
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
  });

  const summary = FinancialSummary(totalIncome: 5000, totalExpense: 2000, balance: 3000);
  const campaigns = [
    Campaign(id: 'c-1', churchId: 'ch-1', title: 'Reforma', goalAmount: '10000', currentAmount: '3500', status: 'active'),
  ];
  const transactions = [
    FinancialTransaction(id: 't-1', churchId: 'ch-1', type: 'INCOME', category: 'Dizimo', amount: '500', transactionDate: '2026-04-03'),
  ];
  const transactionPage = TransactionPage(data: transactions, total: 1, page: 1, limit: 20);

  group('FinancialCubit', () {
    test('initial state is FinancialState.initial', () {
      final cubit = FinancialCubit(repository: mockRepository);
      expect(cubit.state, const FinancialState.initial());
      cubit.close();
    });

    blocTest<FinancialCubit, FinancialState>(
      'emits [loading, loaded] when loadFinancial succeeds',
      build: () {
        when(() => mockRepository.getSummary()).thenAnswer((_) async => summary);
        when(() => mockRepository.getCampaigns()).thenAnswer((_) async => campaigns);
        when(() => mockRepository.getTransactions(page: 1, limit: 20)).thenAnswer((_) async => transactionPage);
        return FinancialCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadFinancial(),
      expect: () => [
        const FinancialState.loading(),
        const FinancialState.loaded(summary: summary, campaigns: campaigns, transactions: transactions),
      ],
    );

    blocTest<FinancialCubit, FinancialState>(
      'emits [loading, error] when loadFinancial fails',
      build: () {
        when(() => mockRepository.getSummary()).thenThrow(NetworkException('Erro'));
        when(() => mockRepository.getCampaigns()).thenAnswer((_) async => []);
        when(() => mockRepository.getTransactions(page: 1, limit: 20))
            .thenAnswer((_) async => const TransactionPage(data: [], total: 0, page: 1, limit: 20));
        return FinancialCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadFinancial(),
      expect: () => [
        const FinancialState.loading(),
        const FinancialState.error(message: 'Erro'),
      ],
    );
  });
}
