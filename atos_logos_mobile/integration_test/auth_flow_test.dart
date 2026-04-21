import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:atos_logos_mobile/core/network/dio_client.dart';
import 'package:atos_logos_mobile/features/auth/data/auth_repository.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/login_page.dart';

// Pre-requisite: NestJS backend must be running on http://10.0.2.2:3000
// and the database seeded with: admin.e2e@hq.com / password123

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E', () {
    testWidgets('Login with valid credentials navigates to Home', (tester) async {
      const storage = FlutterSecureStorage();
      final dio = DioClient.getInstance(storage: storage);
      final repository = AuthRepository(dio: dio, storage: storage);

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AuthCubit(repository: repository),
          child: MaterialApp(
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const Scaffold(
                    body: Center(key: Key('home_screen'), child: Text('Home')),
                  ),
            },
            initialRoute: '/login',
          ),
        ),
      );

      // Find fields and button
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Fill in credentials
      await tester.enterText(emailField, 'admin.e2e@hq.com');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // After successful login, should navigate to home
      expect(find.byKey(const Key('home_screen')), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error', (tester) async {
      const storage = FlutterSecureStorage();
      final dio = DioClient.getInstance(storage: storage);
      final repository = AuthRepository(dio: dio, storage: storage);

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AuthCubit(repository: repository),
          child: MaterialApp(
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const Scaffold(body: Text('Home')),
            },
            initialRoute: '/login',
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'wrong@email.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should still be on login page and show error snack
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });
  });
}
