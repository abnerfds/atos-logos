import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/core/navigation/auth_redirect.dart';

void main() {
  group('resolveAuthRedirect', () {
    test(
        'should redirect to /login when user is unauthenticated on a protected route',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/home',
        isAuthenticated: false,
      );
      expect(result, '/login');
    });

    test(
        'should redirect to /home when user is authenticated and visiting /login',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/login',
        isAuthenticated: true,
      );
      expect(result, '/home');
    });

    test(
        'should return null (no redirect) when user is authenticated on a protected route',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/home',
        isAuthenticated: true,
      );
      expect(result, isNull);
    });

    test(
        'should return null (no redirect) when user is unauthenticated on /register',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/register',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });

    test(
        'should return null (no redirect) when user is unauthenticated on /select-church',
        () {
      final result = resolveAuthRedirect(
        currentPath: '/select-church',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });
  });
}
