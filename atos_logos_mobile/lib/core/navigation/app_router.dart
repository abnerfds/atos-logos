import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/pages/church_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/members/presentation/pages/create_member_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/members/presentation/pages/edit_member_page.dart';
import '../../features/profile/presentation/pages/member_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/branches/presentation/pages/branches_page.dart';
import '../../features/branches/presentation/pages/create_branch_page.dart';
import '../../features/branches/presentation/pages/edit_branch_page.dart';
import '../../shared/widgets/authenticated_shell.dart';
import '../../shared/widgets/coming_soon_page.dart';
import '../di/injection.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/branches/presentation/cubit/branches_cubit.dart';
import '../../features/members/presentation/cubit/members_cubit.dart';
import 'auth_redirect.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    // Persisted token acts as the source of truth for "logged in".
    // Token validity (expiry, revocation) is enforced by the API and
    // the AuthInterceptor's refresh flow, so we only need a presence
    // check here to gate navigation.
    final isAuthenticated = await getIt<AuthRepository>().isAuthenticated();
    return resolveAuthRedirect(
      currentPath: state.matchedLocation,
      isAuthenticated: isAuthenticated,
    );
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/select-church',
      builder: (context, state) => const ChurchSelectionPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/secretaria',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MembersCubit>()..loadMembers(),
        child: const AuthenticatedShell(child: MembersPage()),
      ),
    ),
    GoRoute(
      path: '/create-member',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MembersCubit>(),
        child: const AuthenticatedShell(child: CreateMemberPage()),
      ),
    ),
    GoRoute(
      path: '/member-profile/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProfileCubit>(),
        child: AuthenticatedShell(
          child: MemberProfilePage(profileId: state.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProfileCubit>(),
        child: const AuthenticatedShell(child: EditProfilePage()),
      ),
    ),
    GoRoute(
      path: '/edit-member/:id',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
          BlocProvider<MembersCubit>(create: (_) => getIt<MembersCubit>()),
        ],
        child: AuthenticatedShell(
          child: EditMemberPage(userId: state.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/branches',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BranchesCubit>(),
        child: const AuthenticatedShell(child: BranchesPage()),
      ),
    ),
    GoRoute(
      path: '/create-branch',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BranchesCubit>(),
        child: const AuthenticatedShell(child: CreateBranchPage()),
      ),
    ),
    GoRoute(
      path: '/edit-branch/:id',
      builder: (context, state) => BlocProvider(
        // A scoped cubit — matches the /create-branch pattern. The
        // parent /branches list reloads on pop (BranchesPage FAB handler
        // and tile onTap both await the push + re-fire loadBranches).
        create: (_) => getIt<BranchesCubit>(),
        child: AuthenticatedShell(
          child: EditBranchPage(branchId: state.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/coming-soon',
      builder: (context, state) => const AuthenticatedShell(
        child: ComingSoonPage(title: 'Em breve'),
      ),
    ),
  ],
);
