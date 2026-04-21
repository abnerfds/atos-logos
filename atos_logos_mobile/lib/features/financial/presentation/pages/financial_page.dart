import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/financial_cubit.dart';
import '../cubit/financial_state.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  late final FinancialCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<FinancialCubit>()..loadFinancial();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<FinancialCubit, FinancialState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            loaded: (summary, campaigns, transactions) {
              return RefreshIndicator(
                onRefresh: () => _cubit.loadFinancial(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        Expanded(child: _SummaryCard(
                          label: 'Receitas',
                          value: 'R\$ ${summary.totalIncome.toStringAsFixed(2)}',
                          color: const Color(0xFF16A34A),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _SummaryCard(
                          label: 'Despesas',
                          value: 'R\$ ${summary.totalExpense.toStringAsFixed(2)}',
                          color: AppTheme.error,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      label: 'Saldo',
                      value: 'R\$ ${summary.balance.toStringAsFixed(2)}',
                      color: AppTheme.primary,
                    ),

                    const SizedBox(height: 24),

                    // Campaigns
                    if (campaigns.isNotEmpty) ...[
                      Text('Campanhas', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
                      const SizedBox(height: 12),
                      ...campaigns.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: double.tryParse(c.goalAmount) != null && double.parse(c.goalAmount) > 0
                                  ? double.parse(c.currentAmount) / double.parse(c.goalAmount)
                                  : 0,
                              backgroundColor: AppTheme.surfaceContainerHigh,
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'R\$ ${c.currentAmount} / R\$ ${c.goalAmount}',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],

                    // Recent transactions
                    Text('Últimas Transações', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      Center(child: Text('Nenhuma transação', style: GoogleFonts.inter(color: AppTheme.outline)))
                    else
                      ...transactions.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: ListTile(
                          leading: Icon(
                            t.type == 'INCOME' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t.type == 'INCOME' ? const Color(0xFF16A34A) : AppTheme.error,
                          ),
                          title: Text(t.category, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text(t.transactionDate.substring(0, 10), style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                          trailing: Text(
                            'R\$ ${t.amount}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: t.type == 'INCOME' ? const Color(0xFF16A34A) : AppTheme.error,
                            ),
                          ),
                        ),
                      )),
                  ],
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(message, style: GoogleFonts.inter(color: AppTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => _cubit.loadFinancial(), child: const Text('Tentar novamente')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
