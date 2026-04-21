import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../members/domain/models/member_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key, required this.profileId});

  final String profileId;

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadMemberProfile(widget.profileId);
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
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF37628A)),
            ),
            saving: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF37628A)),
            ),
            saved: () => const SizedBox.shrink(),
            error: (message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFA83836),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            loaded: (profile) => _ProfileContent(profile: profile),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final name = user?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // -- Avatar --
        Center(
          child: Container(
            width: 128,
            height: 128,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF37628A),
                  Color(0xFFA6D0FE),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9EEF3),
                border: Border.all(
                  color: const Color(0xFFF7F9FC),
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF37628A),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // -- Name --
        Center(
          child: Text(
            name,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2C3338),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        // -- Edit button --
        Center(
          child: SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37628A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Editar Perfil',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // -- Stat cards --
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Batismo',
                value: _formatDate(profile.baptismDate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Membro desde',
                value: _formatDate(profile.admissionDate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // -- Dados Pessoais --
        Text(
          'Dados Pessoais',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3338),
          ),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Telefone',
          value: user?.phone ?? '--',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'E-mail',
          value: user?.email ?? '--',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Endereço',
          value: _formatAddress(user),
        ),
        const SizedBox(height: 32),

        // -- Ações da Secretaria --
        Text(
          'Ações da Secretaria',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3338),
          ),
        ),
        const SizedBox(height: 16),
        _ActionCard(
          icon: Icons.mail_outline,
          title: 'Carta de Recomendação',
          subtitle: 'Gerar carta de recomendação',
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.school_outlined,
          title: 'Certificado EBD',
          subtitle: 'Gerar certificado da EBD',
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  static String _formatAddress(MemberProfileUser? user) {
    if (user == null) return '--';
    final parts = <String>[
      if (user.street != null && user.street!.isNotEmpty) user.street!,
      if (user.number != null && user.number!.isNotEmpty) user.number!,
      if (user.neighborhood != null && user.neighborhood!.isNotEmpty)
        user.neighborhood!,
      if (user.city != null && user.city!.isNotEmpty) user.city!,
      if (user.state != null && user.state!.isNotEmpty) user.state!,
    ];
    return parts.isEmpty ? '--' : parts.join(', ');
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF596065),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3338),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE3E9EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF37628A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF596065),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2C3338),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF635983)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3338),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF596065),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF596065),
            size: 20,
          ),
        ],
      ),
    );
  }
}
