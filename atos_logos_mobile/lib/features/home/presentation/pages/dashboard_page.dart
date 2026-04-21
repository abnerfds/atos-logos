import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/models/birthday_member.dart';
import '../../domain/models/upcoming_event.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/flip_card.dart';

/// Dashboard tab — greeting, member flip card, birthdays carousel, and
/// upcoming events list. Consumes [HomeCubit] for dashboard data and
/// [AuthCubit] for the logged-in user profile.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (msg) => _ErrorRetry(message: msg),
          loaded: (church, birthdays, upcomingEvents) =>
              _LoadedBody(birthdays: birthdays, events: upcomingEvents),
        );
      },
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: AppTheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().loadDashboard(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

// ── Loaded body ────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.birthdays, required this.events});

  final List<BirthdayMember> birthdays;
  final List<UpcomingEvent> events;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        UserProfile? profile;
        authState.whenOrNull(authenticated: (p) => profile = p);

        final rawName = profile?.user.name ?? '';
        final firstName = rawName.split(' ').first;
        // The greeting intentionally drops the name when we don't have a
        // real one yet (authenticated-no-profile window, or backend returned
        // an empty string). Never surface a fake "Membro" literal.
        final greeting = firstName.isNotEmpty ? 'Olá, $firstName' : 'Olá';
        // The card front still needs a non-null userName for the avatar
        // letter; empty is handled there with a "?" fallback.
        final userName = rawName;
        final positionName = profile?.positions.isNotEmpty == true
            ? profile!.positions.first.name
            : null;

        return Container(
          color: AppTheme.surface,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // -- Greeting --
              Text(
                greeting,
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Que bom ter você aqui hoje.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // -- Flip card (member ID) --
              Semantics(
                label: 'Carteira digital do membro — toque para girar',
                button: true,
                container: true,
                child: FlipCard(
                  front: _MemberCardFront(
                    userName: userName,
                    positionName: positionName,
                    registrationNumber: profile?.profile?.registrationNumber,
                  ),
                  back: _MemberCardBack(
                    birthDate: _formatDate(profile?.profile?.birthDate),
                    baptismDate: _formatDate(profile?.profile?.baptismDate),
                    admissionDate: _formatDate(profile?.profile?.admissionDate),
                    status: profile?.membership.status ?? 'ACTIVE',
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // -- Birthdays section (only if any) --
              if (birthdays.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Aniversariantes do Mês',
                  trailing: Text(
                    'Ver todos',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: birthdays.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => _BirthdayAvatar(
                      member: birthdays[index],
                      isFirst: index == 0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // -- Upcoming events section --
              _SectionHeader(
                title: 'Próximos Eventos',
                trailing: const Icon(
                  Icons.filter_list,
                  size: 20,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (events.isEmpty)
                const _EmptyEventsCard()
              else
                ...events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventCard(event: event),
                  ),
                ),

              const SizedBox(height: 80), // bottom nav breathing room
            ],
          ),
        );
      },
    );
  }
}

// ── Section header helper ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        trailing,
      ],
    );
  }
}

// ── Date formatting ───────────────────────────────────────────────────────

/// Converts a backend ISO date string (e.g. `"2020-03-15"` or
/// `"2020-03-15T00:00:00.000Z"`) into the Brazilian `dd/MM/yyyy`
/// representation used in the card back. Returns `"—"` when the input
/// is null, empty or unparseable.
String _formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '—';
  try {
    final trimmed = isoDate.length >= 10 ? isoDate.substring(0, 10) : isoDate;
    final parts = trimmed.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  } catch (_) {
    return isoDate;
  }
}

// ── Member card front ─────────────────────────────────────────────────────

class _MemberCardFront extends StatelessWidget {
  const _MemberCardFront({
    required this.userName,
    required this.positionName,
    required this.registrationNumber,
  });

  final String userName;
  final String? positionName;
  final String? registrationNumber;

  /// Placeholder shown when the user has no MemberProfile row yet, so
  /// the card keeps its visual layout without displaying a fake
  /// identification number.
  static const String _kRegistrationPlaceholder = '—';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDim],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 24,
            color: Color(0x3337628A), // primary @ 20% (see AppTheme.buttonShadow)
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -64,
            right: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (positionName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  positionName!.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                    color:
                                        Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ghost "Atos Logos" text + real registration number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Atos Logos',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      Text(
                        registrationNumber ?? _kRegistrationPlaceholder,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          letterSpacing: 2.0,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sync,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Toque para girar',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'CARTEIRA DIGITAL',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Member card back ──────────────────────────────────────────────────────

class _MemberCardBack extends StatelessWidget {
  const _MemberCardBack({
    required this.birthDate,
    required this.baptismDate,
    required this.admissionDate,
    required this.status,
  });

  final String birthDate;
  final String baptismDate;
  final String admissionDate;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.onSurface, Color(0xFF0B0F11)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 24,
            color: Color(0x3337628A),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -64,
            left: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informações de Registro',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BackField(label: 'NASCIMENTO', value: birthDate),
                          const SizedBox(height: 12),
                          _BackField(label: 'ADMISSÃO', value: admissionDate),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BackField(label: 'BATISMO', value: baptismDate),
                          const SizedBox(height: 12),
                          _BackField(
                            label: 'STATUS',
                            value: status,
                            isStatus: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sync,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Toque para voltar',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Atos Logos',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackField extends StatelessWidget {
  const _BackField({
    required this.label,
    required this.value,
    this.isStatus = false,
  });

  final String label;
  final String value;
  final bool isStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isStatus ? FontWeight.w700 : FontWeight.w500,
            color: isStatus ? AppTheme.primary : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Birthday avatar ───────────────────────────────────────────────────────

class _BirthdayAvatar extends StatelessWidget {
  const _BirthdayAvatar({required this.member, required this.isFirst});

  final BirthdayMember member;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(member.birthDate);
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
        : '--';

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isFirst
                  ? const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppTheme.primary,
                        AppTheme.primaryContainer,
                      ],
                    )
                  : null,
              border: !isFirst
                  ? Border.all(
                      color: AppTheme.surfaceContainerHighest,
                      width: 2,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainer,
                border: Border.all(color: AppTheme.surface, width: 4),
              ),
              child: Center(
                child: Text(
                  member.name.isNotEmpty
                      ? member.name[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name.split(' ').first,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────

/// Localized weekday abbreviations used on the date box of an event card.
/// `DateTime.weekday` returns 1-7 starting on Monday, which matches this
/// array so we can index it directly.
const List<String> _kWeekdayAbbrPtBR = [
  'SEG',
  'TER',
  'QUA',
  'QUI',
  'SEX',
  'SÁB',
  'DOM',
];

/// Badge taxonomy colors for the event type chip. Kept inline because
/// they are category colors (not brand tokens) and are specific to the
/// dashboard card. If/when we get more event types this moves into a
/// dedicated theme extension.
const Color _kEventBadgeBackground = Color(0xFFD8CAFC);
const Color _kEventBadgeForeground = Color(0xFF4B416A);

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    final day = event.startsAt.day.toString().padLeft(2, '0');
    final dayAbbr = _kWeekdayAbbrPtBR[(event.startsAt.weekday - 1) % 7];
    final hh = event.startsAt.hour.toString().padLeft(2, '0');
    final mm = event.startsAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final location = event.branchName ?? 'Local a definir';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.surfaceContainerLow),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x0F2C3338), // onSurface @ 6% (AppTheme.cardShadow)
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayAbbr,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  day,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$time • $location',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kEventBadgeBackground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Evento',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kEventBadgeForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty events card ─────────────────────────────────────────────────────

class _EmptyEventsCard extends StatelessWidget {
  const _EmptyEventsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
          const Icon(
            Icons.event_busy_outlined,
            size: 32,
            color: AppTheme.outline,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Nenhum evento cadastrado',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
