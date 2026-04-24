import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/ebd_class.dart';
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
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
            loaded: (classes) {
              if (classes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 64,
                        color: AppTheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma turma de EBD',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/ebd/new-quarter'),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Nova Classe/Revista'),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => _cubit.loadClasses(),
                child: _EbdDashboard(classes: classes),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: GoogleFonts.inter(color: AppTheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _cubit.loadClasses(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EbdDashboard extends StatelessWidget {
  const _EbdDashboard({required this.classes});

  final List<EbdClass> classes;

  @override
  Widget build(BuildContext context) {
    final cards = classes.map(_ClassOverview.fromClass).toList();
    final activeClasses = classes.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      children: [
        Text(
          'Módulo Liderança'.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escola Bíblica Dominical',
          style: GoogleFonts.manrope(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Gerencie as classes, currículos e o engajamento dos alunos para o trimestre atual.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.45,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/ebd/new-quarter'),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Nova Classe/Revista'),
            style: ElevatedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        const _EbdTabs(),
        const SizedBox(height: 26),
        ...cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ClassCard(overview: card),
          ),
        ),
        const SizedBox(height: 24),
        _QuarterSummary(activeClasses: activeClasses),
      ],
    );
  }
}

class _EbdTabs extends StatelessWidget {
  const _EbdTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        _TabLabel(text: 'Classes Ativas', selected: true),
        const SizedBox(width: 46),
        _TabLabel(text: 'Histórico de Trimestres'),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.45,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primary : AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.overview});

  final _ClassOverview overview;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.primary;
    final iconBackground = AppTheme.secondaryContainer;
    final badgeBackground = overview.badgeColor;

    return InkWell(
      onTap: () => context.push('/ebd/classes/${overview.slug}'),
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Container(
        constraints: const BoxConstraints(minHeight: 164),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Icon(overview.icon, color: accent, size: 25),
                ),
                const Spacer(),
                if (overview.certificateAvailable) ...[
                  Tooltip(
                    message: 'Certificado disponível',
                    child: IconButton.filledTonal(
                      key: Key('certificate_${overview.slug}'),
                      onPressed: () {},
                      icon: const Icon(Icons.verified_outlined, size: 20),
                      color: AppTheme.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.secondaryContainer,
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    overview.badge,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              overview.title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.person, size: 12, color: AppTheme.onSurface),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    overview.teacher,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${overview.students}',
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: accent,
                      ),
                    ),
                    Text(
                      overview.studentsLabel.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Lição ${overview.lesson} de 13',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: overview.progress,
                minHeight: 5,
                backgroundColor: AppTheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuarterSummary extends StatelessWidget {
  const _QuarterSummary({required this.activeClasses});

  final int activeClasses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral do Trimestre',
            style: GoogleFonts.manrope(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.08,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O engajamento deste trimestre superou em 15% o período anterior. O foco em classes temáticas tem atraído novos membros.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.55,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.surfaceContainerLowest,
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Ver Relatório Completo',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const _MetricTile(value: '141', label: 'Total\nAlunos'),
              _MetricTile(value: '$activeClasses', label: 'Classes\nAtivas'),
              const _MetricTile(value: '82%', label: 'Frequência'),
              const _MetricTile(value: '12', label: 'Professores'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              height: 1.15,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassOverview {
  const _ClassOverview({
    required this.slug,
    required this.title,
    required this.teacher,
    required this.students,
    required this.studentsLabel,
    required this.lesson,
    required this.progress,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    this.certificateAvailable = false,
  });

  final String slug;
  final String title;
  final String teacher;
  final int students;
  final String studentsLabel;
  final int lesson;
  final double progress;
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final bool certificateAvailable;

  factory _ClassOverview.fromClass(EbdClass ebdClass) {
    return _ClassOverview(
      slug: ebdClass.id,
      title: ebdClass.name,
      teacher: ebdClass.teacherName ?? 'Professor não informado',
      students: ebdClass.enrolledCount,
      studentsLabel: ebdClass.targetAudience ?? 'Alunos Ativos',
      lesson: 0,
      progress: 0,
      badge: ebdClass.status == false ? 'INATIVA' : 'EM ANDAMENTO',
      badgeColor: ebdClass.status == false
          ? AppTheme.surfaceContainerHigh
          : const Color(0xFFD8CAFC),
      icon: Icons.menu_book_outlined,
      certificateAvailable: ebdClass.certificateAvailable,
    );
  }
}
