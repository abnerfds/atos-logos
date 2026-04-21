import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/position.dart';
import '../cubit/positions_cubit.dart';
import '../cubit/positions_state.dart';

/// Gestão tab — matches Stitch "Configuração de Cargos" design.
class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  late final PositionsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<PositionsCubit>()..loadPositions();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Novo Cargo', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome do cargo'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _cubit.createPosition(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  static const _positionIcons = {
    'pastor': Icons.account_balance,
    'diacono': Icons.volunteer_activism,
    'diácono': Icons.volunteer_activism,
    'lider': Icons.music_note,
    'líder': Icons.music_note,
    'secretario': Icons.description,
    'secretário': Icons.description,
    'presbitero': Icons.shield_outlined,
    'presbítero': Icons.shield_outlined,
  };

  IconData _iconForPosition(String name) {
    final lower = name.toLowerCase();
    for (final entry in _positionIcons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.badge_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: BlocBuilder<PositionsCubit, PositionsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAINEL ADMINISTRATIVO', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 1.5, color: AppTheme.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('Configuração\nde Cargos', style: GoogleFonts.manrope(
                          fontSize: 32, fontWeight: FontWeight.w800,
                          color: AppTheme.primary, height: 1.1, letterSpacing: -0.5,
                        )),
                        const SizedBox(height: 8),
                        Text('Gerencie a hierarquia e as funções ministeriais da sua congregação.',
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── List ──
                state.when(
                  initial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  ),
                  loaded: (positions) {
                    if (positions.isEmpty) {
                      return SliverFillRemaining(child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.badge_outlined, size: 64, color: AppTheme.outline),
                          const SizedBox(height: 16),
                          Text('Nenhum cargo cadastrado',
                              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                        ],
                      )));
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('LISTA DE CARGOS ATIVOS', style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2, color: AppTheme.onSurfaceVariant,
                                  )),
                                  Text('AÇÕES', style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2, color: AppTheme.onSurfaceVariant,
                                  )),
                                ],
                              ),
                            ),
                            // Position items
                            ...positions.map((p) => _PositionItem(
                              position: p,
                              icon: _iconForPosition(p.name),
                              onDelete: () => _cubit.deletePosition(p.id),
                            )),
                          ]),
                        ),
                      ),
                    );
                  },
                  error: (msg) => SliverFillRemaining(child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(msg, style: GoogleFonts.inter(color: AppTheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => _cubit.loadPositions(), child: const Text('Tentar novamente')),
                    ],
                  ))),
                ),

                // ── Insights cards ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: state.maybeWhen(
                      loaded: (positions) {
                        final totalUsers = positions.fold<int>(0, (sum, p) => sum + p.users.length);
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFF37628A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL DE MEMBROS ALOCADOS', style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5, color: Colors.white70,
                                  )),
                                  const SizedBox(height: 4),
                                  Text('$totalUsers', style: GoogleFonts.manrope(
                                    fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white,
                                  )),
                                ],
                              ),
                              Icon(Icons.group, size: 48, color: Colors.white12),
                            ],
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          onPressed: _showCreateDialog,
          icon: const Icon(Icons.add),
          label: Text('Novo Cargo', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _PositionItem extends StatelessWidget {
  const _PositionItem({required this.position, required this.icon, required this.onDelete});
  final Position position;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(position.name, style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurface,
            )),
            Text('${position.users.length} membro${position.users.length != 1 ? 's' : ''}',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant)),
          ],
        )),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
          onPressed: onDelete,
        ),
      ]),
    );
  }
}
