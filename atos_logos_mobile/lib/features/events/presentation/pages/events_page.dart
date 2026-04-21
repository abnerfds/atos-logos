import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

/// Agenda tab — event cards matching Stitch dashboard event style.
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EventsCubit>()..loadEvents();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'SERVICE': return 'Culto';
      case 'EBD': return 'EBD';
      case 'MEETING': return 'Reunião';
      default: return type;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'SERVICE': return AppTheme.primary;
      case 'EBD': return const Color(0xFF635983);
      case 'MEETING': return AppTheme.outline;
      default: return AppTheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agenda', style: GoogleFonts.manrope(
                        fontSize: 32, fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface, letterSpacing: -0.5,
                      )),
                      const SizedBox(height: 8),
                      Text('Próximos cultos, eventos e reuniões.',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              state.when(
                initial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                ),
                loaded: (events, total, page) {
                  if (events.isEmpty) {
                    return SliverFillRemaining(child: Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_outlined, size: 64, color: AppTheme.outline),
                        const SizedBox(height: 16),
                        Text('Nenhum evento cadastrado',
                            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                      ],
                    )));
                  }
                  return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                    final event = events[index];
                    final date = event.startsAt.substring(0, 10);
                    final day = date.length >= 10 ? date.substring(8, 10) : '--';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(children: [
                          // Date badge
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: _typeColor(event.type).withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(day, style: GoogleFonts.manrope(
                                  fontSize: 20, fontWeight: FontWeight.w800, color: _typeColor(event.type),
                                )),
                                Text(_typeLabel(event.type), style: GoogleFonts.inter(
                                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  color: _typeColor(event.type),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface,
                              )),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.schedule, size: 14, color: AppTheme.outline),
                                const SizedBox(width: 4),
                                Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.outline)),
                                if (event.branch != null) ...[
                                  const SizedBox(width: 12),
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.outline),
                                  const SizedBox(width: 4),
                                  Text(event.branch!.name, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.outline)),
                                ],
                              ]),
                            ],
                          )),
                          const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
                        ]),
                      ),
                    );
                  }, childCount: events.length));
                },
                error: (msg) => SliverFillRemaining(child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text(msg, style: GoogleFonts.inter(color: AppTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => _cubit.loadEvents(), child: const Text('Tentar novamente')),
                  ],
                ))),
              ),
            ],
          );
        },
      ),
    );
  }
}
