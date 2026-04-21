import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/ebd_cubit.dart';
import '../cubit/ebd_state.dart';

class EbdPage extends StatefulWidget {
  const EbdPage({super.key});

  @override
  State<EbdPage> createState() => _EbdPageState();
}

class _EbdPageState extends State<EbdPage> {
  late final EbdCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EbdCubit>()..loadClasses();
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
      child: BlocBuilder<EbdCubit, EbdState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            loaded: (classes) {
              if (classes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 64, color: AppTheme.outline),
                      const SizedBox(height: 16),
                      Text('Nenhuma turma de EBD', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => _cubit.loadClasses(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: const Icon(Icons.menu_book_outlined, color: AppTheme.primary, size: 22),
                        ),
                        title: Text(cls.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                        subtitle: Text(
                          cls.branch?.name ?? '',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
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
                  ElevatedButton(onPressed: () => _cubit.loadClasses(), child: const Text('Tentar novamente')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
