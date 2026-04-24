import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class EbdClassDetailsPage extends StatelessWidget {
  const EbdClassDetailsPage({super.key, this.classId = 'parabolas'});

  final String classId;

  static const _lessons = [
    _LessonOverview(
      number: '01',
      date: '01 Outubro, 2023',
      title: 'O Semeador e os Solos',
      status: _LessonStatus.done,
    ),
    _LessonOverview(
      number: '02',
      date: '08 Outubro, 2023',
      title: 'O Joio e o Trigo',
      status: _LessonStatus.done,
    ),
    _LessonOverview(
      number: '03',
      date: 'HOJE • 15 Outubro, 2023',
      title: 'A Pérola de Grande Valor',
      subtitle: 'Tema central: O valor incomparável do Reino de Deus.',
      status: _LessonStatus.today,
    ),
    _LessonOverview(
      number: '04',
      date: '22 Outubro, 2023',
      title: 'O Credor Incompassivo',
      status: _LessonStatus.pending,
    ),
    _LessonOverview(
      number: '05',
      date: '29 Outubro, 2023',
      title: 'O Bom Samaritano',
      status: _LessonStatus.pending,
    ),
    _LessonOverview(
      number: '06',
      date: '05 Novembro, 2023',
      title: 'O Amigo Importuno',
      status: _LessonStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 14),
        Text(
          'As Parábolas de Jesus',
          style: GoogleFonts.manrope(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoPill(icon: Icons.person, label: 'Prof. Ricardo Mendes'),
            _InfoPill(icon: Icons.calendar_today, label: '4º Trimestre 2023'),
          ],
        ),
        const SizedBox(height: 34),
        const _MagazineHero(),
        const SizedBox(height: 46),
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
                  'Próxima aula:\nLição 08',
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
        ..._lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _LessonCard(lesson: lesson, classId: classId),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          label: Text(
            'Ver todas as 13 lições',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          icon: const Icon(Icons.expand_more),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}

void _openAttendance(BuildContext context, String classId, String lessonId) {
  final router = GoRouter.maybeOf(context);
  final route = '/ebd/classes/$classId/lessons/$lessonId/attendance';
  if (router != null) {
    context.push(route);
  } else {
    context.push('/attendance');
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
  const _LessonCard({required this.lesson, required this.classId});

  final _LessonOverview lesson;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final isToday = lesson.status == _LessonStatus.today;
    final isPending = lesson.status == _LessonStatus.pending;
    final activeColor = isToday ? AppTheme.primary : AppTheme.outlineVariant;

    return InkWell(
      key: isToday ? const Key('take_attendance_button') : null,
      onTap: () => _openAttendance(context, classId, lesson.number),
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
            _LessonBadge(
              number: lesson.number,
              active: isToday,
              muted: isPending,
            ),
            SizedBox(width: isToday ? 18 : 18),
            Expanded(
              child: _LessonText(lesson: lesson, active: isToday),
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
  const _LessonText({required this.lesson, this.active = false});

  final _LessonOverview lesson;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (lesson.status) {
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
              lesson.date,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? AppTheme.primary : AppTheme.onSurfaceVariant,
              ),
            ),
            if (statusLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lesson.status == _LessonStatus.done
                      ? const Color(0xFFCFF6D8)
                      : AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: lesson.status == _LessonStatus.done
                        ? const Color(0xFF087436)
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          lesson.title,
          style: GoogleFonts.manrope(
            fontSize: active ? 21 : 17,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: active ? AppTheme.onPrimaryContainer : Colors.black,
          ),
        ),
        if (lesson.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            lesson.subtitle!,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.35,
              color: AppTheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LessonOverview {
  const _LessonOverview({
    required this.number,
    required this.date,
    required this.title,
    required this.status,
    this.subtitle,
  });

  final String number;
  final String date;
  final String title;
  final _LessonStatus status;
  final String? subtitle;
}

enum _LessonStatus { done, today, pending }
