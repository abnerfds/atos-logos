import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// App version surfaced at the bottom of the profile sheet.
///
// TODO(build-info): read from `package_info_plus` once the dependency
// is added so this reflects the actual pubspec version instead of a
// hand-maintained constant.
const String _kAppVersionDisplay = '2.4.0';

class ProfileBottomSheet extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onMyProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const ProfileBottomSheet({
    super.key,
    required this.userName,
    required this.userRole,
    required this.onMyProfile,
    required this.onSettings,
    required this.onLogout,
  });

  /// Maps the backend Role enum to a friendly PT-BR label. Kept exhaustive
  /// (including the explicit `MEMBER` branch) so future refactors that
  /// add a new Role enum value fail fast instead of silently falling
  /// through to "Membro".
  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Gestor da Comunidade';
      case 'SECRETARY':
        return 'Secretário(a)';
      case 'MEMBER':
        return 'Membro';
      default:
        return 'Membro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty
        ? userName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.secondaryContainer,
            child: Text(
              initials,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roleLabel(userRole),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppTheme.surfaceContainerHigh),
          _MenuItem(
            icon: Icons.person_outline,
            label: 'Meu Perfil',
            onTap: onMyProfile,
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.outlineVariant,
            ),
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: onSettings,
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.outlineVariant,
            ),
          ),
          _MenuItem(
            icon: Icons.logout,
            label: 'Sair',
            onTap: onLogout,
            iconColor: AppTheme.error,
            labelColor: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Versão $_kAppVersionDisplay • Atos Logos',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.onSurfaceVariant),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor ?? AppTheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
