import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class EbdAttendancePage extends StatefulWidget {
  const EbdAttendancePage({
    super.key,
    this.classId = 'parabolas',
    this.lessonId = '04',
  });

  final String classId;
  final String lessonId;

  @override
  State<EbdAttendancePage> createState() => _EbdAttendancePageState();
}

class _EbdAttendancePageState extends State<EbdAttendancePage> {
  final _offeringController = TextEditingController();
  final List<_StudentPresence> _students = [
    _StudentPresence('Adriano Silva', 'Assíduo', true),
    _StudentPresence('Beatriz Oliveira', 'Faltou domingo passado', false),
    _StudentPresence('Carlos Eduardo', 'Líder de Louvor', false),
    _StudentPresence('Daniela Santos', 'Secretária', true),
  ];

  @override
  void dispose() {
    _offeringController.dispose();
    super.dispose();
  }

  void _markAllPresent() {
    setState(() {
      for (final student in _students) {
        student.present = true;
      }
    });
  }

  void _finish() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Chamada finalizada')));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(38, 22, 38, 200),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const Key('ebd_attendance_back_button'),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/ebd/classes/${widget.classId}');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.primary,
                tooltip: 'Voltar',
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Lição 04: O Bom Samaritano',
              style: GoogleFonts.manrope(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppTheme.onSurfaceVariant,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data: 26/04/2026',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 54),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _markAllPresent,
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                  foregroundColor: AppTheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                icon: const Icon(Icons.done_all, size: 30),
                label: Text(
                  'Marcar todos como presentes',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 54),
            Text(
              'LISTA DE ALUNOS',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 26),
            ...List.generate(
              _students.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: _StudentTile(
                  student: _students[index],
                  index: index,
                  onChanged: (value) {
                    setState(() => _students[index].present = value);
                  },
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _AttendanceFooter(
            offeringController: _offeringController,
            onFinish: _finish,
          ),
        ),
      ],
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.student,
    required this.index,
    required this.onChanged,
  });

  final _StudentPresence student;
  final int index;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _avatarColor(index),
            child: Icon(
              Icons.person,
              color: index == 1 ? Colors.white : AppTheme.onPrimaryContainer,
              size: 34,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  student.note,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: student.present,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppTheme.surfaceContainerHighest,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Color _avatarColor(int index) {
    return switch (index) {
      1 => Colors.black,
      2 => const Color(0xFF5DC4BA),
      3 => const Color(0xFFF43F5E),
      _ => AppTheme.secondaryContainer,
    };
  }
}

class _AttendanceFooter extends StatelessWidget {
  const _AttendanceFooter({
    required this.offeringController,
    required this.onFinish,
  });

  final TextEditingController offeringController;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38, 28, 38, 30),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.94),
        border: const Border(
          top: BorderSide(color: AppTheme.surfaceContainerHighest),
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, -8),
            blurRadius: 30,
            color: Color(0x0F2C3338),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OfferingInput(controller: offeringController),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.send, size: 34),
                iconAlignment: IconAlignment.end,
                label: Text(
                  'Finalizar Chamada',
                  style: GoogleFonts.manrope(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferingInput extends StatelessWidget {
  const _OfferingInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FooterLabel('OFERTA DA CLASSE'),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'R\$  ',
            hintText: '0,00',
            filled: true,
            fillColor: AppTheme.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            prefixStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurfaceVariant,
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _FooterLabel extends StatelessWidget {
  const _FooterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: AppTheme.onSurfaceVariant,
      ),
    );
  }
}

class _StudentPresence {
  _StudentPresence(this.name, this.note, this.present);

  final String name;
  final String note;
  bool present;
}
