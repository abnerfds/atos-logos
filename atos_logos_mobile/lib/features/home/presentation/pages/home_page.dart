import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:atos_logos_mobile/shared/widgets/authenticated_shell.dart';
import 'package:atos_logos_mobile/shared/widgets/coming_soon_page.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/dashboard_page.dart';

/// Top-level authenticated screen. Renders its three tabs
/// (Dashboard, Agenda, Notificações) inside [AuthenticatedShell] so the
/// chrome (app bar, drawer, bottom nav) is the same one every other
/// authenticated screen uses.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tabCount = 3;
  int _currentIndex = 0;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Seed the tab from the route's ?tab= query on the first frame so
    // deep-links like /home?tab=1 open Agenda. Later in-page taps use
    // setState directly, so we only consume the param once per push.
    if (_seeded) return;
    _seeded = true;
    // GoRouterState.of throws when HomePage is hosted outside a GoRouter
    // (plain MaterialApp in tests, embedded previews). Treat absence as
    // "no tab hint — default to Início".
    String? raw;
    try {
      raw = GoRouterState.of(context).uri.queryParameters['tab'];
    } catch (_) {
      raw = null;
    }
    final parsed = int.tryParse(raw ?? '');
    if (parsed != null && parsed >= 0 && parsed < _tabCount) {
      _currentIndex = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedShell(
      selectedBottomNavIndex: _currentIndex,
      onBottomNavTap: (index) => setState(() => _currentIndex = index),
      child: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardPage(),
          ComingSoonPage(title: 'Agenda'),
          ComingSoonPage(title: 'Notificações'),
        ],
      ),
    );
  }
}
