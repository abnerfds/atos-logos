import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/visitors_cubit.dart';
import '../cubit/visitors_state.dart';

class VisitorsPage extends StatefulWidget {
  const VisitorsPage({super.key});

  @override
  State<VisitorsPage> createState() => _VisitorsPageState();
}

class _VisitorsPageState extends State<VisitorsPage> {
  late final VisitorsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<VisitorsCubit>()..loadVisitors();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Novo Visitante', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Nome'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(hintText: 'Telefone (opcional)'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final phone = phoneController.text.trim();
                _cubit.createVisitor(name: name, phone: phone.isNotEmpty ? phone : null);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: BlocBuilder<VisitorsCubit, VisitorsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              loaded: (visitors, total, page) {
                if (visitors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_outlined, size: 64, color: AppTheme.outline),
                        const SizedBox(height: 16),
                        Text('Nenhum visitante cadastrado',
                            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => _cubit.loadVisitors(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visitors.length,
                    itemBuilder: (context, index) {
                      final visitor = visitors[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.secondaryContainer,
                            child: Text(
                              visitor.name.isNotEmpty ? visitor.name[0].toUpperCase() : '?',
                              style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                          ),
                          title: Text(visitor.name,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                          subtitle: Text(
                            visitor.phone ?? 'Sem telefone',
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
                          ),
                          trailing: Text(
                            visitor.createdAt.substring(0, 10),
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.outline),
                          ),
                        ),
                      );
                    },
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
                    ElevatedButton(onPressed: () => _cubit.loadVisitors(), child: const Text('Tentar novamente')),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          onPressed: _showCreateDialog,
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}
