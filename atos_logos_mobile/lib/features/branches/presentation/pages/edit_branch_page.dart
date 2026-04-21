import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/models/branch.dart';
import '../cubit/branches_cubit.dart';
import '../cubit/branches_state.dart';

/// Secretariat "edit branch" form. Reuses the [BranchesCubit] from the
/// list so a successful save/delete refreshes the list automatically.
///
/// Pre-fills every field from the loaded branch (looked up by id on the
/// cubit's current state). Deleting is guarded server-side by the
/// "cannot delete HQ" rule — the backend's 403 message is surfaced to
/// the user via SnackBar.
class EditBranchPage extends StatefulWidget {
  final String branchId;

  const EditBranchPage({super.key, required this.branchId});

  @override
  State<EditBranchPage> createState() => _EditBranchPageState();
}

class _EditBranchPageState extends State<EditBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();

  bool _controllersPopulated = false;
  bool _saving = false;
  bool _deleting = false;
  bool _promoting = false;

  @override
  void initState() {
    super.initState();
    // Scoped cubit — load the list so we can find the branch by id.
    context.read<BranchesCubit>().loadBranches();
  }

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

  /// One-shot fill so edits by the user aren't clobbered on every
  /// BlocBuilder rebuild.
  void _populateControllersOnce(Branch branch) {
    if (_controllersPopulated) return;
    _nameController.text = branch.name;
    _countryController.text = branch.country ?? '';
    _stateController.text = branch.state ?? '';
    _cityController.text = branch.city ?? '';
    _neighborhoodController.text = branch.neighborhood ?? '';
    _streetController.text = branch.street ?? '';
    _numberController.text = branch.number ?? '';
    _controllersPopulated = true;
  }

  Future<void> _onSave() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await context.read<BranchesCubit>().updateBranch(
            id: widget.branchId,
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            state: _stateController.text.trim(),
            city: _cityController.text.trim(),
            neighborhood: _neighborhoodController.text.trim(),
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congregação atualizada.')),
      );
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao salvar.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDeleteConfirmed() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await context.read<BranchesCubit>().deleteBranch(widget.branchId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congregação removida.')),
      );
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      // Typically the Last-HQ guard (`Cannot delete the headquarters branch`)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao remover.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _onPromoteConfirmed() async {
    if (_promoting) return;
    setState(() => _promoting = true);
    try {
      await context
          .read<BranchesCubit>()
          .promoteToHeadquarters(widget.branchId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congregação promovida a Sede.')),
      );
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao promover.')),
      );
    } finally {
      if (mounted) setState(() => _promoting = false);
    }
  }

  void _showPromoteDialog(String branchName) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Tornar Sede?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3338),
          ),
        ),
        content: Text(
          'Ao tornar "$branchName" a Sede, a Sede atual será '
          'automaticamente rebaixada para Filial. Somente uma Sede '
          'pode existir por igreja.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF596065),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF37628A),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _onPromoteConfirmed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF37628A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Tornar Sede',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String branchName) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Remover Congregação?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3338),
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover "$branchName"? '
          'Essa ação é permanente.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF596065),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF37628A),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _onDeleteConfirmed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA83836),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Remover',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        child: BlocBuilder<BranchesCubit, BranchesState>(
          builder: (context, state) {
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
              loaded: (branches, _) {
                final branch = branches.where(
                  (b) => b.id == widget.branchId,
                ).toList();
                if (branch.isEmpty) {
                  return Center(
                    child: Text(
                      'Congregação não encontrada.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF596065),
                      ),
                    ),
                  );
                }
                _populateControllersOnce(branch.first);
                return _buildForm(branch.first);
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(Branch branch) {
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
            // -- Title --
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
                    child: Icon(
                      branch.isHeadquarters
                          ? Icons.church
                          : Icons.location_on,
                      color: const Color(0xFF37628A),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Editar Congregação',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3338),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.isHeadquarters
                        ? 'Sede — não pode ser removida'
                        : 'Atualize os dados da unidade',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF596065),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // -- Sections (reuse of the same structure as CreateBranchPage) --
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
                    decoration:
                        _inputDecoration(hint: 'Nome da congregação'),
                    style: GoogleFonts.inter(fontSize: 14),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome da congregação'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                              decoration: _inputDecoration(hint: 'Estado'),
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
                              decoration: _inputDecoration(hint: 'Cidade'),
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
                              decoration: _inputDecoration(hint: 'Rua'),
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
                              decoration: _inputDecoration(hint: 'Nº'),
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
            const SizedBox(height: 16),
            // -- Promote to HQ (only for non-HQ branches) --
            if (!branch.isHeadquarters)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3338),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Esta é uma Filial. Apenas uma Sede pode existir '
                      'por igreja — promover esta congregação irá '
                      'rebaixar automaticamente a Sede atual.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF596065),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _promoting
                            ? null
                            : () => _showPromoteDialog(branch.name),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF37628A),
                          side: const BorderSide(color: Color(0xFF37628A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Tornar esta a Sede',
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
            if (!branch.isHeadquarters) const SizedBox(height: 16),
            // -- Danger zone (omitted for headquarters) --
            if (!branch.isHeadquarters)
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
                        onPressed: _deleting
                            ? null
                            : () => _showDeleteDialog(branch.name),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFA83836),
                          side:
                              const BorderSide(color: Color(0xFFA83836)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Remover Congregação',
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
            // -- Save button --
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
                  'Salvar Alterações',
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
