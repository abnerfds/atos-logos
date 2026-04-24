import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/ebd_class.dart';
import '../cubit/ebd_class_details_cubit.dart';

class EbdClassDetailsPage extends StatefulWidget {
  const EbdClassDetailsPage({super.key, required this.classId});

  final String classId;

  @override
  State<EbdClassDetailsPage> createState() => _EbdClassDetailsPageState();
}

class _EbdClassDetailsPageState extends State<EbdClassDetailsPage> {
  late final EbdClassDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EbdClassDetailsCubit>()..loadDetails(widget.classId);
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
      child: BlocBuilder<EbdClassDetailsCubit, EbdClassDetailsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('ebd_class_details_back_button'),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/ebd');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: AppTheme.primary,
                  tooltip: 'Voltar',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ESCOLA BÍBLICA DOMINICAL',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (state is EbdClassDetailsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (state is EbdClassDetailsError)
                _ErrorView(
                  message: state.message,
                  onRetry: () => _cubit.loadDetails(widget.classId),
                )
              else if (state is EbdClassDetailsLoaded)
                _LessonList(
                  classDetail: state.classDetail,
                  lessons: state.lessons,
                  classId: widget.classId,
                )
              else
                const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(color: AppTheme.error)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({
    required this.classDetail,
    required this.lessons,
    required this.classId,
  });

  final EbdClassDetail classDetail;
  final List<EbdLesson> lessons;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final nextLesson = lessons.firstWhere(
      (l) => !l.isCompleted,
      orElse: () => lessons.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Nome da classe ──────────────────────────────────────────────
        Text(
          classDetail.name,
          style: GoogleFonts.manrope(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        // ── Pills: professor e trimestre ────────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (classDetail.teacherName != null)
              _InfoPill(
                icon: Icons.person,
                label: classDetail.teacherName!,
              ),
            if (classDetail.quarterName != null)
              _InfoPill(
                icon: Icons.calendar_today,
                label: classDetail.quarterName!,
              ),
          ],
        ),
        const SizedBox(height: 34),
        const _MagazineHero(),
        const SizedBox(height: 46),
        // ── Cronograma ──────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Cronograma de Lições',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Próxima aula:\nLição ${nextLesson.number.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.25,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        ...lessons.map((lesson) {
          final lessonDay = DateTime(
            lesson.scheduledDate.year,
            lesson.scheduledDate.month,
            lesson.scheduledDate.day,
          );
          final isToday = lessonDay == today;
          final status = lesson.isCompleted
              ? _LessonStatus.done
              : isToday
              ? _LessonStatus.today
              : _LessonStatus.pending;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _LessonCard(
              lesson: lesson,
              status: status,
              classId: classId,
            ),
          );
        }),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MagazineHero extends StatelessWidget {
  const _MagazineHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D171A), Color(0xFF37628A)],
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 22),
            blurRadius: 55,
            color: Color(0x2237628A),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE3E9EE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: const Icon(
                Icons.public,
                color: Color(0xFF8B6F5C),
                size: 70,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'Aprofundando nas lições',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.status,
    required this.classId,
  });

  final EbdLesson lesson;
  final _LessonStatus status;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final isToday = status == _LessonStatus.today;
    final isPending = status == _LessonStatus.pending;
    final activeColor = isToday ? AppTheme.primary : AppTheme.outlineVariant;
    final numberStr = lesson.number.toString().padLeft(2, '0');
    final dateStr = _formatDate(lesson.scheduledDate);

    return InkWell(
      key: isToday ? const Key('take_attendance_button') : null,
      onTap: () => context.push(
        '/ebd/classes/$classId/lessons/${lesson.id}/attendance',
      ),
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: EdgeInsets.all(isToday ? 22 : 18),
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFFDCEBFA)
              : AppTheme.surfaceContainerLowest,
          border: isToday
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isToday ? null : AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            _LessonBadge(number: numberStr, active: isToday, muted: isPending),
            SizedBox(width: isToday ? 18 : 18),
            Expanded(
              child: _LessonText(
                dateStr: isToday ? 'HOJE • $dateStr' : dateStr,
                title: lesson.theme,
                status: status,
                active: isToday,
              ),
            ),
            Icon(
              isToday ? Icons.arrow_forward : Icons.chevron_right,
              color: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonBadge extends StatelessWidget {
  const _LessonBadge({
    required this.number,
    this.active = false,
    this.muted = false,
  });

  final String number;
  final bool active;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 58 : 52,
      height: active ? 58 : 52,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LIÇÃO',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
            ),
          ),
          Text(
            number,
            style: GoogleFonts.manrope(
              fontSize: active ? 22 : 20,
              fontWeight: FontWeight.w800,
              color: active
                  ? AppTheme.onPrimary
                  : muted
                  ? AppTheme.primary.withValues(alpha: 0.45)
                  : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonText extends StatelessWidget {
  const _LessonText({
    required this.dateStr,
    required this.title,
    required this.status,
    this.active = false,
  });

  final String dateStr;
  final String title;
  final _LessonStatus status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (status) {
      _LessonStatus.done => 'CONCLUÍDA',
      _LessonStatus.pending => 'PENDENTE',
      _LessonStatus.today => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              dateStr,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? AppTheme.primary : AppTheme.onSurfaceVariant,
              ),
            ),
            if (statusLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: status == _LessonStatus.done
                      ? const Color(0xFFCFF6D8)
                      : AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: status == _LessonStatus.done
                        ? const Color(0xFF087436)
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: active ? 21 : 17,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: active ? AppTheme.onPrimaryContainer : Colors.black,
          ),
        ),
      ],
    );
  }
}

enum _LessonStatus { done, today, pending }

String _formatDate(DateTime date) {
  const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  return '$day $month, ${date.year}';
}
