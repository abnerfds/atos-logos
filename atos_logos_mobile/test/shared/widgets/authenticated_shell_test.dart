import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';
import 'package:atos_logos_mobile/shared/widgets/app_bar_widget.dart';
import 'package:atos_logos_mobile/shared/widgets/authenticated_shell.dart';
import 'package:atos_logos_mobile/shared/widgets/custom_bottom_nav.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockAuthCubit mockAuthCubit;

  const profile = UserProfile(
    user: UserProfileUser(id: 'u1', name: 'Ricardo', email: 'r@e.com'),
    membership: UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
    positions: [],
    church: UserProfileChurch(id: 'c1', name: 'Igreja'),
    branch: UserProfileBranch(id: 'b1', name: 'Sede'),
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockAuthCubit = MockAuthCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState.initial());
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(
      () => mockAuthCubit.state,
    ).thenReturn(const AuthState.authenticated(profile: profile));
    when(() => mockAuthCubit.fetchProfile()).thenAnswer((_) async {});
  });

  Widget buildSubject({
    Widget? child,
    int selectedBottomNavIndex = 0,
    ValueChanged<int>? onBottomNavTap,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: AuthenticatedShell(
          selectedBottomNavIndex: selectedBottomNavIndex,
          onBottomNavTap: onBottomNavTap,
          child: child ?? const Text('INNER'),
        ),
      ),
    );
  }

  /// Builds the shell inside a real GoRouter with placeholder destinations
  /// so navigation side-effects (drawer `context.push`, logout
  /// `context.go('/login')`, default bottom nav `context.go('/home')`)
  /// can be observed.
  Widget buildRoutedSubject({
    Widget? child,
    int selectedBottomNavIndex = 0,
    ValueChanged<int>? onBottomNavTap,
  }) {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<HomeCubit>.value(value: mockHomeCubit),
              BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            ],
            child: AuthenticatedShell(
              selectedBottomNavIndex: selectedBottomNavIndex,
              onBottomNavTap: onBottomNavTap,
              child: child ?? const Text('INNER'),
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME_ROUTE')),
        ),
        GoRoute(
          path: '/secretaria',
          builder: (context, state) =>
              const Scaffold(body: Text('SECRETARIA_ROUTE')),
        ),
        GoRoute(
          path: '/branches',
          builder: (context, state) =>
              const Scaffold(body: Text('BRANCHES_ROUTE')),
        ),
        GoRoute(
          path: '/ebd',
          builder: (context, state) => const Scaffold(body: Text('EBD_ROUTE')),
        ),
        GoRoute(
          path: '/coming-soon',
          builder: (context, state) =>
              const Scaffold(body: Text('COMING_SOON_ROUTE')),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) =>
              const Scaffold(body: Text('EDIT_PROFILE_ROUTE')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('LOGIN_ROUTE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('AuthenticatedShell - chrome', () {
    testWidgets(
      'should render AtosAppBar, hamburger menu icon and CustomBottomNav around the child',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byType(AtosAppBar), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byType(CustomBottomNav), findsOneWidget);
        // The provided child body is mounted inside the shell
        expect(find.text('INNER'), findsOneWidget);
      },
    );

    testWidgets(
      'should expose the authenticated user first-name initial on the avatar',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.text('R'), findsOneWidget);
      },
    );

    testWidgets(
      'should fall back to "?" on the avatar when AuthState has not resolved to authenticated yet (orElse branch)',
      (tester) async {
        when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());

        await tester.pumpWidget(buildSubject());

        expect(find.text('?'), findsOneWidget);
      },
    );

    testWidgets(
      'should fall back to "?" on the avatar when profile.user.name is empty (no RangeError)',
      (tester) async {
        const emptyNameProfile = UserProfile(
          user: UserProfileUser(id: 'u1', name: '', email: 'r@e.com'),
          membership: UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
          positions: [],
          church: UserProfileChurch(id: 'c1', name: 'Igreja'),
          branch: UserProfileBranch(id: 'b1', name: 'Sede'),
        );
        when(
          () => mockAuthCubit.state,
        ).thenReturn(const AuthState.authenticated(profile: emptyNameProfile));

        await tester.pumpWidget(buildSubject());

        expect(tester.takeException(), isNull);
        expect(find.text('?'), findsOneWidget);
      },
    );
  });

  group('AuthenticatedShell - lifecycle', () {
    testWidgets(
      'should trigger HomeCubit.loadDashboard and AuthCubit.fetchProfile on initState so deep-link entries still hydrate the shell data',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        verify(() => mockHomeCubit.loadDashboard()).called(1);
        verify(() => mockAuthCubit.fetchProfile()).called(1);
      },
    );
  });

  group('AuthenticatedShell - drawer', () {
    testWidgets('should open the drawer when the menu icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Gestão Eclesiástica'), findsOneWidget);
    });

    testWidgets(
      'should render the church name from HomeState.loaded in the drawer header',
      (tester) async {
        when(() => mockHomeCubit.state).thenReturn(
          HomeState.loaded(
            church: const Church(
              id: 'c1',
              name: 'Igreja Central',
              activePlan: 'free',
            ),
            birthdays: const [],
            upcomingEvents: const [],
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('Igreja Central'), findsOneWidget);
      },
    );

    testWidgets(
      'should fall back to "Igreja" placeholder when HomeState is not yet loaded',
      (tester) async {
        when(() => mockHomeCubit.state).thenReturn(const HomeState.initial());

        await tester.pumpWidget(buildSubject());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('Igreja'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /secretaria when the Secretaria drawer item is tapped',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Secretaria'));
        await tester.pumpAndSettle();

        expect(find.text('SECRETARIA_ROUTE'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /branches when the Congregações drawer item is tapped',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Congregações'));
        await tester.pumpAndSettle();

        expect(find.text('BRANCHES_ROUTE'), findsOneWidget);
      },
    );

    testWidgets('should navigate to /ebd when the EBD drawer item is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('EBD'));
      await tester.pumpAndSettle();

      expect(find.text('EBD_ROUTE'), findsOneWidget);
    });

    testWidgets(
      'should navigate to /coming-soon for drawer items that are not yet implemented',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finanças'));
        await tester.pumpAndSettle();

        expect(find.text('COMING_SOON_ROUTE'), findsOneWidget);
      },
    );
  });

  group('AuthenticatedShell - bottom nav', () {
    testWidgets(
      'should forward taps to onBottomNavTap when the caller provides an override (HomePage tab switching)',
      (tester) async {
        final taps = <int>[];
        await tester.pumpWidget(buildSubject(onBottomNavTap: taps.add));

        await tester.tap(find.text('Agenda'));
        await tester.pump();

        expect(taps, equals([1]));
      },
    );

    testWidgets(
      'should navigate to /home when a bottom nav tab is tapped on a screen that did not provide an override',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());

        await tester.tap(find.text('Início'));
        await tester.pumpAndSettle();

        expect(find.text('HOME_ROUTE'), findsOneWidget);
      },
    );

    testWidgets(
      'should carry the tapped tab index to /home via a ?tab= query param so HomePage can open the right sub-screen (fixes "Agenda sends me to Início" bug)',
      (tester) async {
        // Given — an inner shell (no onBottomNavTap override, like
        // /secretaria, /branches, etc.)
        String? capturedLocation;
        final router = GoRouter(
          initialLocation: '/host',
          routes: [
            GoRoute(
              path: '/host',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<HomeCubit>.value(value: mockHomeCubit),
                  BlocProvider<AuthCubit>.value(value: mockAuthCubit),
                ],
                child: const AuthenticatedShell(child: Text('INNER')),
              ),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) {
                // Record the full location the router resolved to so the
                // test can inspect the query string.
                capturedLocation = state.uri.toString();
                return Scaffold(
                  body: Text(
                    'HOME_ROUTE tab=${state.uri.queryParameters['tab']}',
                  ),
                );
              },
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  const Scaffold(body: Text('LOGIN_ROUTE')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        // When — user taps "Agenda" (index 1) from an inner shell
        await tester.tap(find.text('Agenda'));
        await tester.pumpAndSettle();

        // Then — navigation targets /home with ?tab=1 so HomePage opens the
        // Agenda sub-screen, NOT the Início dashboard.
        expect(capturedLocation, '/home?tab=1');
        expect(find.text('HOME_ROUTE tab=1'), findsOneWidget);
      },
    );

    testWidgets(
      'should highlight the bottom nav tab at the provided selectedBottomNavIndex',
      (tester) async {
        await tester.pumpWidget(buildSubject(selectedBottomNavIndex: 2));

        final semantics = tester.getSemantics(find.text('Notificações'));
        // flagsCollection.isSelected is a Tristate enum — .isTrue means the
        // flag is explicitly asserted (as opposed to unset or explicitly false).
        expect(semantics.flagsCollection.isSelected.name, 'isTrue');
      },
    );
  });

  group('AuthenticatedShell - profile sheet', () {
    testWidgets(
      'should open the profile bottom sheet when the avatar is tapped',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('R'));
        await tester.pumpAndSettle();

        expect(find.text('Meu Perfil'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /edit-profile when "Meu Perfil" is tapped in the sheet',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());

        await tester.tap(find.text('R'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Meu Perfil'));
        await tester.pumpAndSettle();

        expect(find.text('EDIT_PROFILE_ROUTE'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /coming-soon when "Configurações" is tapped in the sheet',
      (tester) async {
        await tester.pumpWidget(buildRoutedSubject());

        await tester.tap(find.text('R'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Configurações'));
        await tester.pumpAndSettle();

        expect(find.text('COMING_SOON_ROUTE'), findsOneWidget);
      },
    );

    testWidgets(
      'should await AuthCubit.logout before navigating to /login when "Sair" is tapped (prevents stale-token redirect race)',
      (tester) async {
        final eventLog = <String>[];
        final logoutCompleter = Completer<void>();
        when(() => mockAuthCubit.logout()).thenAnswer((_) async {
          eventLog.add('logout-start');
          await logoutCompleter.future;
          eventLog.add('logout-end');
        });

        final router = GoRouter(
          initialLocation: '/host',
          routes: [
            GoRoute(
              path: '/host',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<HomeCubit>.value(value: mockHomeCubit),
                  BlocProvider<AuthCubit>.value(value: mockAuthCubit),
                ],
                child: const AuthenticatedShell(child: Text('INNER')),
              ),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) {
                eventLog.add('login-route-built');
                return const Scaffold(body: Text('LOGIN_ROUTE'));
              },
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        await tester.tap(find.text('R'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Sair'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sair'));
        await tester.pump();
        await tester.pump();

        expect(
          eventLog,
          equals(['logout-start']),
          reason:
              'Navigation must not fire before logout resolves; otherwise the '
              'GoRouter redirect guard reads a stale access token.',
        );
        expect(find.text('LOGIN_ROUTE'), findsNothing);

        logoutCompleter.complete();
        await tester.pumpAndSettle();

        expect(
          eventLog,
          equals(['logout-start', 'logout-end', 'login-route-built']),
        );
        expect(find.text('LOGIN_ROUTE'), findsOneWidget);
      },
    );
  });
}
