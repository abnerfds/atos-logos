import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/ebd_repository.dart';
import '../cubit/ebd_class_details_cubit.dart';
import '../cubit/ebd_cubit.dart';
import '../cubit/ebd_state.dart';
import '../widgets/ebd_class_form_widgets.dart';

class EditEbdClassPage extends StatefulWidget {
  const EditEbdClassPage({super.key, required this.classId});

  final String classId;

  @override
  State<EditEbdClassPage> createState() => _EditEbdClassPageState();
}

class _EditEbdClassPageState extends State<EditEbdClassPage> {
  late final EbdCubit _cubit;
  late final EbdRepository _repository;
  late final EbdClassDetailsCubit _detailsCubit;

  final _formKey = GlobalKey<FormState>();
  final _magazineController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _quarterController = TextEditingController();
  final _startDateController = TextEditingController();
  late final List<TextEditingController> _lessonControllers;

  EbdSetupOptions? _setupOptions;
  final _selectedTeacherIds = <String>{};
  final _selectedStudentIds = <String>{};

  String? _setupError;
  bool _isLoadingSetup = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<EbdCubit>();
    _repository = getIt<EbdRepository>();
    _detailsCubit = getIt<EbdClassDetailsCubit>();
    _lessonControllers = List.generate(13, (_) => TextEditingController());
    _loadAll();
  }

  @override
  void dispose() {
    _cubit.close();
    _detailsCubit.close();
    _magazineController.dispose();
    _targetAudienceController.dispose();
    _quarterController.dispose();
    _startDateController.dispose();
    for (final c in _lessonControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadClassData(), _loadSetupOptions()]);
  }

  Future<void> _loadClassData() async {
    try {
      await _detailsCubit.loadDetails(widget.classId);
      if (!mounted) return;

      final state = _detailsCubit.state;
      if (state is! EbdClassDetailsLoaded) return;

      _magazineController.text = state.classDetail.name;
      _targetAudienceController.text = state.classDetail.targetAudience ?? '';
      _quarterController.text = state.classDetail.quarterName ?? '';

      for (final t in state.classDetail.teachers) {
        _selectedTeacherIds.add(t.id);
      }

      for (var i = 0; i < state.lessons.length && i < 13; i++) {
        _lessonControllers[i].text = state.lessons[i].theme;
      }

      if (state.lessons.isNotEmpty) {
        final first = state.lessons.first.scheduledDate;
        _startDateController.text =
            '${first.month.toString().padLeft(2, '0')}/'
            '${first.day.toString().padLeft(2, '0')}/'
            '${first.year}';
      }

      // Load enrolled students so their checkboxes start pre-selected
      final enrolledIds =
          await _repository.getEnrollmentIds(widget.classId);
      _selectedStudentIds.addAll(enrolledIds);

      if (mounted) setState(() {});
    } catch (_) {
      // Non-fatal — form still usable
    }
  }

  Future<void> _loadSetupOptions() async {
    try {
      final options = await _repository.getSetupOptions();
      if (!mounted) return;
      setState(() {
        _setupOptions = options;
        _isLoadingSetup = false;
        _setupError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingSetup = false;
        _setupError = 'Não foi possível carregar membros e professores';
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedTeacherIds.isEmpty) {
      _showMessage('Selecione pelo menos um professor');
      return;
    }

    final lessons = _buildLessons();
    if (lessons == null) return;

    setState(() => _isSaving = true);
    final saved = await _cubit.updateClass(
      classId: widget.classId,
      name: _magazineController.text.trim(),
      targetAudience: _targetAudienceController.text.trim().isEmpty
          ? 'Geral'
          : _targetAudienceController.text.trim(),
      quarterName: _quarterController.text.trim().isEmpty
          ? null
          : _quarterController.text.trim(),
      teacherIds: _selectedTeacherIds.toList(),
      studentIds: _selectedStudentIds.toList(),
      lessons: lessons,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (saved) {
      _showMessage('Classe atualizada com sucesso');
      if (context.canPop()) context.pop();
    } else {
      final state = _cubit.state;
      final message = state.when(
        initial: () => 'Não foi possível salvar',
        loading: () => 'Não foi possível salvar',
        loaded: (_) => 'Não foi possível salvar',
        error: (msg) => msg,
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
    for (var i = 0; i < _lessonControllers.length; i++) {
      final theme = _lessonControllers[i].text.trim();
      if (theme.isEmpty) {
        _showMessage('Informe o tema da lição ${i + 1}');
        return null;
      }
      lessons.add(
        EbdLessonInput(
          theme: theme,
          scheduledDate: _formatApiDate(
            startDate.add(Duration(days: i * 7)),
          ),
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

  String _formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _formatShortDate(DateTime date) {
    const months = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                key: const Key('edit_ebd_class_back_button'),
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
            const SizedBox(height: 12),
            const EbdStepperHeader(),
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
                    'Editar Classe',
                    style: GoogleFonts.manrope(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atualize as informações essenciais da classe da Escola Bíblica Dominical.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 34),
                  EbdFieldLabel(
                    label: 'Nome da Revista',
                    child: TextFormField(
                      controller: _magazineController,
                      decoration: _inputDecoration('Ex: O Fruto do Espírito'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Informe o nome da revista'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 22),
                  EbdFieldLabel(
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
                        child: EbdFieldLabel(
                          label: 'Trimestre / Ano',
                          child: TextFormField(
                            controller: _quarterController,
                            decoration: _inputDecoration('2026.2'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: EbdFieldLabel(
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
                  EbdSetupOptionsSection(
                    isLoading: _isLoadingSetup,
                    error: _setupError,
                    options: _setupOptions,
                    selectedTeacherIds: _selectedTeacherIds,
                    selectedStudentIds: _selectedStudentIds,
                    onRetry: _loadSetupOptions,
                    onTeacherChanged: (id, selected) => setState(() {
                      if (selected) {
                        _selectedTeacherIds.add(id);
                      } else {
                        _selectedTeacherIds.remove(id);
                      }
                    }),
                    onStudentChanged: (id, selected) => setState(() {
                      if (selected) {
                        _selectedStudentIds.add(id);
                      } else {
                        _selectedStudentIds.remove(id);
                      }
                    }),
                    onSelectAllStudents: () {
                      final students = _setupOptions?.students ?? const [];
                      setState(() {
                        if (_selectedStudentIds.length == students.length) {
                          _selectedStudentIds.clear();
                        } else {
                          _selectedStudentIds
                            ..clear()
                            ..addAll(students.map((s) => s.memberId));
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 34),
                  EbdLessonsPreview(
                    controllers: _lessonControllers,
                    startDateText: _startDateController.text,
                    parseDate: _parseDate,
                    formatDate: _formatShortDate,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const Key('save_edit_ebd_class_button'),
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
                          : const Icon(Icons.save_outlined),
                      label: const Text('Salvar Alterações'),
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
}
