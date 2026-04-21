import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/church_option.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Two-step login's second screen: the user picks which membership to
/// operate as when their account belongs to more than one church.
///
/// Layout was redesigned to match the new "Escolha sua comunidade" mock
/// (2026-04-11): eyebrow label + headline + list of church cards + a
/// hardcoded daily-reflection card at the bottom.
class ChurchSelectionPage extends StatelessWidget {
  const ChurchSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (_) => context.go('/home'),
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
            churchSelection: (selectionToken, churches) =>
                _ChurchSelectionBody(churches: churches),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _ChurchSelectionBody extends StatelessWidget {
  const _ChurchSelectionBody({required this.churches});

  final List<ChurchOption> churches;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 20),
                for (final church in churches) ...[
                  _ChurchCard(
                    church: church,
                    onTap: () =>
                        context.read<AuthCubit>().selectChurch(church.id),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                const DailyReflectionCard(
                  verse:
                      'Pois onde estiverem dois ou três reunidos em meu nome, ali eu estarei.',
                  reference: 'Mateus 18:20',
                  authorName: 'Pr. Ricardo Santos',
                  authorRole: 'Ministério de Ensino',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BEM-VINDO DE VOLTA',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha sua comunidade',
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Church card ───────────────────────────────────────────────────────────

class _ChurchCard extends StatelessWidget {
  const _ChurchCard({required this.church, required this.onTap});

  final ChurchOption church;
  final VoidCallback onTap;

  /// Maps the backend Role enum to a friendly PT-BR label used under
  /// each church name. The set mirrors prisma/schema.prisma's `enum Role`.
  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'SECRETARY':
        return 'Secretário';
      case 'MEMBER':
        return 'Membro';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Same icon for every card — explicit product decision
              // (keeps the card row visually consistent regardless of role).
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.church_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _roleLabel(church.role),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily reflection card ─────────────────────────────────────────────────

/// Renders the "REFLEXÃO DO DIA" card shown at the bottom of the church
/// selection screen.
///
/// Content is fully passed in via the constructor so the call site in
/// [ChurchSelectionPage] is the single place that decides what is
/// displayed — today it's hardcoded placeholder text, but once a backend
/// endpoint exists (for example `GET /reflections/today`) the call site
/// can feed it live data without touching this widget.
///
// TODO(backend): wire [verse], [reference], [authorName] and [authorRole]
// to a real `/reflections/today` endpoint when it exists. Today the call
// site hardcodes placeholder values that match the design mock.
class DailyReflectionCard extends StatelessWidget {
  const DailyReflectionCard({
    super.key,
    required this.verse,
    required this.reference,
    required this.authorName,
    required this.authorRole,
  });

  final String verse;
  final String reference;
  final String authorName;
  final String authorRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFLEXÃO DO DIA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$verse"',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppTheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— $reference',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.surfaceContainerLow),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.secondaryContainer,
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authorRole,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
