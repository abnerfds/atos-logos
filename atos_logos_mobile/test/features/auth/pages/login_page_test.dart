// test/features/auth/pages/login_page_test.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/login_page.dart';

/// Finder that matches a RichText whose plain text contains [substring].
/// Use this when an inline link sits inside a Text.rich and `find.text`
/// won't match it because it's a TextSpan, not a child Text widget.
Finder findRichTextContaining(String substring) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is RichText && widget.text.toPlainText().contains(substring),
    description: 'RichText containing "$substring"',
  );
}

/// Locates the inline link with [linkText] inside the currently rendered
/// RichText and invokes its TapGestureRecognizer — same effect as a real
/// user tap on the link, but without depending on tap coordinates.
Future<void> tapInlineLink(WidgetTester tester, String linkText) async {
  final richText = tester.widget<RichText>(findRichTextContaining(linkText));
  TapGestureRecognizer? recognizer;
  richText.text.visitChildren((span) {
    if (span is TextSpan &&
        span.text == linkText &&
        span.recognizer is TapGestureRecognizer) {
      recognizer = span.recognizer as TapGestureRecognizer;
      return false;
    }
    return true;
  });
  expect(
    recognizer,
    isNotNull,
    reason: 'Expected a TapGestureRecognizer attached to "$linkText"',
  );
  recognizer!.onTap?.call();
  await tester.pumpAndSettle();
}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const LoginPage(),
      ),
    );
  }

  /// Build a LoginPage wrapped in a GoRouter with placeholder destinations
  /// so that navigation side-effects (context.go) can be asserted.
  Widget buildRoutedSubject() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME_ROUTE')),
        ),
        GoRoute(
          path: '/select-church',
          builder: (context, state) => const Scaffold(body: Text('SELECT_CHURCH_ROUTE')),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              const Scaffold(body: Text('REGISTER_ROUTE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('LoginPage - Layout', () {
    testWidgets('should display app logo and title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Atos Logos'), findsOneWidget);
      expect(find.text('Bem-vindo de Volta'), findsOneWidget);
      expect(find.text('Por favor, insira suas credenciais'), findsOneWidget);
    });

    testWidgets('should display email and password field labels',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('SENHA'), findsOneWidget);
    });

    testWidgets('should display enter button', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets(
        'should display the "Cadastre sua igreja" CTA pointing new admins to the signup flow',
        (tester) async {
      // Given / When — the page is pumped in its initial state
      await tester.pumpWidget(buildSubject());

      // Then — the prompt + the inline tappable link both render inside a
      // single RichText, and the link span carries a TapGestureRecognizer.
      final richText = tester.widget<RichText>(
        findRichTextContaining('Cadastre sua igreja'),
      );
      expect(richText.text.toPlainText(),
          'Não tem uma conta? Cadastre sua igreja');
      bool foundRecognizer = false;
      richText.text.visitChildren((span) {
        if (span is TextSpan &&
            span.text == 'Cadastre sua igreja' &&
            span.recognizer is TapGestureRecognizer) {
          foundRecognizer = true;
          return false;
        }
        return true;
      });
      expect(foundRecognizer, isTrue,
          reason:
              'The "Cadastre sua igreja" span must carry a TapGestureRecognizer');
    });

    testWidgets(
        'should not display non-functional "forgot password" link',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Esqueceu a senha?'), findsNothing);
    });

    testWidgets('should not display decorative footer links', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('PRIVACIDADE'), findsNothing);
      expect(find.text('TERMOS'), findsNothing);
      expect(find.text('SUPORTE'), findsNothing);
    });

    testWidgets('should not display "remember device" checkbox',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(Checkbox), findsNothing);
      expect(find.textContaining('Lembrar'), findsNothing);
    });
  });

  group('LoginPage - Interactions', () {
    testWidgets('should toggle password visibility on icon tap',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcon, findsOneWidget);
      await tester.tap(visibilityIcon);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should call login when form is valid and button pressed',
        (tester) async {
      when(() => mockAuthCubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      verify(() => mockAuthCubit.login(
            email: 'test@email.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should show validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.textContaining('e-mail'), findsOneWidget);
    });

    testWidgets('should show validation error when password is empty',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      // Fill only the email to isolate the password validation error.
      await tester.enterText(
          find.byType(TextFormField).first, 'test@email.com');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets(
        'should trim whitespace from email before forwarding to login()',
        (tester) async {
      when(() => mockAuthCubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.byType(TextFormField).first, '  user@test.com  ');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      verify(() => mockAuthCubit.login(
            email: 'user@test.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should start with password field obscured', (tester) async {
      await tester.pumpWidget(buildSubject());
      // The eye-off icon is only shown when obscureText is true.
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('should reject malformed email', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('should accept well-formed email', (tester) async {
      when(() => mockAuthCubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      verify(() => mockAuthCubit.login(
            email: 'user@test.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should reject password shorter than 6 characters',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('A senha deve ter ao menos 6 caracteres'),
          findsOneWidget);
    });

    TextField findInnerTextField(WidgetTester tester, {required bool last}) {
      final form = last
          ? find.byType(TextFormField).last
          : find.byType(TextFormField).first;
      return tester.widget<TextField>(
        find.descendant(of: form, matching: find.byType(TextField)),
      );
    }

    testWidgets('should expose email autofill hint', (tester) async {
      await tester.pumpWidget(buildSubject());
      final field = findInnerTextField(tester, last: false);
      expect(field.autofillHints, contains(AutofillHints.email));
    });

    testWidgets('should expose password autofill hint', (tester) async {
      await tester.pumpWidget(buildSubject());
      final field = findInnerTextField(tester, last: true);
      expect(field.autofillHints, contains(AutofillHints.password));
    });

    testWidgets(
        'should submit login when keyboard "done" is pressed on password field',
        (tester) async {
      when(() => mockAuthCubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      // Simulate the user hitting the "done" key on the keyboard.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      verify(() => mockAuthCubit.login(
            email: 'user@test.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets(
        'should advance focus to the password field when "next" is pressed on the email keyboard',
        (tester) async {
      // Given — the page is pumped and the email field is focused
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();

      // Sanity check: the email field currently has input focus.
      final emailFieldBefore = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).first,
          matching: find.byType(TextField),
        ),
      );
      expect(emailFieldBefore.focusNode?.hasFocus, isTrue);

      // When — the user presses the "next" key on the soft keyboard
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Then — focus jumps to the password field
      final passwordField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.focusNode?.hasFocus, isTrue);
    });
  });

  group('LoginPage - States', () {
    testWidgets('should show loading indicator when state is loading',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());
      await tester.pumpWidget(buildSubject());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when state is error',
        (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.fromIterable(
            [const AuthState.error(message: 'Credenciais invalidas')]),
        initialState: const AuthState.initial(),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.text('Credenciais invalidas'), findsOneWidget);
    });

    testWidgets('should disable submit button while loading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());
      await tester.pumpWidget(buildSubject());
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('LoginPage - Navigation', () {
    testWidgets('should navigate to /home when state becomes authenticated',
        (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.fromIterable([const AuthState.authenticated()]),
        initialState: const AuthState.initial(),
      );
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();
      expect(find.text('HOME_ROUTE'), findsOneWidget);
    });

    testWidgets(
        'should navigate to /select-church when state becomes churchSelection',
        (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.fromIterable([
          const AuthState.churchSelection(
            selectionToken: 'sel',
            churches: [],
          ),
        ]),
        initialState: const AuthState.initial(),
      );
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();
      expect(find.text('SELECT_CHURCH_ROUTE'), findsOneWidget);
    });

    testWidgets(
        'should navigate to /register when the "Cadastre sua igreja" CTA is tapped',
        (tester) async {
      // Given — the routed app is pumped on /login
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      // When — the user taps the inline signup link
      await tapInlineLink(tester, 'Cadastre sua igreja');

      // Then — the router transitioned to /register
      expect(find.text('REGISTER_ROUTE'), findsOneWidget);
    });
  });
}
