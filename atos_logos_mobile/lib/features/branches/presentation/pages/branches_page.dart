import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/branch.dart';
import '../cubit/branches_cubit.dart';
import '../cubit/branches_state.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  @override
  void initState() {
    super.initState();
    context.read<BranchesCubit>().loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    // AuthenticatedShell already provides the Scaffold (chrome + body).
    // This page returns its content + a Positioned FAB so there is no
    // nested-Scaffold oddity (drawer / bottomNav / FAB anchor all live
    // on the outer Scaffold).
    //
    // NO SafeArea at the root: the shell's AppBar already carves out the
    // status bar, and adding a SafeArea here would push `bottom: 100`
    // up by the system home-indicator inset — mismatched with the FAB
    // on the MembersPage (Secretaria), which lives at the same
    // bottom: 100 inside a Stack with no SafeArea.
    return Container(
      color: const Color(0xFFF7F9FC),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Header --
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Congregações',
                      style: GoogleFonts.manrope(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C3338),
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie as unidades da sua igreja',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF596065),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // -- Content --
              Expanded(
                child: BlocBuilder<BranchesCubit, BranchesState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF37628A),
                        ),
                      ),
                      loaded: (branches, searchQuery) =>
                          _buildLoadedContent(branches, searchQuery),
                      error: (msg) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFFA83836),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              msg,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFA83836),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<BranchesCubit>()
                                  .loadBranches(),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Positioned FAB — the outer shell's Scaffold bottom nav is
          // transparent / has its own backdrop, so a Positioned FAB
          // here plays well with extendBody: true.
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF37628A),
              foregroundColor: Colors.white,
              onPressed: () async {
                // The /create-branch route owns its own BranchesCubit
                // (scoped via @injectable), so a successful create does
                // NOT reach the cubit backing this list. Await the push
                // and re-fetch here so the newly-created branch shows
                // up without a manual refresh.
                await context.push('/create-branch');
                if (!context.mounted) return;
                context.read<BranchesCubit>().loadBranches();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(List<Branch> branches, String searchQuery) {
    // Server-side search — backend already filtered by `q`.
    final filtered = branches;

    return Column(
      children: [
        // -- Search bar --
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            onChanged: (value) =>
                context.read<BranchesCubit>().search(value),
            decoration: InputDecoration(
              hintText: 'Buscar congregação...',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF747C81),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF747C81),
              ),
              filled: true,
              fillColor: const Color(0xFFE3E9EE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        // -- Branch list --
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.church_outlined,
                        size: 64,
                        color: Color(0xFF747C81),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Nenhum resultado encontrado'
                            : 'Nenhuma congregação cadastrada',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF596065),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 80,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final branch = filtered[index];
                    return _BranchCard(
                      branch: branch,
                      onTap: () async {
                        // Same pattern as the FAB: await the edit route
                        // so the list reloads on return (edits/deletes
                        // there happen against a SCOPED cubit, so the
                        // parent list doesn't get the update otherwise).
                        await context.push('/edit-branch/${branch.id}');
                        if (!context.mounted) return;
                        context.read<BranchesCubit>().loadBranches();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final VoidCallback onTap;
  const _BranchCard({required this.branch, required this.onTap});

  String _buildAddress() {
    final parts = <String>[
      if (branch.street != null && branch.street!.isNotEmpty) branch.street!,
      if (branch.number != null && branch.number!.isNotEmpty) branch.number!,
      if (branch.neighborhood != null && branch.neighborhood!.isNotEmpty)
        branch.neighborhood!,
      if (branch.city != null && branch.city!.isNotEmpty) branch.city!,
      if (branch.state != null && branch.state!.isNotEmpty) branch.state!,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final address = _buildAddress();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 8,
              color: Color(0x0F2C3338),
            ),
          ],
        ),
        child: Row(
          children: [
            // -- Icon --
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFCDE6F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                branch.isHeadquarters ? Icons.church : Icons.location_on,
                color: const Color(0xFF37628A),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // -- Info --
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          branch.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3338),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (branch.isHeadquarters) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF37628A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sede',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF596065),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Tile itself is tappable (opens /edit-branch/:id); the
            // former "Ver Detalhes" TextButton is redundant now.
          ],
        ),
        ),
      ),
    );
  }
}
