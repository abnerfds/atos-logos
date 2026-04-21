// Pure authentication-redirect logic for the GoRouter.
//
// Separated from the router itself so it can be unit-tested without
// spinning up a Widget tree. The GoRouter `redirect` callback just
// forwards to this function after reading `isAuthenticated()` from the
// repository.

/// Routes that are reachable without an authenticated session.
const Set<String> _kPublicPaths = {
  '/login',
  '/register',
  '/select-church',
};

/// Returns the path to redirect to, or `null` to stay on `currentPath`.
///
/// Rules:
///  - Unauthenticated users on a protected route → `/login`.
///  - Authenticated users hitting `/login` → `/home` (they're already in).
///  - Everything else: no redirect.
String? resolveAuthRedirect({
  required String currentPath,
  required bool isAuthenticated,
}) {
  final isPublic = _kPublicPaths.contains(currentPath);

  if (!isAuthenticated && !isPublic) {
    return '/login';
  }

  if (isAuthenticated && currentPath == '/login') {
    return '/home';
  }

  return null;
}
