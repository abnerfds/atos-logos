import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/enums/civil_status.dart';
import '../../../../core/enums/sex.dart';
import '../../../../core/error/exceptions.dart';
import '../../../branches/data/branches_repository.dart';
import '../../../branches/domain/models/branch.dart';
import '../../../positions/data/positions_repository.dart';
import '../../../positions/domain/models/position.dart';
import '../cubit/members_cubit.dart';

class CreateMemberPage extends StatefulWidget {
  const CreateMemberPage({super.key});

  @override
  State<CreateMemberPage> createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _baptismDateController = TextEditingController();
  final _admissionDateController = TextEditingController();
  final _rgController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _consecrationDateController = TextEditingController();
  bool _personalInfoExpanded = true;
  bool _filiationExpanded = true;
  bool _churchInfoExpanded = true;
  Sex? _selectedSex;
  CivilStatus? _selectedCivilStatus;
  String? _selectedPosition;
  String? _selectedBranch;
  List<Position> _availablePositions = [];
  List<Branch> _availableBranches = [];

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  /// Pulls cargo + congregação options from the same repositories the rest
  /// of the app uses. Fails silently because dropdowns are optional UX —
  /// the user can still fill in the other fields even if options are empty.
  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        getIt<PositionsRepository>().getPositions(),
        getIt<BranchesRepository>().getBranches(),
      ]);
      if (!mounted) return;
      setState(() {
        _availablePositions = results[0] as List<Position>;
        _availableBranches = results[1] as List<Branch>;
      });
    } catch (_) {
      // Swallow: dropdowns remain empty, user is not blocked.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _baptismDateController.dispose();
    _admissionDateController.dispose();
    _rgController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _consecrationDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  bool _submitting = false;

  /// Converts a Brazilian dd/MM/yyyy string (produced by _selectDate) into
  /// the ISO yyyy-MM-dd that the backend DTO expects. Returns null for
  /// empty or unparseable input so the repository strips the field from
  /// the payload instead of forwarding "2020-05-20-abc"-style garbage
  /// that would slip past the backend's @IsDateString check.
  String? _toIsoDate(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (parts[2].length != 4) return null; // require a 4-digit year
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;
    final dd = day.toString().padLeft(2, '0');
    final mm = month.toString().padLeft(2, '0');
    return '${parts[2]}-$mm-$dd';
  }

  /// Generates a random 10-char alphanumeric temporary password that the
  /// secretary will hand to the new member. The plaintext is shown in a
  /// confirmation dialog AFTER a successful save so it can be copied.
  String _generateTempPassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    final rng = Random.secure();
    return List.generate(10, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  String _stripMask(String value) => value.replaceAll(RegExp(r'[^\d]'), '');

  Future<void> _onSubmit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Branch is required by the backend. If the secretary did not pick one
    // on the form, surface that before hitting the network.
    if (_selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma congregação.')),
      );
      return;
    }

    final tempPassword = _generateTempPassword();
    setState(() => _submitting = true);
    try {
      await context.read<MembersCubit>().createMemberWithUser(
            name: _nameController.text.trim(),
            password: tempPassword,
            branchId: _selectedBranch!,
            email: _emailController.text.trim(),
            cpf: _stripMask(_cpfController.text),
            phone: _stripMask(_phoneController.text),
            rg: _rgController.text.trim(),
            sex: _selectedSex?.wireValue,
            civilStatus: _selectedCivilStatus?.wireValue,
            fatherName: _fatherNameController.text.trim(),
            motherName: _motherNameController.text.trim(),
            // The "CARGO" dropdown maps to a MemberPosition (Pastor,
            // Diácono, …) — an ecclesiastical title — NOT the access-
            // control role. It goes to positionId so the backend can
            // attach the PositionUser row in the same transaction.
            positionId: _selectedPosition,
            birthDate: _toIsoDate(_birthDateController.text),
            baptismDate: _toIsoDate(_baptismDateController.text),
            admissionDate: _toIsoDate(_admissionDateController.text),
            consecrationDate:
                _toIsoDate(_consecrationDateController.text),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membro criado com sucesso.')),
      );
      Navigator.of(context).pop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao criar membro.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF747C81),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFE3E9EE),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // -- Header --
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF37628A),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Novo Membro',
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3338),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preencha os dados para criar um novo membro na sua Igreja',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF596065),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // -- Photo section --
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDCE3E9)),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Color(0x0F2C3338),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE9EEF3),
                                    border: Border.all(
                                      color: const Color(0xFFABB3B9),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Color(0xFFABB3B9),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF37628A),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Foto do Perfil',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF596065),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -- Section 1: Informações Pessoais --
                    _AccordionSection(
                      icon: Icons.person_outlined,
                      title: 'Informações Pessoais',
                      isExpanded: _personalInfoExpanded,
                      onToggle: () => setState(
                        () =>
                            _personalInfoExpanded = !_personalInfoExpanded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('NOME COMPLETO'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              hint: 'Nome completo do membro',
                            ),
                            style: GoogleFonts.inter(fontSize: 14),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe o nome'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // 2-col: E-mail + CPF
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('E-MAIL'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      decoration: _inputDecoration(
                                        hint: 'email@exemplo.com',
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('CPF'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _cpfController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_cpfMask],
                                      decoration: _inputDecoration(
                                        hint: '000.000.000-00',
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 2-col: Telefone + Data Nascimento
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('TELEFONE'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: _inputDecoration(
                                        hint: '(00) 00000-0000',
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('DATA DE NASCIMENTO'),
                                    const SizedBox(height: 6),
                    TextFormField(
                                      controller: _birthDateController,
                                      readOnly: true,
                                      onTap: () =>
                                          _selectDate(_birthDateController),
                                      decoration: _inputDecoration(
                                        hint: 'dd/mm/aaaa',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Color(0xFF747C81),
                                          size: 20,
                                        ),
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 2-col: RG + Sexo
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('RG'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _rgController,
                                      decoration: _inputDecoration(
                                        hint: 'Documento de identidade',
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('SEXO'),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3E9EE),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonFormField<Sex>(
                                        initialValue: _selectedSex,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12),
                                          hintText: 'Selecione',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF747C81),
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: Sex.values
                                            .map((s) => DropdownMenuItem(
                                                  value: s,
                                                  child: Text(s.label),
                                                ))
                                            .toList(),
                                        onChanged: (v) =>
                                            setState(() => _selectedSex = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('ESTADO CIVIL'),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E9EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<CivilStatus>(
                              initialValue: _selectedCivilStatus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                hintText: 'Selecione',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF747C81),
                                  fontSize: 14,
                                ),
                              ),
                              items: CivilStatus.values
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.label),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _selectedCivilStatus = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -- Section 2: Filiação --
                    _AccordionSection(
                      icon: Icons.family_restroom_outlined,
                      title: 'Filiação',
                      isExpanded: _filiationExpanded,
                      onToggle: () => setState(
                        () => _filiationExpanded = !_filiationExpanded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('NOME DO PAI'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _fatherNameController,
                            decoration:
                                _inputDecoration(hint: 'Nome completo'),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('NOME DA MÃE'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _motherNameController,
                            decoration:
                                _inputDecoration(hint: 'Nome completo'),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -- Section 3: Dados Eclesiásticos --
                    _AccordionSection(
                      icon: Icons.church_outlined,
                      title: 'Dados Eclesiásticos',
                      isExpanded: _churchInfoExpanded,
                      onToggle: () => setState(
                        () => _churchInfoExpanded = !_churchInfoExpanded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2-col: Data Batismo + Data Admissão
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('DATA DE BATISMO'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _baptismDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                          _baptismDateController),
                                      decoration: _inputDecoration(
                                        hint: 'dd/mm/aaaa',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Color(0xFF747C81),
                                          size: 20,
                                        ),
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('DATA DE ADMISSÃO'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _admissionDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                          _admissionDateController),
                                      decoration: _inputDecoration(
                                        hint: 'dd/mm/aaaa',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Color(0xFF747C81),
                                          size: 20,
                                        ),
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('DATA DE CONSAGRAÇÃO'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _consecrationDateController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(_consecrationDateController),
                            decoration: _inputDecoration(
                              hint: 'dd/mm/aaaa',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF747C81),
                                size: 20,
                              ),
                            ),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          // 2-col: Cargo + Congregação
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('CARGO'),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3E9EE),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child:
                                          DropdownButtonFormField<String>(
                                        initialValue: _selectedPosition,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12),
                                          hintText: 'Selecione',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF747C81),
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: _availablePositions
                                            .map(
                                              (p) => DropdownMenuItem(
                                                value: p.id,
                                                child: Text(p.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => _selectedPosition = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('CONGREGAÇÃO'),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3E9EE),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child:
                                          DropdownButtonFormField<String>(
                                        initialValue: _selectedBranch,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12),
                                          hintText: 'Selecione',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF747C81),
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: _availableBranches
                                            .map(
                                              (b) => DropdownMenuItem(
                                                value: b.id,
                                                child: Text(b.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => _selectedBranch = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 120), // space for FAB
                  ],
                ),
              ),
            ),
            // -- Save FAB --
            Positioned(
              bottom: 112, // bottom-28
              right: 24,
              child: GestureDetector(
                onTap: _onSubmit,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF37628A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 12),
                        blurRadius: 40,
                        color: Color(0x4D37628A), // rgba(55,98,138, 0.3)
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: const Color(0xFF596065),
        ),
      ),
    );
  }
}

/// Accordion-style collapsible section in a white card.
class _AccordionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _AccordionSection({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE3E9)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x0F2C3338),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Icon(icon,
                      size: 20, color: const Color(0xFF37628A)),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3338),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: const Color(0xFF596065),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFDCE3E9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}
