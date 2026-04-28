/// Shared form widgets used by both CreateEbdQuarterPage and EditEbdClassPage.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/ebd_repository.dart';

// ── FieldLabel ────────────────────────────────────────────────────────────────

class EbdFieldLabel extends StatelessWidget {
  const EbdFieldLabel({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── StepperHeader ─────────────────────────────────────────────────────────────

class EbdStepperHeader extends StatelessWidget {
  const EbdStepperHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StepItem(number: '1', label: 'Dados Base', selected: true),
        Expanded(child: _StepLine(active: true)),
        _StepItem(number: '2', label: 'Matrícula'),
        Expanded(child: _StepLine()),
        _StepItem(number: '3', label: 'Cronograma'),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.label,
    this.selected = false,
  });

  final String number;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: selected ? AppTheme.primary : AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 28),
      color: active
          ? AppTheme.primary.withValues(alpha: 0.22)
          : AppTheme.surfaceContainer,
    );
  }
}

// ── SetupOptionsSection ───────────────────────────────────────────────────────

class EbdSetupOptionsSection extends StatelessWidget {
  const EbdSetupOptionsSection({
    super.key,
    required this.isLoading,
    required this.error,
    required this.options,
    required this.selectedTeacherIds,
    required this.selectedStudentIds,
    required this.onRetry,
    required this.onTeacherChanged,
    required this.onStudentChanged,
    required this.onSelectAllStudents,
  });

  final bool isLoading;
  final String? error;
  final EbdSetupOptions? options;
  final Set<String> selectedTeacherIds;
  final Set<String> selectedStudentIds;
  final VoidCallback onRetry;
  final void Function(String memberId, bool selected) onTeacherChanged;
  final void Function(String memberId, bool selected) onStudentChanged;
  final VoidCallback onSelectAllStudents;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (error != null) {
      return Column(
        children: [
          Text(error!, style: GoogleFonts.inter(color: AppTheme.error)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    final teachers = options?.teachers ?? const <EbdPersonOption>[];
    final students = options?.students ?? const <EbdPersonOption>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professores',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (teachers.isEmpty)
          _EmptyText('Nenhum professor/membro disponível')
        else
          ...teachers.take(8).map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EbdPersonTile(
                person: t,
                selected: selectedTeacherIds.contains(t.memberId),
                onChanged: (v) => onTeacherChanged(t.memberId, v),
              ),
            ),
          ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Matrícula de Membros',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('select_all_ebd_students'),
              onPressed: students.isEmpty ? null : onSelectAllStudents,
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Selecionar Todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (students.isEmpty)
          _EmptyText('Nenhum membro disponível para matrícula')
        else
          ...students.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EbdPersonTile(
                person: s,
                selected: selectedStudentIds.contains(s.memberId),
                onChanged: (v) => onStudentChanged(s.memberId, v),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}

// ── PersonTile ────────────────────────────────────────────────────────────────

class EbdPersonTile extends StatelessWidget {
  const EbdPersonTile({
    super.key,
    required this.person,
    required this.selected,
    required this.onChanged,
  });

  final EbdPersonOption person;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('ebd_person_${person.memberId}'),
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryContainer,
              backgroundImage: person.photoUrl == null
                  ? null
                  : NetworkImage(person.photoUrl!),
              child: person.photoUrl == null
                  ? Text(
                      person.name.characters.first,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _roleLabel(person.role),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
    'ADMIN' => 'Administrador',
    'SECRETARY' => 'Secretaria',
    _ => 'Membro',
  };
}

// ── LessonsPreview ────────────────────────────────────────────────────────────

class EbdLessonsPreview extends StatelessWidget {
  const EbdLessonsPreview({
    super.key,
    required this.controllers,
    required this.startDateText,
    required this.parseDate,
    required this.formatDate,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final String startDateText;
  final DateTime? Function(String) parseDate;
  final String Function(DateTime) formatDate;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final startDate = parseDate(startDateText);

    return Container(
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.surfaceContainerHigh)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Temas das Lições',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '13 SEMANAS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(controllers.length, (i) {
            final date = startDate?.add(Duration(days: i * 7));
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LessonRow(
                date: date == null ? '-- ---' : formatDate(date),
                active: i == 0,
                number: i + 1,
                controller: controllers[i],
                hint: 'Lição ${i + 1}: Título da lição...',
                onChanged: onChanged,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.date,
    required this.number,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.active = false,
  });

  final String date;
  final int number;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? hint;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primary : AppTheme.outline;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Column(
            children: [
              Text(
                date,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              prefixText: '$number. ',
              hintText: hint,
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o tema' : null,
          ),
        ),
      ],
    );
  }
}
