import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Success-state color for the system status indicator at the bottom
/// of the drawer. Kept as a local constant (not yet a brand token)
/// because it's the only place in the app that needs a "success green"
/// right now.
const Color _kStatusHealthyGreen = Color(0xFF22C55E);

class AppDrawer extends StatelessWidget {
  final String churchName;
  final void Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.churchName,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppTheme.radiusXl),
          bottomRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Icon(
                      Icons.church,
                      color: AppTheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          churchName,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          'Gestão Eclesiástica',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  const _SectionLabel(text: 'Módulos'),
                  _DrawerItem(
                    icon: Icons.edit_note,
                    label: 'Secretaria',
                    onTap: () => _navigate(context, 'secretaria'),
                  ),
                  _DrawerItem(
                    icon: Icons.payments,
                    label: 'Finanças',
                    onTap: () => _navigate(context, 'financas'),
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance,
                    label: 'Patrimônio',
                    onTap: () => _navigate(context, 'patrimonio'),
                  ),
                  _DrawerItem(
                    icon: Icons.church,
                    label: 'Congregações',
                    onTap: () => _navigate(context, 'congregacoes'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(
                      height: 1,
                      color: AppTheme.surfaceContainerHigh,
                    ),
                  ),
                  const _SectionLabel(text: 'Ferramentas'),
                  _DrawerItem(
                    icon: Icons.analytics,
                    label: 'Relatórios',
                    onTap: () => _navigate(context, 'relatorios'),
                  ),
                  _DrawerItem(
                    icon: Icons.verified,
                    label: 'Certificados',
                    onTap: () => _navigate(context, 'certificados'),
                  ),
                  _DrawerItem(
                    icon: Icons.volunteer_activism,
                    label: 'Contribuições',
                    onTap: () => _navigate(context, 'contribuicoes'),
                  ),
                  _DrawerItem(
                    icon: Icons.groups,
                    label: 'Célula',
                    onTap: () => _navigate(context, 'celula'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status do Sistema',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Todos os serviços operacionais',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TODO(backend): replace the always-green dot with a
                    // real healthcheck once `/healthz` or similar exists.
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _kStatusHealthyGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    onNavigate(route);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.onSurfaceVariant, size: 24),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
