import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const AtosLogosApp());
}

class AtosLogosApp extends StatelessWidget {
  const AtosLogosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // On app start, attempt a silent refresh so a returning user is
        // kept logged in without going through the login screen.
        BlocProvider(
          create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(create: (_) => getIt<HomeCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Atos Logos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
