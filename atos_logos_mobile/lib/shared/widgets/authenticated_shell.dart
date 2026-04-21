import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/cubit/home_state.dart';
import 'app_bar_widget.dart';
import 'app_drawer.dart';
import 'custom_bottom_nav.dart';
import 'profile_bottom_sheet.dart';

/// Shared chrome for every authenticated screen.
///
/// Wraps [child] with [AtosAppBar], [AppDrawer] and [CustomBottomNav] so that
/// inner routes (secretaria, create-member, branches, etc.) have the same
/// hamburger menu, bottom tabs and profile avatar as the home dashboard.
///
/// Screens that need to drive the bottom nav locally (like the home dashboard
/// that switches between Início/Agenda/Notificações via IndexedStack) can pass
/// [selectedBottomNavIndex] and [onBottomNavTap]. Inner routes leave both
/// unset: the shell highlights index 0 and taps default to `context.go('/home')`,
/// effectively treating the bottom nav as a "back to home" shortcut.
class AuthenticatedShell extends StatefulWidget {
  final Widget child;
  final int selectedBottomNavIndex;
  final ValueChanged<int>? onBottomNavTap;

  const AuthenticatedShell({
    super.key,
    required this.child,
    this.selectedBottomNavIndex = 0,
    this.onBottomNavTap,
  });

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Hydrate shell data. This runs once per shell mount (not once per inner
    // route) because the shell is the outermost widget for authenticated
    // screens. Deep links into /secretaria etc. therefore still populate the
    // drawer church name and the profile avatar.
    context.read<HomeCubit>().loadDashboard();
    context.read<AuthCubit>().fetchProfile();
  }

  void _onDrawerNavigate(String route) {
    switch (route) {
      case 'secretaria':
        context.push('/secretaria');
      case 'congregacoes':
        context.push('/branches');
      default:
        context.push('/coming-soon');
    }
  }

  /// Opens the profile bottom sheet. Falls back to "—" when the profile has
  /// not resolved yet so the sheet never surfaces a fake "Membro"/"MEMBER".
  void _showProfileSheet(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String userName = '—';
    String userRole = '—';

    authState.whenOrNull(
      authenticated: (profile) {
        if (profile != null) {
          userName = profile.user.name;
          userRole = profile.membership.role;
        }
      },
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProfileBottomSheet(
        userName: userName,
        userRole: userRole,
        onMyProfile: () {
          Navigator.of(context).pop();
          context.push('/edit-profile');
        },
        onSettings: () {
          Navigator.of(context).pop();
          context.push('/coming-soon');
        },
        onLogout: () async {
          Navigator.of(context).pop();
          await context.read<AuthCubit>().logout();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }

  void _defaultBottomNavTap(int index) {
    // No-override screens route every bottom-nav tap through /home, and
    // carry the tapped tab as a query param so HomePage opens the right
    // IndexedStack child. Prevents the "tap Agenda from /secretaria →
    // land on Início" bug.
    context.go('/home?tab=$index');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final userInitial = authState.maybeWhen(
          authenticated: (profile) {
            final name = profile?.user.name ?? '';
            return name.isNotEmpty ? name[0].toUpperCase() : null;
          },
          orElse: () => null,
        );

        return BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            final churchName = homeState.maybeWhen(
              loaded: (church, _, events) => church.name,
              orElse: () => 'Igreja',
            );

            return Scaffold(
              key: _scaffoldKey,
              extendBody: true,
              drawer: AppDrawer(
                churchName: churchName,
                onNavigate: _onDrawerNavigate,
              ),
              appBar: AtosAppBar(
                userInitial: userInitial,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                onAvatarPressed: () => _showProfileSheet(context),
              ),
              body: widget.child,
              bottomNavigationBar: CustomBottomNav(
                currentIndex: widget.selectedBottomNavIndex,
                onTap: widget.onBottomNavTap ?? _defaultBottomNavTap,
              ),
            );
          },
        );
      },
    );
  }
}
