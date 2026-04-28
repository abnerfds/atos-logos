import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadFreshProfile();
  }

  Future<void> _loadFreshProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await context.read<AuthCubit>().fetchProfile();
      if (!mounted) return;
      _populateFromAuthCubit();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Erro ao carregar perfil. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _populateFromAuthCubit() {
    final user = context.read<AuthCubit>().state.maybeWhen(
      authenticated: (profile) => profile?.user,
      orElse: () => null,
    );
    if (user == null) return;

    _nameController.text = user.name;
    _cpfController.text = _applyMask(user.cpf ?? '', '###.###.###-##');
    _phoneController.text = _applyMask(user.phone ?? '', '(##) #####-####');
    _emailController.text = user.email;
    _countryController.text = user.country ?? '';
    _stateController.text = user.state ?? '';
    _cityController.text = user.city ?? '';
    _neighborhoodController.text = user.neighborhood ?? '';
    _streetController.text = user.street ?? '';
    _numberController.text = user.number ?? '';
    _complementController.text = user.complement ?? '';
  }

  /// Applies a mask pattern to a string of digits.
  /// '#' in the mask is replaced by the next digit; other chars are literals.
  String _applyMask(String value, String mask) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    var digitIndex = 0;
    for (var i = 0; i < mask.length && digitIndex < digits.length; i++) {
      if (mask[i] == '#') {
        buffer.write(digits[digitIndex++]);
      } else {
        buffer.write(mask[i]);
      }
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  String _stripDigits(String value) =>
      value.replaceAll(RegExp(r'[^\d]'), '');

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? opt(String v) => v.trim().isEmpty ? null : v.trim();

    context.read<ProfileCubit>().updateMyProfile({
      'name': _nameController.text.trim(),
      if (opt(_cpfController.text) != null)
        'cpf': _stripDigits(_cpfController.text),
      if (opt(_phoneController.text) != null)
        'phone': _stripDigits(_phoneController.text),
      if (opt(_emailController.text) != null) 'email': opt(_emailController.text),
      if (opt(_countryController.text) != null) 'country': opt(_countryController.text),
      if (opt(_stateController.text) != null) 'state': opt(_stateController.text),
      if (opt(_cityController.text) != null) 'city': opt(_cityController.text),
      if (opt(_neighborhoodController.text) != null) 'neighborhood': opt(_neighborhoodController.text),
      if (opt(_streetController.text) != null) 'street': opt(_streetController.text),
      if (opt(_numberController.text) != null) 'number': opt(_numberController.text),
      if (opt(_complementController.text) != null) 'complement': opt(_complementController.text),
    });
  }

  // ── Decoration helpers ────────────────────────────────────────────────

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF747C81),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3E9EE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3E9EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF37628A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA83836)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA83836)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF596065),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Field builders ────────────────────────────────────────────────────

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('NOME COMPLETO'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration(hintText: 'Nome completo'),
          style: GoogleFonts.inter(fontSize: 14),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
        ),
      ],
    );
  }

  Widget _buildCpfField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('CPF'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cpfController,
          keyboardType: TextInputType.number,
          inputFormatters: [_cpfMask],
          decoration: _inputDecoration(hintText: '000.000.000-00'),
          style: GoogleFonts.inter(fontSize: 14),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (_stripDigits(v).length != 11) return 'CPF inválido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('TELEFONE'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneMask],
          decoration: _inputDecoration(hintText: '(00) 00000-0000'),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('E-MAIL'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hintText: 'email@exemplo.com'),
          style: GoogleFonts.inter(fontSize: 14),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
            if (!emailRegex.hasMatch(v.trim())) return 'E-mail inválido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hintText: hintText),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3338)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Atos Logos',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3338),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2C3338)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          state.whenOrNull(
            saved: () async {
              await context.read<AuthCubit>().fetchProfile();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil salvo com sucesso')),
              );
              Navigator.of(context).maybePop();
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF37628A)),
              )
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _loadError!,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA83836),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFreshProfile,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Avatar ────────────────────────────────────────
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFCDE6F4),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF37628A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toque para alterar a foto',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF596065),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Dados pessoais ────────────────────────────────
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildRow(_buildCpfField(), _buildPhoneField()),
                      const SizedBox(height: 16),
                      _buildEmailField(),

                      const SizedBox(height: 24),

                      // ── Endereço ──────────────────────────────────────
                      _buildRow(
                        _buildTextField(
                          label: 'PAÍS',
                          controller: _countryController,
                        ),
                        _buildTextField(
                          label: 'ESTADO',
                          controller: _stateController,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRow(
                        _buildTextField(
                          label: 'CIDADE',
                          controller: _cityController,
                        ),
                        _buildTextField(
                          label: 'BAIRRO',
                          controller: _neighborhoodController,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRow(
                        _buildTextField(
                          label: 'RUA',
                          controller: _streetController,
                        ),
                        _buildTextField(
                          label: 'NÚMERO',
                          controller: _numberController,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'COMPLEMENTO',
                        controller: _complementController,
                      ),

                      const SizedBox(height: 32),

                      // ── Salvar ────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            final isSaving = state.maybeWhen(
                              saving: () => true,
                              orElse: () => false,
                            );
                            return FilledButton(
                              onPressed: isSaving ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF37628A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'SALVAR',
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
