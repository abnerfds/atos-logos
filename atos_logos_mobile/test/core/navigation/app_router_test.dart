import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/core/di/injection.dart';
import 'package:atos_logos_mobile/core/navigation/app_router.dart';
import 'package:atos_logos_mobile/core/navigation/auth_redirect.dart';
import 'package:atos_logos_mobile/features/auth/data/auth_repository.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/login_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('resolveAuthRedirect', () {
    test('redirects an unauthenticated user away from a protected route', () {
      final result = resolveAuthRedirect(
        currentPath: '/home',
        isAuthenticated: false,
      );
      expect(result, '/login');
    });

    test('lets an unauthenticated user stay on /login', () {
      final result = resolveAuthRedirect(
        currentPath: '/login',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });

    test('lets an unauthenticated user stay on /register', () {
      final result = resolveAuthRedirect(
        currentPath: '/register',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });

    test('lets an unauthenticated user stay on /select-church (2FA step)',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/select-church',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });

    test('redirects an authenticated user from /login to /home', () {
      final result = resolveAuthRedirect(
        currentPath: '/login',
        isAuthenticated: true,
      );
      expect(result, '/home');
    });

    test('lets an authenticated user access protected routes', () {
      final result = resolveAuthRedirect(
        currentPath: '/home',
        isAuthenticated: true,
      );
      expect(result, isNull);
    });

    test('lets an authenticated user access /secretaria', () {
      final result = resolveAuthRedirect(
        currentPath: '/secretaria',
        isAuthenticated: true,
      );
      expect(result, isNull);
    });
  });

  group('appRouter', () {
    test('should use /login as its initial location on cold start', () {
      // Given — the top-level appRouter constant
      // Then — the initial location matches the strategy (anonymous users go to /login)
      expect(appRouter.configuration.routes, isA<List<RouteBase>>());
      expect(appRouter, isA<GoRouter>());
      // The initialLocation is embedded in the GoRouter config — we assert it
      // indirectly via the router information provider's initial uri.
      expect(
        appRouter.routeInformationProvider.value.uri.path,
        '/login',
      );
    });

    test(
        'should expose every public and private route the login flow can land on',
        () {
      // Given — a map of path → expected presence in the router
      const expectedPaths = {
        '/login',
        '/register',
        '/select-church',
        '/home',
      };

      // When — the registered route paths are collected
      final registeredPaths = appRouter.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      // Then — every required path is registered (extra paths are fine)
      for (final required in expectedPaths) {
        expect(registeredPaths, contains(required));
      }
    });

    testWidgets(
        'should render the LoginPage on cold start when the user has no persisted session',
        (tester) async {
      // Given — an unauthenticated stub in the DI container AND a mock
      // AuthCubit for the LoginPage to consume via BlocProvider.
      final stubRepo = _MockAuthRepository();
      when(() => stubRepo.isAuthenticated()).thenAnswer((_) async => false);
      if (getIt.isRegistered<AuthRepository>()) {
        await getIt.unregister<AuthRepository>();
      }
      getIt.registerSingleton<AuthRepository>(stubRepo);

      final mockAuthCubit = _MockAuthCubit();
      when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());

      // When — MaterialApp.router is pumped with the real appRouter and
      // the mandatory AuthCubit provider LoginPage needs.
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Then — the initial navigation lands on /login and renders the page.
      // This exercises the `redirect` callback (lines 26-35) and the
      // `/login` route builder (line 40) in app_router.dart.
      expect(find.byType(LoginPage), findsOneWidget);

      // Cleanup: unregister the stub so later tests get a fresh container.
      await getIt.unregister<AuthRepository>();
    });
  });
}
