import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/coming_soon_page.dart';
import '../../domain/models/membership.dart';
import '../cubit/members_cubit.dart';
import '../cubit/members_state.dart';

/// Secretaria page -- tabbed layout with Membros, Visitantes, EBD.
class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secretaria',
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
                  'Gerencie membros e voluntarios',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF596065),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          TabBar(
            labelColor: const Color(0xFF37628A),
            unselectedLabelColor: const Color(0xFF747C81),
            indicatorColor: const Color(0xFF37628A),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Membros'),
              Tab(text: 'Visitantes'),
              Tab(text: 'EBD'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _MembrosTab(),
                const ComingSoonPage(title: 'Visitantes'),
                const ComingSoonPage(title: 'EBD'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembrosTab extends StatelessWidget {
  const _MembrosTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<MembersCubit, MembersState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF37628A)),
              ),
              loaded: (members, total, page, searchQuery) {
                // Server-side search now — the API applies the `q` filter
                // at the database level, so `members` already arrives
                // filtered. Keep using `members` directly.
                final filtered = members;
                return Column(
                  children: [
                    // -- Search bar --
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: TextField(
                        onChanged: (value) {
                          context.read<MembersCubit>().search(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome ou cargo...',
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Color(0xFF747C81),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isNotEmpty
                                        ? 'Nenhum resultado encontrado'
                                        : 'Nenhum membro cadastrado',
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
                                final m = filtered[index];
                                return _MemberTile(member: m);
                              },
                            ),
                    ),
                  ],
                );
              },
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
                    Text(msg,
                        style: GoogleFonts.inter(
                            color: const Color(0xFFA83836))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MembersCubit>().loadMembers(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 100,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF37628A),
            foregroundColor: Colors.white,
            // `MembersCubit` is @injectable (factory), so the scoped cubit
            // inside /create-member is a different instance. Its internal
            // loadMembers() call doesn't reach the list cubit here — we
            // reload manually on return from the push.
            onPressed: () async {
              await context.push('/create-member');
              if (context.mounted) {
                context.read<MembersCubit>().loadMembers();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Membership member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = member.user.name.isNotEmpty
        ? member.user.name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          await context.push('/edit-member/${member.userId}');
          if (context.mounted) {
            context.read<MembersCubit>().loadMembers();
          }
        },
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFCDE6F4),
              child: Text(
                initials,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF37628A),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.user.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3338),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _roleLabel(member.role),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF596065),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFABB3B9)),
          ],
        ),
      ),),
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'ADMIN':
      return 'Administrador';
    case 'SECRETARY':
      return 'Secret\u00e1rio';
    default:
      return 'Membro';
  }
}
