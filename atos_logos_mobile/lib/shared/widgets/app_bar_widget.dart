import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// App-wide top bar used by the home shell.
///
/// Semi-transparent background + backdrop blur, 64px fixed height,
/// hamburger menu on the left, brand title, and a circular avatar button
/// on the right. All colors are sourced from [AppTheme] so a single
/// token change rebrands the chrome without touching this file.
class AtosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userInitial;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;

  const AtosAppBar({
    super.key,
    this.userInitial,
    this.onMenuPressed,
    this.onAvatarPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: MediaQuery.of(context).padding.top + 64,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.7),
          ),
          child: Row(
            children: [
              // Menu icon
              Semantics(
                label: 'Abrir menu',
                button: true,
                child: GestureDetector(
                  onTap: onMenuPressed ?? () {},
                  child: const Icon(
                    Icons.menu,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Brand
              Text(
                'Atos Logos',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: -1.0,
                ),
              ),
              const Spacer(),
              // Profile avatar
              Semantics(
                label: 'Abrir menu de perfil',
                button: true,
                child: GestureDetector(
                  onTap: onAvatarPressed,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceContainerHigh,
                      border: Border.all(
                        color: AppTheme.primaryContainer,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userInitial ?? '?',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
