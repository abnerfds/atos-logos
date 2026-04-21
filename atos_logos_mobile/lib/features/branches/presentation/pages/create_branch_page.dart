import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/branches_cubit.dart';
import '../cubit/branches_state.dart';

class CreateBranchPage extends StatefulWidget {
  const CreateBranchPage({super.key});

  @override
  State<CreateBranchPage> createState() => _CreateBranchPageState();
}

class _CreateBranchPageState extends State<CreateBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF747C81),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFE3E9EE),
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<BranchesCubit>().createBranch(
            name: _nameController.text.trim(),
            country: _countryController.text.trim().isNotEmpty
                ? _countryController.text.trim()
                : null,
            state: _stateController.text.trim().isNotEmpty
                ? _stateController.text.trim()
                : null,
            city: _cityController.text.trim().isNotEmpty
                ? _cityController.text.trim()
                : null,
            neighborhood: _neighborhoodController.text.trim().isNotEmpty
                ? _neighborhoodController.text.trim()
                : null,
            street: _streetController.text.trim().isNotEmpty
                ? _streetController.text.trim()
                : null,
            number: _numberController.text.trim().isNotEmpty
                ? _numberController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BranchesCubit, BranchesState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (_, query) => context.pop(),
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: const Color(0xFFA83836),
              ),
            );
          },
        );
      },
      child: Container(
        color: const Color(0xFFF7F9FC),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // -- Back button --
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
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
                  const SizedBox(height: 24),
                  // -- Header icon + title --
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDE6F4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.church,
                            color: Color(0xFF37628A),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nova Unidade',
                          style: GoogleFonts.manrope(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3338),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cadastrar Congregação',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF596065),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Preencha os dados para cadastrar uma nova unidade',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF747C81),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- Section: Dados da Unidade --
                  _buildSectionCard(
                    icon: Icons.church_outlined,
                    title: 'Dados da Unidade',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('NOME'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            hint: 'Nome da congregação',
                          ),
                          style: GoogleFonts.inter(fontSize: 14),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o nome da congregação'
                              : null,
                        ),
                        // The "TIPO" read-only "Filial" field was removed:
                        // the backend hardcodes `isHeadquarters: false`
                        // on create (sede is only created during signup),
                        // so the field was misleading the user into
                        // thinking it was editable.
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // -- Section: Localização --
                  _buildSectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Localização',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('PAÍS'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _countryController,
                          decoration: _inputDecoration(hint: 'Brasil'),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('ESTADO'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _stateController,
                                    decoration:
                                        _inputDecoration(hint: 'Estado'),
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
                                  _buildLabel('CIDADE'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cityController,
                                    decoration:
                                        _inputDecoration(hint: 'Cidade'),
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('BAIRRO'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _neighborhoodController,
                          decoration: _inputDecoration(hint: 'Bairro'),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('RUA'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _streetController,
                                    decoration:
                                        _inputDecoration(hint: 'Rua'),
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
                                  _buildLabel('NÚMERO'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _numberController,
                                    decoration:
                                        _inputDecoration(hint: 'Nº'),
                                    style: GoogleFonts.inter(fontSize: 14),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- Buttons --
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF37628A),
                            side: const BorderSide(color: Color(0xFF37628A)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF37628A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Salvar Unidade',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
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
}
