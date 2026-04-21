import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late final TextEditingController _nameController;
  late final TextEditingController _cpfController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _countryController;
  late final TextEditingController _stateController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthCubit>().state;
    final user = authState.whenOrNull(
      authenticated: (profile) => profile?.user,
    );

    _nameController = TextEditingController(text: user?.name ?? '');
    _cpfController = TextEditingController(text: user?.cpf ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _stateController = TextEditingController(text: user?.state ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _neighborhoodController =
        TextEditingController(text: user?.neighborhood ?? '');
    _streetController = TextEditingController(text: user?.street ?? '');
    _numberController = TextEditingController(text: user?.number ?? '');
    _complementController =
        TextEditingController(text: user?.complement ?? '');
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileCubit>().updateMyProfile({
        'name': _nameController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _countryController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'street': _streetController.text.trim(),
        'number': _numberController.text.trim(),
        'complement': _complementController.text.trim(),
      });
    }
  }

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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFieldRow({
    required String label1,
    required TextEditingController controller1,
    required String label2,
    required TextEditingController controller2,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildField(label: label1, controller: controller1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(label: label2, controller: controller2),
        ),
      ],
    );
  }

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
            saved: () {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
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

                // Personal fields
                _buildField(
                  label: 'NOME COMPLETO',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'CPF',
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'TELEFONE',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'E-MAIL',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Address rows
                _buildFieldRow(
                  label1: 'PAÍS',
                  controller1: _countryController,
                  label2: 'ESTADO',
                  controller2: _stateController,
                ),
                const SizedBox(height: 16),
                _buildFieldRow(
                  label1: 'CIDADE',
                  controller1: _cityController,
                  label2: 'BAIRRO',
                  controller2: _neighborhoodController,
                ),
                const SizedBox(height: 16),
                _buildFieldRow(
                  label1: 'RUA',
                  controller1: _streetController,
                  label2: 'NÚMERO',
                  controller2: _numberController,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'COMPLEMENTO',
                  controller: _complementController,
                ),

                const SizedBox(height: 32),

                // Save button
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
