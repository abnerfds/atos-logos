import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/ebd_repository.dart';
import '../cubit/ebd_cubit.dart';
import '../cubit/ebd_state.dart';

class CreateEbdQuarterPage extends StatefulWidget {
  const CreateEbdQuarterPage({super.key});

  @override
  State<CreateEbdQuarterPage> createState() => _CreateEbdQuarterPageState();
}

class _CreateEbdQuarterPageState extends State<CreateEbdQuarterPage> {
  late final EbdCubit _cubit;
  late final EbdRepository _repository;
  final _formKey = GlobalKey<FormState>();
  final _magazineController = TextEditingController();
  final _targetAudienceController = TextEditingController(text: 'Geral');
  final _quarterController = TextEditingController(text: '2026.2');
  final _startDateController = TextEditingController();
  late final List<TextEditingController> _lessonControllers;
  EbdSetupOptions? _setupOptions;
  final _selectedTeacherIds = <String>{};
  final _selectedStudentIds = <String>{};
  String? _setupError;
  var _isLoadingSetup = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EbdCubit>();
    _repository = getIt<EbdRepository>();
    _lessonControllers = List.generate(
      13,
      (index) => TextEditingController(
        text: index == 0 ? 'O Propósito da Mordomia' : '',
      ),
    );
    _loadSetupOptions();
  }

  @override
  void dispose() {
    _cubit.close();
    _magazineController.dispose();
    _targetAudienceController.dispose();
    _quarterController.dispose();
    _startDateController.dispose();
    for (final controller in _lessonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSetupOptions() async {
    try {
      final options = await _repository.getSetupOptions();
      if (!mounted) return;
      setState(() {
        _setupOptions = options;
        _isLoadingSetup = false;
        _setupError = null;
        if (options.activeQuarter != null) {
          _quarterController.text = options.activeQuarter!.name;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingSetup = false;
        _setupError = 'Não foi possível carregar membros e professores';
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? branchId;
    context.read<AuthCubit>().state.maybeWhen(
      authenticated: (profile) => branchId = profile?.branch.id,
      orElse: () {},
    );

    if (branchId == null || branchId!.isEmpty) {
      _showMessage('Não foi possível identificar a congregação do usuário');
      return;
    }

    if (_selectedTeacherIds.isEmpty) {
      _showMessage('Selecione pelo menos um professor');
      return;
    }

    final lessons = _buildLessons();
    if (lessons == null) return;

    setState(() => _isSaving = true);
    final saved = await _cubit.createClass(
      name: _magazineController.text.trim(),
      branchId: branchId!,
      targetAudience: _targetAudienceController.text.trim().isEmpty
          ? 'Geral'
          : _targetAudienceController.text.trim(),
      quarterId: _setupOptions?.activeQuarter?.name == _quarterController.text
          ? _setupOptions?.activeQuarter?.id
          : null,
      quarterName: _quarterController.text.trim(),
      teacherIds: _selectedTeacherIds.toList(),
      studentIds: _selectedStudentIds.toList(),
      lessons: lessons,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      _showMessage('Classe iniciada com sucesso');
      if (GoRouter.maybeOf(context) != null) {
        context.go('/ebd');
      }
    } else {
      final state = _cubit.state;
      final message = state.when(
        initial: () => 'Não foi possível salvar a classe',
        loading: () => 'Não foi possível salvar a classe',
        loaded: (_) => 'Não foi possível salvar a classe',
        error: (message) => message,
      );
      _showMessage(message);
    }
  }

  List<EbdLessonInput>? _buildLessons() {
    final startDate = _parseDate(_startDateController.text.trim());
    if (startDate == null) {
      _showMessage('Informe uma data de início válida');
      return null;
    }

    final lessons = <EbdLessonInput>[];
    for (var index = 0; index < _lessonControllers.length; index++) {
      final theme = _lessonControllers[index].text.trim();
      if (theme.isEmpty) {
        _showMessage('Informe o tema da lição ${index + 1}');
        return null;
      }
      final scheduledDate = startDate.add(Duration(days: index * 7));
      lessons.add(
        EbdLessonInput(
          theme: theme,
          scheduledDate: _formatApiDate(scheduledDate),
        ),
      );
    }
    return lessons;
  }

  DateTime? _parseDate(String value) {
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final parts = value.split(RegExp(r'[/.-]'));
    if (parts.length != 3) return null;
    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (first == null || second == null || year == null) return null;

    final day = first > 12 ? first : second;
    final month = first > 12 ? second : first;
    return DateTime(year, month, day);
  }

  String _formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 120),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const Key('create_ebd_quarter_back_button'),
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
            const _StepperHeader(),
            const SizedBox(height: 34),
            Container(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurar Novo Trimestre',
                    style: GoogleFonts.manrope(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha as informações essenciais para iniciar a nova classe da Escola Bíblica Dominical.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _FieldLabel(
                    label: 'Nome da Revista',
                    child: TextFormField(
                      controller: _magazineController,
                      decoration: _inputDecoration('Ex: O Fruto do Espírito'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome da revista';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  _FieldLabel(
                    label: 'Público-alvo',
                    child: TextFormField(
                      controller: _targetAudienceController,
                      decoration: _inputDecoration('Ex: Adultos'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _FieldLabel(
                          label: 'Trimestre / Ano',
                          child: TextFormField(
                            controller: _quarterController,
                            decoration: _inputDecoration('2026.2'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FieldLabel(
                          label: 'Data de Início',
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: _inputDecoration('mm/dd/yyyy').copyWith(
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            keyboardType: TextInputType.datetime,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _SetupOptionsSection(
                    isLoading: _isLoadingSetup,
                    error: _setupError,
                    options: _setupOptions,
                    selectedTeacherIds: _selectedTeacherIds,
                    selectedStudentIds: _selectedStudentIds,
                    onRetry: _loadSetupOptions,
                    onTeacherChanged: (memberId, selected) {
                      setState(() {
                        if (selected) {
                          _selectedTeacherIds.add(memberId);
                        } else {
                          _selectedTeacherIds.remove(memberId);
                        }
                      });
                    },
                    onStudentChanged: (memberId, selected) {
                      setState(() {
                        if (selected) {
                          _selectedStudentIds.add(memberId);
                        } else {
                          _selectedStudentIds.remove(memberId);
                        }
                      });
                    },
                    onSelectAllStudents: () {
                      final students = _setupOptions?.students ?? const [];
                      setState(() {
                        if (_selectedStudentIds.length == students.length) {
                          _selectedStudentIds.clear();
                        } else {
                          _selectedStudentIds
                            ..clear()
                            ..addAll(
                              students.map((student) => student.memberId),
                            );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 34),
                  _LessonsPreview(
                    controllers: _lessonControllers,
                    startDateText: _startDateController.text,
                    parseDate: _parseDate,
                    formatDate: _formatShortDate,
                    onChanged: () {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const Key('save_ebd_class_button'),
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Salvar e Iniciar Classe'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

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

class _SetupOptionsSection extends StatelessWidget {
  const _SetupOptionsSection({
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
          const _EmptySetupText('Nenhum professor/membro disponível')
        else
          ...teachers
              .take(8)
              .map(
                (teacher) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PersonTile(
                    person: teacher,
                    selected: selectedTeacherIds.contains(teacher.memberId),
                    onChanged: (selected) =>
                        onTeacherChanged(teacher.memberId, selected),
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
          const _EmptySetupText('Nenhum membro disponível para matrícula')
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PersonTile(
                person: student,
                selected: selectedStudentIds.contains(student.memberId),
                onChanged: (selected) =>
                    onStudentChanged(student.memberId, selected),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptySetupText extends StatelessWidget {
  const _EmptySetupText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
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
              onChanged: (value) => onChanged(value ?? false),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'ADMIN' => 'Administrador',
      'SECRETARY' => 'Secretaria',
      _ => 'Membro',
    };
  }
}

class _LessonsPreview extends StatelessWidget {
  const _LessonsPreview({
    required this.controllers,
    required this.startDateText,
    required this.parseDate,
    required this.formatDate,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final String startDateText;
  final DateTime? Function(String value) parseDate;
  final String Function(DateTime date) formatDate;
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
          ...List.generate(controllers.length, (index) {
            final date = startDate?.add(Duration(days: index * 7));
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LessonRow(
                date: date == null ? '-- ---' : formatDate(date),
                active: index == 0,
                number: index + 1,
                controller: controllers[index],
                hint: 'Lição ${index + 1}: Título da lição...',
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o tema';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
