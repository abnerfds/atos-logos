// test/features/auth/pages/register_page_test.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/register_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

/// Finder that matches a RichText whose plain text contains [substring].
/// Mirrors the helper used in login_page_test.dart for inline links.
Finder findRichTextContaining(String substring) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is RichText && widget.text.toPlainText().contains(substring),
    description: 'RichText containing "$substring"',
  );
}

/// Locates the inline link with [linkText] inside the currently rendered
/// RichText and invokes its TapGestureRecognizer programmatically.
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
        child: const RegisterPage(),
      ),
    );
  }

  /// Wraps the page in a real GoRouter so navigation side-effects
  /// (`context.go('/login')`, `context.go('/home')`) can be asserted.
  Widget buildRoutedSubject() {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const RegisterPage(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('LOGIN_ROUTE')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME_ROUTE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  /// Fills the form with a valid set of values. Used by interaction
  /// tests so the Arrange section stays small.
  Future<void> fillValidForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Igreja Teste');
    await tester.enterText(fields.at(1), 'Pastor João');
    await tester.enterText(fields.at(2), 'pastor@test.com');
    await tester.enterText(fields.at(3), 'password123');
    await tester.enterText(fields.at(4), 'password123');
  }

  group('RegisterPage - Layout', () {
    testWidgets(
        'should display the "Criar Conta da Igreja" headline when the page renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then
      expect(find.text('Criar Conta da Igreja'), findsOneWidget);
    });

    testWidgets(
        'should display every required admin-signup field label when the form renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — every label the backend SignupAdminDto needs is present
      expect(find.text('NOME DA SUA IGREJA'), findsOneWidget);
      expect(find.text('NOME DO PASTOR/LÍDER'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('SENHA'), findsOneWidget);
      expect(find.text('CONFIRMAR SENHA'), findsOneWidget);
    });

    testWidgets(
        'should display the "Criar Conta" submit button when the page renders',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Criar Conta'), findsOneWidget);
    });

    testWidgets(
        'should display the "Já tem uma conta?" prompt with an inline login link',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — the prompt + link are part of a single RichText whose
      // "Entre aqui" span carries a TapGestureRecognizer.
      final richText = tester.widget<RichText>(
        findRichTextContaining('Entre aqui'),
      );
      expect(
        richText.text.toPlainText(),
        'Já tem uma conta? Entre aqui',
      );
      bool foundRecognizer = false;
      richText.text.visitChildren((span) {
        if (span is TextSpan &&
            span.text == 'Entre aqui' &&
            span.recognizer is TapGestureRecognizer) {
          foundRecognizer = true;
          return false;
        }
        return true;
      });
      expect(foundRecognizer, isTrue);
    });

    testWidgets(
        'should NOT display the decorative PRIVACIDADE/TERMOS/SUPORTE footer',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('PRIVACIDADE'), findsNothing);
      expect(find.text('TERMOS'), findsNothing);
      expect(find.text('SUPORTE'), findsNothing);
    });

    testWidgets(
        'should expose the brand logo to assistive tech with a Semantics label',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — there is a Semantics node labelled "Logo Atos Logos"
      expect(
        find.bySemanticsLabel('Logo Atos Logos'),
        findsOneWidget,
      );
    });
  });

  group('RegisterPage - Field validation', () {
    testWidgets(
        'should reject an empty "nome da igreja" with its specific error',
        (tester) async {
      // Given — the user only fills the leader name
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      // When — submit
      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      // Then
      expect(find.text('Informe o nome da igreja'), findsOneWidget);
    });

    testWidgets(
        'should reject an empty "nome do líder" with its specific error',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.text('Informe o nome do líder'), findsOneWidget);
    });

    testWidgets('should reject an empty e-mail with the shared validator error',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('should reject a malformed e-mail with "E-mail inválido"',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'not-an-email');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets(
        'should reject a password shorter than 6 characters with the shared validator error',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), '12345');
      await tester.enterText(fields.at(4), '12345');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter ao menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets(
        'should reject mismatched confirm-password with "As senhas não coincidem"',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'different456');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets(
        'should reject empty confirm-password with "Confirme a senha"',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.text('Confirme a senha'), findsOneWidget);
    });

    testWidgets(
        'should NOT call AuthCubit.signup when any required field is missing',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      verifyNever(() => mockAuthCubit.signup(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            churchName: any(named: 'churchName'),
          ));
    });
  });

  group('RegisterPage - Interactions', () {
    testWidgets(
        'should reveal the password when the password visibility toggle is tapped',
        (tester) async {
      // Given
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(find.text('SENHA'));
      await tester.pumpAndSettle();
      // The password row's toggle is the first eye-off icon in the form.
      final hiddenIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(hiddenIcons, findsNWidgets(2)); // password + confirm

      // When — tap the first (password) toggle
      await tester.tap(hiddenIcons.first);
      await tester.pump();

      // Then — exactly one of the two toggles flipped
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
        'should reveal the confirm password independently of the password toggle',
        (tester) async {
      // Given
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(find.text('CONFIRMAR SENHA'));
      await tester.pumpAndSettle();
      final hiddenIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(hiddenIcons, findsNWidgets(2));

      // When — tap the second (confirm) toggle
      await tester.tap(hiddenIcons.last);
      await tester.pump();

      // Then — only confirm flipped
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
        'should call AuthCubit.signup with trimmed name/email/churchName and the raw password when the form is valid',
        (tester) async {
      // Given — the cubit accepts the call
      when(() => mockAuthCubit.signup(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            churchName: any(named: 'churchName'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());

      // When — fill the form (with surrounding whitespace) and submit
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '  Igreja Teste  ');
      await tester.enterText(fields.at(1), '  Pastor João  ');
      await tester.enterText(fields.at(2), '  pastor@test.com  ');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      // Then — text fields are trimmed, password is sent as-is
      verify(() => mockAuthCubit.signup(
            name: 'Pastor João',
            email: 'pastor@test.com',
            password: 'password123',
            churchName: 'Igreja Teste',
          )).called(1);
    });

    testWidgets(
        'should re-validate the confirm-password live when the password field changes',
        (tester) async {
      // Given — the cubit accepts the call and both fields are filled
      // with matching passwords. We submit once so the form transitions
      // out of its untouched state, then change only the password.
      when(() => mockAuthCubit.signup(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            churchName: any(named: 'churchName'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Igreja');
      await tester.enterText(fields.at(1), 'Pastor');
      await tester.enterText(fields.at(2), 'a@b.com');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.ensureVisible(find.text('Criar Conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar Conta'));
      await tester.pump();
      expect(find.text('As senhas não coincidem'), findsNothing);

      // When — the user goes back and changes the original password
      // so it no longer matches the confirm field
      await tester.enterText(fields.at(3), 'changed-now');
      await tester.pump();

      // Then — the confirm-password mismatch error appears live
      // (without needing another tap on the submit button)
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });
  });

  group('RegisterPage - Autofill + textInputAction', () {
    TextField innerTextField(WidgetTester tester, int index) {
      return tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).at(index),
          matching: find.byType(TextField),
        ),
      );
    }

    testWidgets(
        'should expose organizationName autofill hint on the church name field',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        innerTextField(tester, 0).autofillHints,
        contains(AutofillHints.organizationName),
      );
    });

    testWidgets('should expose name autofill hint on the leader name field',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        innerTextField(tester, 1).autofillHints,
        contains(AutofillHints.name),
      );
    });

    testWidgets('should expose email autofill hint on the e-mail field',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        innerTextField(tester, 2).autofillHints,
        contains(AutofillHints.email),
      );
    });

    testWidgets(
        'should expose newPassword autofill hint on the password field (so password managers offer generation)',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        innerTextField(tester, 3).autofillHints,
        contains(AutofillHints.newPassword),
      );
    });

    testWidgets(
        'should expose newPassword autofill hint on the confirm-password field',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        innerTextField(tester, 4).autofillHints,
        contains(AutofillHints.newPassword),
      );
    });

    testWidgets(
        'should set textInputAction.next on every field except the last one (which is "done")',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(innerTextField(tester, 0).textInputAction, TextInputAction.next);
      expect(innerTextField(tester, 1).textInputAction, TextInputAction.next);
      expect(innerTextField(tester, 2).textInputAction, TextInputAction.next);
      expect(innerTextField(tester, 3).textInputAction, TextInputAction.next);
      expect(innerTextField(tester, 4).textInputAction, TextInputAction.done);
    });

    testWidgets(
        'should advance focus from church name to leader name when "next" is pressed on the church field keyboard',
        (tester) async {
      // Given — the church field is focused
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextFormField).at(0));
      await tester.pump();

      // When — "next" is pressed
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Then — focus moved to the leader field
      expect(innerTextField(tester, 1).focusNode?.hasFocus, isTrue);
    });

    testWidgets(
        'should advance focus from leader name to e-mail when "next" is pressed on the leader field keyboard',
        (tester) async {
      // Given
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextFormField).at(1));
      await tester.pump();

      // When
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Then
      expect(innerTextField(tester, 2).focusNode?.hasFocus, isTrue);
    });

    testWidgets(
        'should advance focus from e-mail to password when "next" is pressed on the e-mail field keyboard',
        (tester) async {
      // Given
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pump();

      // When
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Then
      expect(innerTextField(tester, 3).focusNode?.hasFocus, isTrue);
    });

    testWidgets(
        'should advance focus from password to confirm-password when "next" is pressed on the password field keyboard',
        (tester) async {
      // Given — scroll the password field into view before tapping.
      // The register page is tall enough that it falls below the default
      // 800x600 test viewport.
      await tester.pumpWidget(buildSubject());
      await tester.ensureVisible(find.byType(TextFormField).at(3));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextFormField).at(3));
      await tester.pump();

      // When
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Then
      expect(innerTextField(tester, 4).focusNode?.hasFocus, isTrue);
    });

    testWidgets(
        'should submit the form when the user presses "done" on the confirm-password keyboard',
        (tester) async {
      // Given
      when(() => mockAuthCubit.signup(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            churchName: any(named: 'churchName'),
          )).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await fillValidForm(tester);
      // Focus the confirm field so the "done" action targets it.
      await tester.tap(find.byType(TextFormField).at(4));
      await tester.pump();

      // When
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Then
      verify(() => mockAuthCubit.signup(
            name: 'Pastor João',
            email: 'pastor@test.com',
            password: 'password123',
            churchName: 'Igreja Teste',
          )).called(1);
    });
  });

  group('RegisterPage - States', () {
    testWidgets(
        'should display a loading indicator inside the submit button while the cubit state is loading',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());
      await tester.pumpWidget(buildSubject());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should disable the submit button while the cubit state is loading',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());
      await tester.pumpWidget(buildSubject());
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'should show an error snackbar when the cubit transitions to an error state',
        (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.fromIterable(const [
          AuthState.error(message: 'Já existe um usuário com este e-mail.'),
        ]),
        initialState: const AuthState.initial(),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(
        find.text('Já existe um usuário com este e-mail.'),
        findsOneWidget,
      );
    });
  });

  group('RegisterPage - Navigation', () {
    testWidgets(
        'should navigate to /login when the "Entre aqui" inline link is tapped',
        (tester) async {
      // Given — the routed app is pumped on /register
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      // When — the user taps the inline login link
      await tapInlineLink(tester, 'Entre aqui');

      // Then — the router transitioned to /login
      expect(find.text('LOGIN_ROUTE'), findsOneWidget);
    });

    testWidgets(
        'should show a success snackbar and navigate to /home when the cubit transitions to authenticated (auto-login)',
        (tester) async {
      // Given — the cubit emits authenticated right after pump
      whenListen(
        mockAuthCubit,
        Stream.fromIterable(const [AuthState.authenticated()]),
        initialState: const AuthState.initial(),
      );

      // When — the page is pumped under a real GoRouter
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      // Then — the success snackbar is visible AND the router landed on /home
      expect(find.text('HOME_ROUTE'), findsOneWidget);
    });
  });
}
