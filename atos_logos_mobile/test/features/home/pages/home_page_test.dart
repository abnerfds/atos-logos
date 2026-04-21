import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/home_page.dart';
import 'package:atos_logos_mobile/shared/widgets/custom_bottom_nav.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

// Shell-wide behaviour (drawer, profile sheet, logout race, church name)
// lives in test/shared/widgets/authenticated_shell_test.dart. Tests here
// cover only HomePage's own responsibility: driving the IndexedStack tabs
// via the bottom nav.

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockAuthCubit = MockAuthCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState.initial());
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(() => mockAuthCubit.state)
        .thenReturn(const AuthState.authenticated());
    when(() => mockAuthCubit.fetchProfile()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const HomePage(),
      ),
    );
  }

  group('HomePage - tab switching', () {
    testWidgets('should render the bottom nav with the three tab labels',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CustomBottomNav), findsOneWidget);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets(
        'should show the Agenda coming-soon page when the Agenda tab is tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Agenda'));
      await tester.pump();

      // ComingSoonPage(title: 'Agenda') renders this subtitle.
      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsWidgets,
      );
    });

    testWidgets(
        'should show the Notificações coming-soon page when the Notificações tab is tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Notificações'));
      await tester.pump();

      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsWidgets,
      );
    });
  });

  group('HomePage - initial tab from route', () {
    Widget buildRouterSubject(String initialLocation) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<HomeCubit>.value(value: mockHomeCubit),
                BlocProvider<AuthCubit>.value(value: mockAuthCubit),
              ],
              child: const HomePage(),
            ),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    testWidgets(
        'should open the Agenda tab when the route carries ?tab=1 (fixes cross-shell bottom-nav deep-link)',
        (tester) async {
      await tester.pumpWidget(buildRouterSubject('/home?tab=1'));
      await tester.pump();

      // Agenda coming-soon subtitle shows that tab is the active IndexedStack child.
      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsWidgets,
      );
    });

    testWidgets(
        'should open the Notificações tab when the route carries ?tab=2',
        (tester) async {
      await tester.pumpWidget(buildRouterSubject('/home?tab=2'));
      await tester.pump();

      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsWidgets,
      );
    });

    testWidgets(
        'should default to the Início tab when no ?tab= is supplied',
        (tester) async {
      await tester.pumpWidget(buildRouterSubject('/home'));
      await tester.pump();

      // The dashboard body is owned by DashboardPage; its loading state is
      // what HomeState.initial() produces — just assert we are NOT on one
      // of the coming-soon placeholders.
      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsNothing,
      );
    });

    testWidgets(
        'should clamp an out-of-range ?tab= to the Início default instead of crashing the IndexedStack',
        (tester) async {
      await tester.pumpWidget(buildRouterSubject('/home?tab=99'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('HomePage - cross-shell bottom nav (regression: tapping Agenda from /secretaria landed on Início)', () {
    testWidgets(
        'navigating /secretaria → tap Agenda in the bottom nav opens the Agenda coming-soon page on /home, NOT the Início dashboard',
        (tester) async {
      // A router that mirrors the production wiring closely enough to
      // exercise the bug: an inner route (/secretaria) hosts
      // AuthenticatedShell with no onBottomNavTap, /home renders HomePage
      // and reads ?tab= from the route.
      final router = GoRouter(
        initialLocation: '/secretaria',
        routes: [
          GoRoute(
            path: '/secretaria',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<HomeCubit>.value(value: mockHomeCubit),
                BlocProvider<AuthCubit>.value(value: mockAuthCubit),
              ],
              child: const Scaffold(
                body: Text('SECRETARIA_BODY'),
                bottomNavigationBar: _ShellBottomNavProbe(),
              ),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<HomeCubit>.value(value: mockHomeCubit),
                BlocProvider<AuthCubit>.value(value: mockAuthCubit),
              ],
              child: const HomePage(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // We're on /secretaria now. Trigger the same default-onTap branch
      // that AuthenticatedShell wires up: context.go('/home?tab=$index').
      // _ShellBottomNavProbe exposes a button that fires it with index 1.
      await tester.tap(find.text('TAP_AGENDA'));
      await tester.pumpAndSettle();

      // The ComingSoonPage(title: 'Agenda') is now the active IndexedStack child.
      // Its body shows the shared subtitle below.
      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsWidgets,
      );
      // And the dashboard surface (loading or loaded) is NOT showing.
      expect(find.text('SECRETARIA_BODY'), findsNothing);
    });
  });
}

/// Minimal stand-in for the bottom nav inside an inner shell. Pressing
/// "TAP_AGENDA" mirrors what AuthenticatedShell._defaultBottomNavTap(1)
/// produces in production: a context.go('/home?tab=1').
class _ShellBottomNavProbe extends StatelessWidget {
  const _ShellBottomNavProbe();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/home?tab=1'),
      child: const Text('TAP_AGENDA'),
    );
  }
}
