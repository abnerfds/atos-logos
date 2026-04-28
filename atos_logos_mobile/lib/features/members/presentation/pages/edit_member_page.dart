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
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../cubit/members_cubit.dart';
import '../widgets/inactivate_member_dialog.dart';

/// Secretariat edit form. Reads member data via [ProfileCubit] (existing
/// `/member-profiles/by-user/:userId` fetch) and writes via [MembersCubit]
/// (`PATCH /memberships/by-user/:userId/user-data` and
/// `PATCH /memberships/by-user/:userId/inactivate`).
class EditMemberPage extends StatefulWidget {
  final String userId;

  const EditMemberPage({super.key, required this.userId});

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
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
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  Sex? _selectedSex;
  CivilStatus? _selectedCivilStatus;
  String? _selectedPosition;
  String? _selectedBranch;
  List<Position> _availablePositions = [];
  List<Branch> _availableBranches = [];
  bool _saving = false;
  bool _inactivating = false;
  bool _controllersPopulated = false;
  // Captured from the loaded MemberProfile so `_onSave` can issue the
  // PATCH /member-profiles/:profileId that carries the date fields.
  String? _profileId;

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Sex? _sexFromWire(String? wire) {
    switch (wire) {
      case 'MALE':
        return Sex.male;
      case 'FEMALE':
        return Sex.female;
      default:
        return null;
    }
  }

  CivilStatus? _civilStatusFromWire(String? wire) {
    switch (wire) {
      case 'SINGLE':
        return CivilStatus.single;
      case 'MARRIED':
        return CivilStatus.married;
      case 'DIVORCED':
        return CivilStatus.divorced;
      case 'WIDOWED':
        return CivilStatus.widowed;
      case 'SEPARATED':
        return CivilStatus.separated;
      case 'STABLE_UNION':
        return CivilStatus.stableUnion;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadMemberProfileByUserId(widget.userId);
    _loadDropdownData();
  }

  /// Loads cargo + congregação options from the proper repositories
  /// (instead of the previous raw `getIt<Dio>()` calls). Silent failure
  /// — the form still works even if the options don't load.
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
      // Dropdown options are optional UX — keep the form usable.
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
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  /// One-shot population so re-typing by the secretary isn't overwritten
  /// by a later ProfileState rebuild.
  void _populateControllersOnce(ProfileState state) {
    if (_controllersPopulated) return;
    state.whenOrNull(
      loaded: (profile) {
        _profileId = profile.id;
        _nameController.text = profile.user?.name ?? '';
        _emailController.text = profile.user?.email ?? '';
        _cpfController.text = profile.user?.cpf ?? '';
        _phoneController.text = profile.user?.phone ?? '';
        // Dates are pre-filled in the Brazilian dd/MM/yyyy display format
        // so the secretary reads them naturally; `_toIsoDate` converts
        // back to ISO on save. Unchanged values round-trip losslessly.
        _birthDateController.text = _isoToDisplay(profile.birthDate);
        _baptismDateController.text = _isoToDisplay(profile.baptismDate);
        _admissionDateController.text = _isoToDisplay(profile.admissionDate);
        _consecrationDateController.text = _isoToDisplay(
          profile.consecrationDate,
        );
        _rgController.text = profile.user?.rg ?? '';
        _fatherNameController.text = profile.user?.fatherName ?? '';
        _motherNameController.text = profile.user?.motherName ?? '';
        _selectedSex = _sexFromWire(profile.user?.sex);
        _selectedCivilStatus = _civilStatusFromWire(profile.user?.civilStatus);
        _countryController.text = profile.user?.country ?? '';
        _stateController.text = profile.user?.state ?? '';
        _cityController.text = profile.user?.city ?? '';
        _neighborhoodController.text = profile.user?.neighborhood ?? '';
        _streetController.text = profile.user?.street ?? '';
        _numberController.text = profile.user?.number ?? '';
        _complementController.text = profile.user?.complement ?? '';
        _selectedBranch = profile.branchId;
        _selectedPosition = profile.positionId;
        _controllersPopulated = true;
      },
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF747C81),
        fontSize: 14,
      ),
      filled: true,
      fillColor: readOnly ? const Color(0xFFF0F4F8) : const Color(0xFFE3E9EE),
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

  /// Backend may send `yyyy-MM-dd` or a full ISO DateTime; the form shows
  /// `dd/MM/yyyy`. Returns the empty string when raw is null/invalid so
  /// the TextField stays empty.
  String _isoToDisplay(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final date = DateTime.tryParse(raw);
    if (date != null) {
      final dd = date.day.toString().padLeft(2, '0');
      final mm = date.month.toString().padLeft(2, '0');
      return '$dd/$mm/${date.year}';
    }
    final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (dateOnly == null) return '';
    return '${dateOnly.group(3)}/${dateOnly.group(2)}/${dateOnly.group(1)}';
  }

  /// Converts a dd/MM/yyyy string (from the date picker or the pre-fill)
  /// to the yyyy-MM-dd ISO shape the backend's @IsDateString expects.
  /// Returns null for empty or unparseable input so the repository strips
  /// the field from the payload instead of forwarding garbage.
  String? _toIsoDate(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (parts[2].length != 4) return null;
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;
    final dd = day.toString().padLeft(2, '0');
    final mm = month.toString().padLeft(2, '0');
    return '${parts[2]}-$mm-$dd';
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

  Future<void> _onSave() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final cubit = context.read<MembersCubit>();
      final profileId = _profileId;
      final birthDate = _toIsoDate(_birthDateController.text);
      final baptismDate = _toIsoDate(_baptismDateController.text);
      final admissionDate = _toIsoDate(_admissionDateController.text);
      final consecrationDate = _toIsoDate(_consecrationDateController.text);
      final branchIdForProfile = _selectedBranch;
      // User-level columns (name, contact, identity, address, cargo,
      // branch) go through /memberships/by-user/:userId/user-data.
      // Ecclesiastical dates live on a separate table (MemberProfile),
      // so we PATCH /member-profiles/:profileId in parallel — otherwise
      // editing birth/baptism/admission/consecration is a silent no-op.
      await Future.wait([
        cubit.updateMemberUserData(
          userId: widget.userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          cpf: _cpfController.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
          phone: _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
          rg: _rgController.text.trim(),
          sex: _selectedSex?.wireValue,
          civilStatus: _selectedCivilStatus?.wireValue,
          fatherName: _fatherNameController.text.trim(),
          motherName: _motherNameController.text.trim(),
          // Address fields — forwarded so the secretary can update them
          // from the edit form without a separate address screen.
          country: _countryController.text.trim(),
          state: _stateController.text.trim(),
          city: _cityController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          complement: _complementController.text.trim(),
          // Only forward branch/position when the secretary actually
          // picked them — leaving them null preserves the existing
          // cargo/congregação on the backend instead of blanking out.
          branchId: _selectedBranch,
          positionId: _selectedPosition,
        ),
        if (profileId != null)
          cubit.updateMemberProfile(
            profileId: profileId,
            birthDate: birthDate,
            baptismDate: baptismDate,
            admissionDate: admissionDate,
            consecrationDate: consecrationDate,
          )
        else if (birthDate != null &&
            admissionDate != null &&
            branchIdForProfile != null)
          cubit.createMemberProfile(
            userId: widget.userId,
            branchId: branchIdForProfile,
            birthDate: birthDate,
            baptismDate: baptismDate,
            admissionDate: admissionDate,
            consecrationDate: consecrationDate,
          ),
      ]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
      Navigator.of(context).pop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao salvar.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onInactivateConfirmed() async {
    if (_inactivating) return;
    setState(() => _inactivating = true);
    try {
      await context.read<MembersCubit>().inactivateMemberByUserId(
        widget.userId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Membro inativado.')));
      Navigator.of(context).pop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao inativar.')),
      );
    } finally {
      if (mounted) setState(() => _inactivating = false);
    }
  }

  void _showInactivateDialog(String memberName) {
    showDialog(
      context: context,
      builder: (_) => InactivateMemberDialog(
        memberName: memberName,
        onConfirm: _onInactivateConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            // Populate the form controllers the first time we see a loaded
            // state — inline (not via listener) because a listener only
            // fires on state TRANSITIONS, so a test that seeds the cubit
            // with `loaded` up-front would never run it.
            _populateControllersOnce(state);
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFFA83836),
                  ),
                ),
              ),
              loaded: (profile) => _buildForm(profile.user?.name ?? ''),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(String memberName) {
    final selectedPosition =
        _availablePositions.any((position) => position.id == _selectedPosition)
        ? _selectedPosition
        : null;
    final selectedBranch =
        _availableBranches.any((branch) => branch.id == _selectedBranch)
        ? _selectedBranch
        : null;

    return SingleChildScrollView(
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
                const Spacer(),
                Text(
                  'Atos Logos',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF37628A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // -- Avatar + Title --
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
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
                      size: 40,
                      color: Color(0xFFABB3B9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Editar Membro',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3338),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atualize os dados do membro',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF596065),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -- Section: Informacoes Pessoais --
            _buildSectionCard(
              icon: Icons.person_outlined,
              title: 'Informações Pessoais',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NOME COMPLETO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(hint: 'Nome completo'),
                    style: GoogleFonts.inter(fontSize: 14),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('E-MAIL'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DATA DE NASCIMENTO'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _birthDateController,
                              readOnly: true,
                              onTap: () => _selectDate(_birthDateController),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SEXO'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<Sex>(
                              initialValue: _selectedSex,
                              decoration: _inputDecoration(hint: 'Selecione'),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF2C3338),
                              ),
                              items: Sex.values
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedSex = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('ESTADO CIVIL'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<CivilStatus>(
                    initialValue: _selectedCivilStatus,
                    decoration: _inputDecoration(hint: 'Selecione'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF2C3338),
                    ),
                    items: CivilStatus.values
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.label)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCivilStatus = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -- Section: Filiação --
            _buildSectionCard(
              icon: Icons.family_restroom_outlined,
              title: 'Filiação',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NOME DO PAI'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _fatherNameController,
                    decoration: _inputDecoration(hint: 'Nome completo'),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('NOME DA MÃE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _motherNameController,
                    decoration: _inputDecoration(hint: 'Nome completo'),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -- Section: Dados Eclesiásticos --
            _buildSectionCard(
              icon: Icons.church_outlined,
              title: 'Dados Eclesiásticos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('DATA DE BATISMO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _baptismDateController,
                    readOnly: true,
                    onTap: () => _selectDate(_baptismDateController),
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
                  _buildLabel('DATA DE ADMISSÃO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _admissionDateController,
                    readOnly: true,
                    onTap: () => _selectDate(_admissionDateController),
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
                  _buildLabel('DATA DE CONSAGRAÇÃO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _consecrationDateController,
                    readOnly: true,
                    onTap: () => _selectDate(_consecrationDateController),
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
                  _buildLabel('CARGO'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPosition,
                    decoration: _inputDecoration(hint: 'Selecione o cargo'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF2C3338),
                    ),
                    items: _availablePositions
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPosition = v),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('CONGREGAÇÃO'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBranch,
                    decoration: _inputDecoration(
                      hint: 'Selecione a congregação',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF2C3338),
                    ),
                    items: _availableBranches
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBranch = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -- Zona de Perigo --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA83836)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zona de Perigo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFA83836),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _inactivating
                          ? null
                          : () => _showInactivateDialog(memberName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA83836),
                        side: const BorderSide(color: Color(0xFFA83836)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Inativar Membro',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -- Save Button --
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37628A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Salvar Registro',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF37628A)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3338),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDCE3E9)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: child,
          ),
        ],
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
