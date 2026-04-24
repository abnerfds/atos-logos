import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/ebd_class.dart';
import '../cubit/ebd_attendance_cubit.dart';

class EbdAttendancePage extends StatefulWidget {
  const EbdAttendancePage({
    super.key,
    required this.classId,
    required this.lessonId,
  });

  final String classId;
  final String lessonId;

  @override
  State<EbdAttendancePage> createState() => _EbdAttendancePageState();
}

class _EbdAttendancePageState extends State<EbdAttendancePage> {
  late final EbdAttendanceCubit _cubit;
  final _offeringController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EbdAttendanceCubit>()..loadAttendance(widget.lessonId);
  }

  @override
  void dispose() {
    _cubit.close();
    _offeringController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final offeringText = _offeringController.text
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final offering = double.tryParse(offeringText) ?? 0.0;

    final saved = await _cubit.saveAttendance(
      lessonId: widget.lessonId,
      offeringAmount: offering,
    );

    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamada finalizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ebd/classes/${widget.classId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<EbdAttendanceCubit, EbdAttendanceState>(
        listener: (context, state) {
          if (state is EbdAttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<EbdAttendanceCubit, EbdAttendanceState>(
          builder: (context, state) {
            if (state is EbdAttendanceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is EbdAttendanceError) {
              return Center(
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
                      state.message,
                      style: GoogleFonts.inter(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.loadAttendance(widget.lessonId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final students = switch (state) {
              EbdAttendanceLoaded(:final students) => students,
              EbdAttendanceSaving(:final students) => students,
              _ => <EbdAttendanceEntry>[],
            };
            final isSaving = state is EbdAttendanceSaving;

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
                      'Chamada da Lição',
                      style: GoogleFonts.manrope(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 54),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: isSaving
                            ? null
                            : () => _cubit.markAllPresent(),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.secondaryContainer,
                          foregroundColor: AppTheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXl,
                            ),
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
                    if (students.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Nenhum aluno matriculado nesta classe.',
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...students.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 26),
                          child: _StudentTile(
                            student: entry.value,
                            index: entry.key,
                            enabled: !isSaving,
                            onChanged: (value) => _cubit.togglePresence(
                              entry.value.memberId,
                              value,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _AttendanceFooter(
                    offeringController: _offeringController,
                    isSaving: isSaving,
                    onFinish: _finish,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.student,
    required this.index,
    required this.onChanged,
    this.enabled = true,
  });

  final EbdAttendanceEntry student;
  final int index;
  final ValueChanged<bool> onChanged;
  final bool enabled;

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
            backgroundImage: student.photoUrl != null
                ? NetworkImage(student.photoUrl!)
                : null,
            child: student.photoUrl == null
                ? Icon(
                    Icons.person,
                    color: index == 1 ? Colors.white : AppTheme.onPrimaryContainer,
                    size: 34,
                  )
                : null,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              student.name,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: student.isPresent,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppTheme.surfaceContainerHighest,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  Color _avatarColor(int index) {
    return switch (index % 4) {
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
    this.isSaving = false,
  });

  final TextEditingController offeringController;
  final VoidCallback onFinish;
  final bool isSaving;

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
                onPressed: isSaving ? null : onFinish,
                icon: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 34),
                iconAlignment: IconAlignment.end,
                label: Text(
                  isSaving ? 'Salvando...' : 'Finalizar Chamada',
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
        Text(
          'OFERTA DA CLASSE',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
