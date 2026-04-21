# Layout Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refazer o layout visual de 5 telas do app Atos Logos para ficarem fiéis aos designs, criar endpoints backend necessários, e garantir cobertura de testes 100% via TDD.

**Architecture:** Full-stack por tela (Abordagem C). Cada tela é uma entrega completa com backend (se necessário) + mobile + testes. TDD clássico red-green-refactor em ambas camadas.

**Tech Stack:** NestJS + Prisma (backend), Flutter + BLoC + Freezed + GoRouter (mobile), Jest (backend tests), bloc_test + mocktail + flutter_test (mobile tests)

---

## File Map

### Backend — New/Modified Files

| Action | Path | Purpose |
|--------|------|---------|
| Modify | `src/modules/auth/auth.controller.ts` | Add `GET /auth/me` endpoint |
| Modify | `src/modules/auth/auth.service.ts` | Add `getProfile()` method |
| Modify | `src/modules/auth/auth.service.spec.ts` | Tests for `getProfile()` |
| Modify | `src/modules/member-profiles/member-profiles.controller.ts` | Add `GET /member-profiles/birthdays` |
| Modify | `src/modules/member-profiles/member-profiles.service.ts` | Add `findBirthdays()` method |
| Modify | `src/modules/member-profiles/member-profiles.service.spec.ts` | Tests for `findBirthdays()` |
| Create | `src/modules/member-profiles/dto/query-birthdays.dto.ts` | DTO for birthdays query |
| Modify | `src/modules/events/events.controller.ts` | Pass `upcoming` param to service |
| Modify | `src/modules/events/events.service.ts` | Add upcoming filter logic |
| Modify | `src/modules/events/events.service.spec.ts` | Tests for upcoming filter |
| Modify | `src/modules/events/dto/query-event.dto.ts` | Add `upcoming` field |

### Mobile — New/Modified Files

| Action | Path | Purpose |
|--------|------|---------|
| Create | `lib/shared/widgets/coming_soon_page.dart` | Reusable "Em breve" placeholder |
| Create | `lib/shared/widgets/app_bar_widget.dart` | Standardized AppBar (hamburger + logo + avatar) |
| Modify | `lib/features/auth/presentation/pages/login_page.dart` | Visual refactor to match design |
| Modify | `lib/features/auth/presentation/pages/register_page.dart` | Visual refactor to match design |
| Create | `lib/features/auth/domain/models/user_profile.dart` | Freezed model for /me response |
| Modify | `lib/features/auth/data/auth_repository.dart` | Add `getProfile()` method |
| Modify | `lib/features/auth/presentation/cubit/auth_cubit.dart` | Add `fetchProfile()` method |
| Modify | `lib/features/auth/presentation/cubit/auth_state.dart` | Add profile to state |
| Modify | `lib/features/home/presentation/pages/home_page.dart` | 5 tabs + new AppBar |
| Modify | `lib/features/home/presentation/pages/dashboard_page.dart` | Flip card + birthdays + events |
| Create | `lib/features/home/presentation/widgets/flip_card.dart` | Flip card animation widget |
| Create | `lib/features/home/domain/models/birthday_member.dart` | Freezed model for birthday data |
| Modify | `lib/features/home/domain/models/church.dart` | Keep as-is (used by existing cubit) |
| Modify | `lib/features/home/data/home_repository.dart` | Add birthdays + upcoming events |
| Modify | `lib/features/home/presentation/cubit/home_cubit.dart` | Load dashboard data |
| Modify | `lib/features/home/presentation/cubit/home_state.dart` | Add birthdays + events + profile |
| Modify | `lib/features/members/presentation/pages/members_page.dart` | Visual refactor + search + tabs |
| Modify | `lib/features/members/presentation/cubit/members_cubit.dart` | Add search functionality |
| Modify | `lib/features/members/presentation/cubit/members_state.dart` | Add search query to state |
| Create | `lib/features/members/presentation/pages/create_member_page.dart` | New member form (refactored) |

### Mobile — Test Files

| Action | Path | Purpose |
|--------|------|---------|
| Create | `test/shared/widgets/coming_soon_page_test.dart` | ComingSoonPage widget test |
| Create | `test/features/auth/pages/login_page_test.dart` | Login widget tests |
| Create | `test/features/auth/pages/register_page_test.dart` | Register widget tests |
| Create | `test/features/home/pages/home_page_test.dart` | Home navigation widget tests |
| Create | `test/features/home/widgets/flip_card_test.dart` | Flip card widget test |
| Modify | `test/home_cubit_test.dart` | Update for new dashboard data |
| Modify | `test/members_cubit_test.dart` | Add search tests |
| Create | `test/features/members/pages/members_page_test.dart` | Members list widget tests |
| Create | `test/features/members/pages/create_member_page_test.dart` | Member form widget tests |

---

## Task 1: Shared — ComingSoonPage Widget

**Files:**
- Create: `atos_logos_mobile/lib/shared/widgets/coming_soon_page.dart`
- Create: `atos_logos_mobile/test/shared/widgets/coming_soon_page_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/shared/widgets/coming_soon_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/shared/widgets/coming_soon_page.dart';

void main() {
  group('ComingSoonPage', () {
    testWidgets('should display "Em breve" title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );

      expect(find.text('Em breve'), findsOneWidget);
    });

    testWidgets('should display subtitle message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );

      expect(
        find.text('Estamos trabalhando nessa funcionalidade'),
        findsOneWidget,
      );
    });

    testWidgets('should display an icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ComingSoonPage())),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should accept optional custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ComingSoonPage(title: 'Notificações')),
        ),
      );

      expect(find.text('Notificações'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd atos_logos_mobile && flutter test test/shared/widgets/coming_soon_page_test.dart`
Expected: FAIL — `coming_soon_page.dart` not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/shared/widgets/coming_soon_page.dart
import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  final String? title;

  const ComingSoonPage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Em breve',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos trabalhando nessa funcionalidade',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd atos_logos_mobile && flutter test test/shared/widgets/coming_soon_page_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
cd atos-logos-core
git add atos_logos_mobile/lib/shared/widgets/coming_soon_page.dart atos_logos_mobile/test/shared/widgets/coming_soon_page_test.dart
git commit -m "feat(mobile): add ComingSoonPage reusable placeholder widget"
```

---

## Task 2: Shared — Standardized AppBar Widget

**Files:**
- Create: `atos_logos_mobile/lib/shared/widgets/app_bar_widget.dart`

- [ ] **Step 1: Write the failing test**

```dart
// Add to test/shared/widgets/coming_soon_page_test.dart or create new file
// For now, we test AppBar as part of the home_page tests in Task 8.
// The AppBar is a simple extracted widget — no separate test file needed.
```

- [ ] **Step 2: Implement the AppBar widget**

```dart
// lib/shared/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';

class AtosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userInitial;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;

  const AtosAppBar({
    super.key,
    this.userInitial,
    this.onMenuPressed,
    this.onAvatarPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed ?? () {},
      ),
      titleSpacing: 0,
      title: Text(
        'Atos Logos',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onAvatarPressed,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                userInitial ?? '?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add atos_logos_mobile/lib/shared/widgets/app_bar_widget.dart
git commit -m "feat(mobile): add standardized AtosAppBar widget"
```

---

## Task 3: Login — Visual Refactor (Widget Tests)

**Files:**
- Create: `atos_logos_mobile/test/features/auth/pages/login_page_test.dart`
- Modify: `atos_logos_mobile/lib/features/auth/presentation/pages/login_page.dart`

- [ ] **Step 1: Write the failing widget tests**

```dart
// test/features/auth/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/login_page.dart';

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

  group('LoginPage - Layout', () {
    testWidgets('should display app logo and title', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Atos Logos'), findsOneWidget);
      expect(find.text('Bem-vindo de Volta'), findsOneWidget);
      expect(find.text('Por favor, insira suas credenciais'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.widgetWithText(TextFormField, '').evaluate().length, greaterThanOrEqualTo(2));
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('SENHA'), findsOneWidget);
    });

    testWidgets('should display enter button', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('should display footer links', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('PRIVACIDADE'), findsOneWidget);
      expect(find.text('TERMOS'), findsOneWidget);
      expect(find.text('SUPORTE'), findsOneWidget);
    });
  });

  group('LoginPage - Interactions', () {
    testWidgets('should toggle password visibility on icon tap', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Find the visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should call login when form is valid and button pressed', (tester) async {
      when(() => mockAuthCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      verify(() => mockAuthCubit.login('test@email.com', 'password123')).called(1);
    });

    testWidgets('should show validation error when email is empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.textContaining('e-mail'), findsOneWidget);
    });
  });

  group('LoginPage - States', () {
    testWidgets('should show loading indicator when state is loading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when state is error', (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.fromIterable([const AuthState.error('Credenciais inválidas')]),
        initialState: const AuthState.initial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/auth/pages/login_page_test.dart`
Expected: FAIL — tests will fail because current LoginPage layout doesn't match expected design elements

- [ ] **Step 3: Rewrite LoginPage to match design**

Rewrite `lib/features/auth/presentation/pages/login_page.dart` completely to match the design spec. The new layout must have:
- Circular blue icon with "Atos Logos" text in teal
- "Bem-vindo de Volta" headline (Manrope)
- "Por favor, insira suas credenciais" subtitle
- E-MAIL field with #F0F4F8 background, uppercase label
- SENHA field with visibility toggle
- "Esqueceu a senha?" link right-aligned
- "Entrar →" full-width teal button
- Footer: PRIVACIDADE | TERMOS | SUPORTE
- "Não tem uma conta ainda? Converse com o Administrador"

```dart
// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          authenticated: () => context.go('/home'),
          churchSelection: (token, churches) => context.go('/select-church'),
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.church_outlined,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Atos Logos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Headlines
                    Text(
                      'Bem-vindo de Volta',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, insira suas credenciais',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email field
                    _buildLabel('E-MAIL'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(hint: 'seu@email.com'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    _buildLabel('SENHA'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Esqueceu a senha?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Submit button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        );

                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Secondary action
                    Text.rich(
                      TextSpan(
                        text: 'Não tem uma conta ainda? ',
                        style: theme.textTheme.bodySmall,
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                'Converse com o Administrador',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Footer links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _footerLink('PRIVACIDADE', theme),
                        _footerDot(theme),
                        _footerLink('TERMOS', theme),
                        _footerDot(theme),
                        _footerLink('SUPORTE', theme),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F4F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _footerLink(String text, ThemeData theme) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _footerDot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/auth/pages/login_page_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add atos_logos_mobile/lib/features/auth/presentation/pages/login_page.dart atos_logos_mobile/test/features/auth/pages/login_page_test.dart
git commit -m "feat(mobile): refactor LoginPage visual layout to match design spec"
```

---

## Task 4: Register — Visual Refactor (Widget Tests)

**Files:**
- Create: `atos_logos_mobile/test/features/auth/pages/register_page_test.dart`
- Modify: `atos_logos_mobile/lib/features/auth/presentation/pages/register_page.dart`

- [ ] **Step 1: Write the failing widget tests**

```dart
// test/features/auth/pages/register_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/register_page.dart';

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
        child: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage - Layout', () {
    testWidgets('should display page title and subtitle', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Criar Conta da Igreja'), findsOneWidget);
    });

    testWidgets('should display all required form fields', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('NOME DA SUA SEDE'), findsOneWidget);
      expect(find.text('NOME DO PASTOR/LÍDER'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('SENHA'), findsOneWidget);
      expect(find.text('CONFIRMAR SENHA'), findsOneWidget);
    });

    testWidgets('should display create account button', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Criar Conta'), findsOneWidget);
    });

    testWidgets('should display login link', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Já tem uma conta?'), findsOneWidget);
    });
  });

  group('RegisterPage - Interactions', () {
    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(buildSubject());

      final icons = find.byIcon(Icons.visibility_off_outlined);
      expect(icons, findsWidgets);

      await tester.tap(icons.first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    });

    testWidgets('should validate password confirmation mismatch', (tester) async {
      await tester.pumpWidget(buildSubject());

      final fields = find.byType(TextFormField);
      // Fill church name
      await tester.enterText(fields.at(0), 'Igreja Teste');
      // Fill leader name
      await tester.enterText(fields.at(1), 'Pastor João');
      // Fill email
      await tester.enterText(fields.at(2), 'test@email.com');
      // Fill password
      await tester.enterText(fields.at(3), 'password123');
      // Fill confirm password (mismatch)
      await tester.enterText(fields.at(4), 'different');

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.textContaining('senhas'), findsOneWidget);
    });
  });

  group('RegisterPage - States', () {
    testWidgets('should show loading indicator when submitting', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/auth/pages/register_page_test.dart`
Expected: FAIL — layout doesn't match expected elements

- [ ] **Step 3: Rewrite RegisterPage to match design**

Rewrite `lib/features/auth/presentation/pages/register_page.dart` to match design. Same input styling pattern as LoginPage (#F0F4F8 fill, uppercase labels, rounded corners). Fields: NOME DA SUA SEDE, NOME DO PASTOR/LÍDER, E-MAIL, SENHA (toggle), CONFIRMAR SENHA (toggle). Button "Criar Conta →". Link "Já tem uma conta? Entre aqui".

```dart
// lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  final _leaderNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _churchNameController.dispose();
    _leaderNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signup(
            _leaderNameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            _churchNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          registered: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conta criada com sucesso!')),
            );
            context.go('/login');
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Text(
                      'Atos Logos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Criar Conta da Igreja',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registre sua sede e comece a gerenciar sua organização',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Fields
                    _buildLabel('NOME DA SUA SEDE'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _churchNameController,
                      decoration: _inputDecoration(hint: 'Ex: Igreja Batista Central'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome da sede' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('NOME DO PASTOR/LÍDER'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _leaderNameController,
                      decoration: _inputDecoration(hint: 'Nome completo'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do líder' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('E-MAIL'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(hint: 'seu@email.com'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu e-mail' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('SENHA'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe sua senha';
                        if (v.length < 6) return 'Mínimo de 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('CONFIRMAR SENHA'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Submit
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Criar Conta'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Login link
                    Text.rich(
                      TextSpan(
                        text: 'Já tem uma conta? ',
                        style: theme.textTheme.bodySmall,
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Entre aqui',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F4F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/auth/pages/register_page_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add atos_logos_mobile/lib/features/auth/presentation/pages/register_page.dart atos_logos_mobile/test/features/auth/pages/register_page_test.dart
git commit -m "feat(mobile): refactor RegisterPage visual layout to match design spec"
```

---

## Task 5: Backend — GET /auth/me Endpoint

**Files:**
- Modify: `atos-logos-backend/src/modules/auth/auth.service.ts`
- Modify: `atos-logos-backend/src/modules/auth/auth.service.spec.ts`
- Modify: `atos-logos-backend/src/modules/auth/auth.controller.ts`

- [ ] **Step 1: Write the failing test for getProfile**

Add to `auth.service.spec.ts`:

```typescript
// Add this describe block to the existing auth.service.spec.ts file

describe('getProfile', () => {
  it('should return full user profile with membership, positions, church and branch', async () => {
    const userId = 'user-uuid';
    const churchId = 'church-uuid';

    const mockMembership = {
      id: 'membership-uuid',
      role: 'ADMIN',
      status: 'ACTIVE',
      branch: { id: 'branch-uuid', name: 'Sede Principal' },
      user: {
        id: userId,
        name: 'Ricardo Oliveira',
        email: 'ricardo@email.com',
        phone: '11999999999',
        memberProfiles: [{
          photoUrl: 'https://photo.url',
          admissionDate: new Date('2020-03-15'),
          birthDate: new Date('1990-05-20'),
          registrationNumber: '2020-ABCD-001',
        }],
        positions: [{
          position: { id: 'pos-uuid', name: 'Pastor' },
        }],
      },
      church: { id: churchId, name: 'Igreja Batista Central' },
    };

    prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);

    const result = await service.getProfile(userId, churchId);

    expect(result).toEqual({
      user: {
        id: userId,
        name: 'Ricardo Oliveira',
        email: 'ricardo@email.com',
        phone: '11999999999',
      },
      profile: {
        photoUrl: 'https://photo.url',
        admissionDate: new Date('2020-03-15'),
        birthDate: new Date('1990-05-20'),
        registrationNumber: '2020-ABCD-001',
      },
      membership: {
        role: 'ADMIN',
        status: 'ACTIVE',
      },
      positions: [{ id: 'pos-uuid', name: 'Pastor' }],
      church: { id: churchId, name: 'Igreja Batista Central' },
      branch: { id: 'branch-uuid', name: 'Sede Principal' },
    });
  });

  it('should throw NotFoundException when membership not found', async () => {
    prisma.membership.findFirst = jest.fn().mockResolvedValue(null);

    await expect(service.getProfile('user-uuid', 'church-uuid'))
      .rejects.toThrow(NotFoundException);
  });

  it('should return null profile fields when no member profile exists', async () => {
    const mockMembership = {
      id: 'membership-uuid',
      role: 'MEMBER',
      status: 'ACTIVE',
      branch: { id: 'branch-uuid', name: 'Sede' },
      user: {
        id: 'user-uuid',
        name: 'João',
        email: 'joao@email.com',
        phone: null,
        memberProfiles: [],
        positions: [],
      },
      church: { id: 'church-uuid', name: 'Igreja' },
    };

    prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);

    const result = await service.getProfile('user-uuid', 'church-uuid');

    expect(result.profile).toBeNull();
    expect(result.positions).toEqual([]);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=auth.service.spec`
Expected: FAIL — `getProfile` is not a function

- [ ] **Step 3: Implement getProfile in AuthService**

Add to `auth.service.ts` (after the `issueToken` method):

```typescript
async getProfile(userId: string, churchId: string) {
  const membership = await this.prisma.membership.findFirst({
    where: { userId, churchId },
    include: {
      branch: { select: { id: true, name: true } },
      church: { select: { id: true, name: true } },
      user: {
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          memberProfiles: {
            where: { churchId },
            select: {
              photoUrl: true,
              admissionDate: true,
              birthDate: true,
              registrationNumber: true,
            },
            take: 1,
          },
          positions: {
            include: {
              position: { select: { id: true, name: true } },
            },
          },
        },
      },
    },
  });

  if (!membership) {
    throw new NotFoundException('Membership not found');
  }

  const profile = membership.user.memberProfiles[0] ?? null;
  const positions = membership.user.positions.map((p) => p.position);

  return {
    user: {
      id: membership.user.id,
      name: membership.user.name,
      email: membership.user.email,
      phone: membership.user.phone,
    },
    profile,
    membership: {
      role: membership.role,
      status: membership.status,
    },
    positions,
    church: membership.church,
    branch: membership.branch,
  };
}
```

Add `NotFoundException` to imports at top of file if not already imported:
```typescript
import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=auth.service.spec`
Expected: All tests PASS

- [ ] **Step 5: Add controller endpoint**

Add to `auth.controller.ts`:

```typescript
import { UseGuards, Get } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@UseGuards(JwtAuthGuard)
@Get('me')
async getProfile(@CurrentUser() user: AuthenticatedUser) {
  return this.authService.getProfile(user.userId, user.churchId);
}
```

- [ ] **Step 6: Run all auth tests**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=auth`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
cd atos-logos-backend
git add src/modules/auth/auth.controller.ts src/modules/auth/auth.service.ts src/modules/auth/auth.service.spec.ts
git commit -m "feat(backend): add GET /auth/me endpoint for user profile"
```

---

## Task 6: Backend — GET /member-profiles/birthdays Endpoint

**Files:**
- Create: `atos-logos-backend/src/modules/member-profiles/dto/query-birthdays.dto.ts`
- Modify: `atos-logos-backend/src/modules/member-profiles/member-profiles.service.ts`
- Modify: `atos-logos-backend/src/modules/member-profiles/member-profiles.service.spec.ts`
- Modify: `atos-logos-backend/src/modules/member-profiles/member-profiles.controller.ts`

- [ ] **Step 1: Create the DTO**

```typescript
// src/modules/member-profiles/dto/query-birthdays.dto.ts
import { IsOptional, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class QueryBirthdaysDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month?: number;
}
```

- [ ] **Step 2: Write the failing test**

Add to `member-profiles.service.spec.ts`:

```typescript
describe('findBirthdays', () => {
  it('should return members with birthday in the specified month', async () => {
    const churchId = 'church-uuid';
    const month = 4;

    const mockProfiles = [
      {
        id: 'profile-1',
        birthDate: new Date('1995-04-12'),
        photoUrl: 'https://photo1.url',
        user: { name: 'Ana Paula' },
      },
      {
        id: 'profile-2',
        birthDate: new Date('1988-04-25'),
        photoUrl: null,
        user: { name: 'Carlos' },
      },
    ];

    prisma.$queryRaw = jest.fn().mockResolvedValue(mockProfiles);
    // Alternative: if using findMany with raw filter
    prisma.memberProfile.findMany = jest.fn().mockResolvedValue(mockProfiles);

    const result = await service.findBirthdays(churchId, month);

    expect(result).toEqual({
      data: [
        { id: 'profile-1', name: 'Ana Paula', photoUrl: 'https://photo1.url', birthDate: new Date('1995-04-12') },
        { id: 'profile-2', name: 'Carlos', photoUrl: null, birthDate: new Date('1988-04-25') },
      ],
      month: 4,
    });
  });

  it('should default to current month when month not provided', async () => {
    const churchId = 'church-uuid';
    prisma.memberProfile.findMany = jest.fn().mockResolvedValue([]);

    const result = await service.findBirthdays(churchId);

    expect(result.month).toBe(new Date().getMonth() + 1);
    expect(result.data).toEqual([]);
  });
});
```

- [ ] **Step 3: Run test to verify it fails**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=member-profiles.service.spec`
Expected: FAIL — `findBirthdays` is not a function

- [ ] **Step 4: Implement findBirthdays in service**

Add to `member-profiles.service.ts`:

```typescript
async findBirthdays(churchId: string, month?: number) {
  const targetMonth = month ?? (new Date().getMonth() + 1);

  const profiles = await this.prisma.memberProfile.findMany({
    where: {
      churchId,
      birthDate: { not: null },
    },
    include: {
      user: { select: { name: true } },
    },
  });

  const filtered = profiles.filter((p) => {
    if (!p.birthDate) return false;
    return p.birthDate.getMonth() + 1 === targetMonth;
  });

  return {
    data: filtered.map((p) => ({
      id: p.id,
      name: p.user.name,
      photoUrl: p.photoUrl,
      birthDate: p.birthDate,
    })),
    month: targetMonth,
  };
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=member-profiles.service.spec`
Expected: All tests PASS

- [ ] **Step 6: Add controller endpoint**

Add to `member-profiles.controller.ts` (before the existing `findAll`):

```typescript
import { QueryBirthdaysDto } from './dto/query-birthdays.dto';

@Get('birthdays')
async findBirthdays(
  @CurrentUser() user: AuthenticatedUser,
  @Query() query: QueryBirthdaysDto,
) {
  return this.memberProfilesService.findBirthdays(user.churchId, query.month);
}
```

**Important:** This route MUST be declared before `@Get(':id')` to avoid route conflict.

- [ ] **Step 7: Run all member-profiles tests**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=member-profiles`
Expected: All tests PASS

- [ ] **Step 8: Commit**

```bash
cd atos-logos-backend
git add src/modules/member-profiles/
git commit -m "feat(backend): add GET /member-profiles/birthdays endpoint"
```

---

## Task 7: Backend — Upcoming Events Filter

**Files:**
- Modify: `atos-logos-backend/src/modules/events/dto/query-event.dto.ts`
- Modify: `atos-logos-backend/src/modules/events/events.service.ts`
- Modify: `atos-logos-backend/src/modules/events/events.service.spec.ts`
- Modify: `atos-logos-backend/src/modules/events/events.controller.ts`

- [ ] **Step 1: Write the failing test**

Add to `events.service.spec.ts`:

```typescript
describe('findAll with upcoming filter', () => {
  it('should return only future events sorted by startsAt ASC when upcoming is true', async () => {
    const churchId = 'church-uuid';
    const now = new Date();
    const futureDate1 = new Date(now.getTime() + 86400000); // tomorrow
    const futureDate2 = new Date(now.getTime() + 172800000); // day after

    const mockEvents = [
      { id: 'event-1', title: 'Culto', startsAt: futureDate1, type: 'SERVICE' },
      { id: 'event-2', title: 'EBD', startsAt: futureDate2, type: 'EBD' },
    ];

    prisma.event.findMany = jest.fn().mockResolvedValue(mockEvents);
    prisma.event.count = jest.fn().mockResolvedValue(2);

    const result = await service.findAll(churchId, 1, 20, undefined, true);

    expect(prisma.event.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          churchId,
          startsAt: expect.objectContaining({ gte: expect.any(Date) }),
        }),
        orderBy: { startsAt: 'asc' },
      }),
    );
    expect(result.data).toHaveLength(2);
  });

  it('should combine upcoming with type filter', async () => {
    const churchId = 'church-uuid';

    prisma.event.findMany = jest.fn().mockResolvedValue([]);
    prisma.event.count = jest.fn().mockResolvedValue(0);

    await service.findAll(churchId, 1, 20, 'SERVICE' as any, true);

    expect(prisma.event.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          churchId,
          type: 'SERVICE',
          startsAt: expect.objectContaining({ gte: expect.any(Date) }),
        }),
      }),
    );
  });

  it('should return events in descending order when upcoming is false', async () => {
    const churchId = 'church-uuid';

    prisma.event.findMany = jest.fn().mockResolvedValue([]);
    prisma.event.count = jest.fn().mockResolvedValue(0);

    await service.findAll(churchId, 1, 20, undefined, false);

    expect(prisma.event.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        orderBy: { startsAt: 'desc' },
      }),
    );
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=events.service.spec`
Expected: FAIL — `findAll` doesn't accept 5th parameter

- [ ] **Step 3: Update QueryEventDto**

```typescript
// src/modules/events/dto/query-event.dto.ts
import { IsOptional, IsEnum, IsInt, Min, Max, IsBoolean } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { EventType } from '@prisma/client';

export class QueryEventDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @IsOptional()
  @IsEnum(EventType)
  type?: EventType;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  upcoming?: boolean;
}
```

- [ ] **Step 4: Update findAll in EventsService**

Modify `findAll` method in `events.service.ts` to accept and handle `upcoming` parameter:

```typescript
async findAll(
  churchId: string,
  page: number = 1,
  limit: number = 20,
  type?: EventType,
  upcoming?: boolean,
) {
  const skip = (page - 1) * limit;

  const where: any = { churchId };
  if (type) where.type = type;
  if (upcoming) where.startsAt = { gte: new Date() };

  const orderBy = upcoming ? { startsAt: 'asc' as const } : { startsAt: 'desc' as const };

  const [data, total] = await Promise.all([
    this.prisma.event.findMany({
      where,
      skip,
      take: limit,
      orderBy,
      include: {
        branch: true,
        schedules: { include: { user: { select: { id: true, name: true } } } },
        _count: { select: { visitorAttendances: true } },
      },
    }),
    this.prisma.event.count({ where }),
  ]);

  return { data, total, page, limit };
}
```

- [ ] **Step 5: Update controller**

Update `findAll` in `events.controller.ts`:

```typescript
@Get()
async findAll(
  @CurrentUser() user: AuthenticatedUser,
  @Query() query: QueryEventDto,
) {
  return this.eventsService.findAll(
    user.churchId,
    query.page,
    query.limit,
    query.type,
    query.upcoming,
  );
}
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd atos-logos-backend && npm test -- --testPathPattern=events`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
cd atos-logos-backend
git add src/modules/events/
git commit -m "feat(backend): add upcoming filter to GET /events endpoint"
```

---

## Task 8: Mobile — UserProfile Model + AuthRepository + AuthCubit Updates

**Files:**
- Create: `atos_logos_mobile/lib/features/auth/domain/models/user_profile.dart`
- Modify: `atos_logos_mobile/lib/features/auth/data/auth_repository.dart`
- Modify: `atos_logos_mobile/lib/features/auth/presentation/cubit/auth_cubit.dart`
- Modify: `atos_logos_mobile/lib/features/auth/presentation/cubit/auth_state.dart`
- Modify: `atos_logos_mobile/test/widget_test.dart` (existing auth cubit tests)

- [ ] **Step 1: Create UserProfile freezed model**

```dart
// lib/features/auth/domain/models/user_profile.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required UserProfileUser user,
    UserProfileDetail? profile,
    required UserProfileMembership membership,
    required List<UserProfilePosition> positions,
    required UserProfileChurch church,
    required UserProfileBranch branch,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserProfileUser with _$UserProfileUser {
  const factory UserProfileUser({
    required String id,
    required String name,
    required String email,
    String? phone,
  }) = _UserProfileUser;

  factory UserProfileUser.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUserFromJson(json);
}

@freezed
class UserProfileDetail with _$UserProfileDetail {
  const factory UserProfileDetail({
    String? photoUrl,
    String? admissionDate,
    String? birthDate,
    String? registrationNumber,
  }) = _UserProfileDetail;

  factory UserProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDetailFromJson(json);
}

@freezed
class UserProfileMembership with _$UserProfileMembership {
  const factory UserProfileMembership({
    required String role,
    required String status,
  }) = _UserProfileMembership;

  factory UserProfileMembership.fromJson(Map<String, dynamic> json) =>
      _$UserProfileMembershipFromJson(json);
}

@freezed
class UserProfilePosition with _$UserProfilePosition {
  const factory UserProfilePosition({
    required String id,
    required String name,
  }) = _UserProfilePosition;

  factory UserProfilePosition.fromJson(Map<String, dynamic> json) =>
      _$UserProfilePositionFromJson(json);
}

@freezed
class UserProfileChurch with _$UserProfileChurch {
  const factory UserProfileChurch({
    required String id,
    required String name,
  }) = _UserProfileChurch;

  factory UserProfileChurch.fromJson(Map<String, dynamic> json) =>
      _$UserProfileChurchFromJson(json);
}

@freezed
class UserProfileBranch with _$UserProfileBranch {
  const factory UserProfileBranch({
    required String id,
    required String name,
  }) = _UserProfileBranch;

  factory UserProfileBranch.fromJson(Map<String, dynamic> json) =>
      _$UserProfileBranchFromJson(json);
}
```

- [ ] **Step 2: Run build_runner to generate freezed files**

Run: `cd atos_logos_mobile && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated `user_profile.freezed.dart` and `user_profile.g.dart`

- [ ] **Step 3: Add getProfile to AuthRepository**

Add to `auth_repository.dart`:

```dart
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

Future<UserProfile> getProfile() async {
  try {
    final response = await _dio.get('/auth/me');
    return UserProfile.fromJson(response.data);
  } on DioException catch (e) {
    throw NetworkException(
      message: e.response?.data?['message'] ?? 'Failed to load profile',
      statusCode: e.response?.statusCode,
    );
  }
}
```

- [ ] **Step 4: Update AuthState to include profile**

Replace `auth_state.dart`:

```dart
// lib/features/auth/presentation/cubit/auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/church_option.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({UserProfile? profile}) = _Authenticated;
  const factory AuthState.churchSelection({
    required String selectionToken,
    required List<ChurchOption> churches,
  }) = _ChurchSelection;
  const factory AuthState.registered() = _Registered;
  const factory AuthState.error(String message) = _Error;
}
```

- [ ] **Step 5: Add fetchProfile to AuthCubit**

Add to `auth_cubit.dart`:

```dart
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

Future<void> fetchProfile() async {
  try {
    final profile = await _authRepository.getProfile();
    emit(AuthState.authenticated(profile: profile));
  } on AppException catch (e) {
    emit(AuthState.error(e.message));
  }
}
```

- [ ] **Step 6: Run build_runner to regenerate freezed state**

Run: `cd atos_logos_mobile && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 7: Update existing auth cubit tests**

Update `test/widget_test.dart` to account for the new `profile` parameter in `AuthState.authenticated`:

Where tests check `AuthState.authenticated()`, update to `AuthState.authenticated(profile: null)` or provide a mock profile as needed.

- [ ] **Step 8: Run all tests**

Run: `cd atos_logos_mobile && flutter test`
Expected: All tests PASS

- [ ] **Step 9: Commit**

```bash
cd atos_logos_mobile
git add lib/features/auth/ test/widget_test.dart
git commit -m "feat(mobile): add UserProfile model and fetchProfile to AuthCubit"
```

---

## Task 9: Mobile — Dashboard Models + Repository + HomeCubit

**Files:**
- Create: `atos_logos_mobile/lib/features/home/domain/models/birthday_member.dart`
- Modify: `atos_logos_mobile/lib/features/home/data/home_repository.dart`
- Modify: `atos_logos_mobile/lib/features/home/presentation/cubit/home_cubit.dart`
- Modify: `atos_logos_mobile/lib/features/home/presentation/cubit/home_state.dart`
- Modify: `atos_logos_mobile/test/home_cubit_test.dart`

- [ ] **Step 1: Create BirthdayMember model**

```dart
// lib/features/home/domain/models/birthday_member.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'birthday_member.freezed.dart';
part 'birthday_member.g.dart';

@freezed
class BirthdayMember with _$BirthdayMember {
  const factory BirthdayMember({
    required String id,
    required String name,
    String? photoUrl,
    required String birthDate,
  }) = _BirthdayMember;

  factory BirthdayMember.fromJson(Map<String, dynamic> json) =>
      _$BirthdayMemberFromJson(json);
}

@freezed
class BirthdaysResponse with _$BirthdaysResponse {
  const factory BirthdaysResponse({
    required List<BirthdayMember> data,
    required int month,
  }) = _BirthdaysResponse;

  factory BirthdaysResponse.fromJson(Map<String, dynamic> json) =>
      _$BirthdaysResponseFromJson(json);
}
```

- [ ] **Step 2: Run build_runner**

Run: `cd atos_logos_mobile && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Update HomeState**

```dart
// lib/features/home/presentation/cubit/home_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({
    required Church church,
    required List<BirthdayMember> birthdays,
    required List<dynamic> upcomingEvents,
  }) = _Loaded;
  const factory HomeState.error(String message) = _Error;
}
```

- [ ] **Step 4: Update HomeRepository**

Replace `home_repository.dart`:

```dart
// lib/features/home/data/home_repository.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';

@injectable
class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<Church> getChurch() async {
    try {
      final response = await _dio.get('/churches/me');
      return Church.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.response?.data?['message'] ?? 'Failed to load church',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<BirthdaysResponse> getBirthdays({int? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      final response = await _dio.get('/member-profiles/birthdays', queryParameters: queryParams);
      return BirthdaysResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.response?.data?['message'] ?? 'Failed to load birthdays',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getUpcomingEvents({int limit = 5}) async {
    try {
      final response = await _dio.get('/events', queryParameters: {
        'upcoming': true,
        'limit': limit,
      });
      return response.data;
    } on DioException catch (e) {
      throw NetworkException(
        message: e.response?.data?['message'] ?? 'Failed to load events',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
```

- [ ] **Step 5: Write failing cubit tests**

Replace `test/home_cubit_test.dart`:

```dart
// test/home_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/home/data/home_repository.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepo;

  setUp(() {
    mockRepo = MockHomeRepository();
  });

  final testChurch = Church(id: '1', name: 'Igreja Teste', activePlan: 'free');
  final testBirthdays = BirthdaysResponse(
    data: [
      BirthdayMember(id: '1', name: 'Ana', birthDate: '1995-04-12'),
      BirthdayMember(id: '2', name: 'Carlos', birthDate: '1988-04-25'),
    ],
    month: 4,
  );
  final testEvents = {
    'data': [
      {'id': '1', 'title': 'Culto', 'startsAt': '2026-04-12T19:30:00Z'},
    ],
    'total': 1,
  };

  group('HomeCubit - loadDashboard', () {
    blocTest<HomeCubit, HomeState>(
      'should emit loading then loaded with church, birthdays and events on success',
      build: () {
        when(() => mockRepo.getChurch()).thenAnswer((_) async => testChurch);
        when(() => mockRepo.getBirthdays()).thenAnswer((_) async => testBirthdays);
        when(() => mockRepo.getUpcomingEvents()).thenAnswer((_) async => testEvents);
        return HomeCubit(mockRepo);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: testBirthdays.data,
          upcomingEvents: testEvents['data'] as List,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should emit error when church fetch fails',
      build: () {
        when(() => mockRepo.getChurch()).thenThrow(
          const NetworkException(message: 'Network error'),
        );
        when(() => mockRepo.getBirthdays()).thenAnswer((_) async => testBirthdays);
        when(() => mockRepo.getUpcomingEvents()).thenAnswer((_) async => testEvents);
        return HomeCubit(mockRepo);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        const HomeState.error('Network error'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should emit loaded with empty birthdays when birthdays fetch fails',
      build: () {
        when(() => mockRepo.getChurch()).thenAnswer((_) async => testChurch);
        when(() => mockRepo.getBirthdays()).thenThrow(
          const NetworkException(message: 'Failed'),
        );
        when(() => mockRepo.getUpcomingEvents()).thenAnswer((_) async => testEvents);
        return HomeCubit(mockRepo);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeState.loading(),
        HomeState.loaded(
          church: testChurch,
          birthdays: [],
          upcomingEvents: testEvents['data'] as List,
        ),
      ],
    );
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

Run: `cd atos_logos_mobile && flutter test test/home_cubit_test.dart`
Expected: FAIL — `loadDashboard` doesn't exist

- [ ] **Step 7: Implement HomeCubit**

```dart
// lib/features/home/presentation/cubit/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/home/data/home_repository.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;

  HomeCubit(this._homeRepository) : super(const HomeState.initial());

  Future<void> loadDashboard() async {
    emit(const HomeState.loading());

    try {
      final church = await _homeRepository.getChurch();

      var birthdays = <dynamic>[];
      try {
        final birthdaysResponse = await _homeRepository.getBirthdays();
        birthdays = birthdaysResponse.data;
      } catch (_) {
        // Birthdays are non-critical — degrade gracefully
      }

      var upcomingEvents = <dynamic>[];
      try {
        final eventsResponse = await _homeRepository.getUpcomingEvents();
        upcomingEvents = (eventsResponse['data'] as List?) ?? [];
      } catch (_) {
        // Events are non-critical — degrade gracefully
      }

      emit(HomeState.loaded(
        church: church,
        birthdays: birthdays,
        upcomingEvents: upcomingEvents,
      ));
    } on AppException catch (e) {
      emit(HomeState.error(e.message));
    }
  }
}
```

- [ ] **Step 8: Run build_runner + tests**

Run: `cd atos_logos_mobile && dart run build_runner build --delete-conflicting-outputs && flutter test test/home_cubit_test.dart`
Expected: All tests PASS

- [ ] **Step 9: Commit**

```bash
cd atos_logos_mobile
git add lib/features/home/ test/home_cubit_test.dart
git commit -m "feat(mobile): add dashboard data loading with birthdays and upcoming events"
```

---

## Task 10: Mobile — FlipCard Widget

**Files:**
- Create: `atos_logos_mobile/lib/features/home/presentation/widgets/flip_card.dart`
- Create: `atos_logos_mobile/test/features/home/widgets/flip_card_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/home/widgets/flip_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/features/home/presentation/widgets/flip_card.dart';

void main() {
  group('FlipCard', () {
    testWidgets('should show front side by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );

      expect(find.text('Front'), findsOneWidget);
    });

    testWidgets('should flip to back on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('should flip back to front on second tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              front: const Text('Front'),
              back: const Text('Back'),
            ),
          ),
        ),
      );

      // First tap — flip to back
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      // Second tap — flip to front
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      expect(find.text('Front'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd atos_logos_mobile && flutter test test/features/home/widgets/flip_card_test.dart`
Expected: FAIL — `FlipCard` not found

- [ ] **Step 3: Implement FlipCard**

```dart
// lib/features/home/presentation/widgets/flip_card.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_controller.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/home/widgets/flip_card_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
cd atos_logos_mobile
git add lib/features/home/presentation/widgets/flip_card.dart test/features/home/widgets/flip_card_test.dart
git commit -m "feat(mobile): add FlipCard widget with animation"
```

---

## Task 11: Mobile — Dashboard Page Visual Refactor

**Files:**
- Modify: `atos_logos_mobile/lib/features/home/presentation/pages/dashboard_page.dart`
- Create: `atos_logos_mobile/test/features/home/pages/dashboard_page_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/home/pages/dashboard_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockAuthCubit mockAuthCubit;

  final testProfile = UserProfile(
    user: const UserProfileUser(id: '1', name: 'Ricardo', email: 'r@e.com'),
    profile: null,
    membership: const UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
    positions: [const UserProfilePosition(id: '1', name: 'Pastor')],
    church: const UserProfileChurch(id: '1', name: 'Igreja Teste'),
    branch: const UserProfileBranch(id: '1', name: 'Sede'),
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(AuthState.authenticated(profile: testProfile));
  });

  Widget buildSubject(HomeState state) {
    when(() => mockHomeCubit.state).thenReturn(state);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const Scaffold(body: DashboardPage()),
      ),
    );
  }

  group('DashboardPage - Greeting', () {
    testWidgets('should display greeting with user name', (tester) async {
      await tester.pumpWidget(buildSubject(
        HomeState.loaded(
          church: Church(id: '1', name: 'Igreja', activePlan: 'free'),
          birthdays: [],
          upcomingEvents: [],
        ),
      ));

      expect(find.textContaining('Olá, Ricardo'), findsOneWidget);
      expect(find.text('Bem-vindo ao seu painel de controle'), findsOneWidget);
    });
  });

  group('DashboardPage - FlipCard', () {
    testWidgets('should display member card with user name', (tester) async {
      await tester.pumpWidget(buildSubject(
        HomeState.loaded(
          church: Church(id: '1', name: 'Igreja', activePlan: 'free'),
          birthdays: [],
          upcomingEvents: [],
        ),
      ));

      expect(find.text('Ricardo'), findsWidgets);
    });
  });

  group('DashboardPage - Birthdays', () {
    testWidgets('should display birthday section with members', (tester) async {
      await tester.pumpWidget(buildSubject(
        HomeState.loaded(
          church: Church(id: '1', name: 'Igreja', activePlan: 'free'),
          birthdays: [
            BirthdayMember(id: '1', name: 'Ana', birthDate: '1995-04-12'),
            BirthdayMember(id: '2', name: 'Carlos', birthDate: '1988-04-25'),
          ],
          upcomingEvents: [],
        ),
      ));

      expect(find.text('Aniversariantes do Mês'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Carlos'), findsOneWidget);
    });
  });

  group('DashboardPage - Events', () {
    testWidgets('should display upcoming events section', (tester) async {
      await tester.pumpWidget(buildSubject(
        HomeState.loaded(
          church: Church(id: '1', name: 'Igreja', activePlan: 'free'),
          birthdays: [],
          upcomingEvents: [
            {'id': '1', 'title': 'Reunião de Oração', 'startsAt': '2026-04-12T19:30:00Z'},
          ],
        ),
      ));

      expect(find.text('Próximos Eventos'), findsOneWidget);
      expect(find.text('Reunião de Oração'), findsOneWidget);
    });
  });

  group('DashboardPage - Loading', () {
    testWidgets('should show loading indicator', (tester) async {
      await tester.pumpWidget(buildSubject(const HomeState.loading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/home/pages/dashboard_page_test.dart`
Expected: FAIL

- [ ] **Step 3: Rewrite DashboardPage**

Rewrite `lib/features/home/presentation/pages/dashboard_page.dart` to match the design with greeting, flip card, birthdays section, and upcoming events section. Use BlocBuilder for HomeCubit state and read AuthCubit for profile data. Use the FlipCard widget created in Task 10. Birthdays as horizontal scroll of CircleAvatars with name. Events as vertical list of cards with day number + title + time.

The implementation should consume `HomeState.loaded` with `church`, `birthdays`, and `upcomingEvents`, and `AuthState.authenticated` with `profile` for user name and card data.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/home/pages/dashboard_page_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
cd atos_logos_mobile
git add lib/features/home/presentation/pages/dashboard_page.dart test/features/home/pages/dashboard_page_test.dart
git commit -m "feat(mobile): refactor DashboardPage with flip card, birthdays and events"
```

---

## Task 12: Mobile — HomePage 5-Tab Navigation

**Files:**
- Modify: `atos_logos_mobile/lib/features/home/presentation/pages/home_page.dart`
- Create: `atos_logos_mobile/test/features/home/pages/home_page_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/home/pages/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/home_page.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockMembersCubit extends MockCubit<MembersState> implements MembersCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockAuthCubit mockAuthCubit;
  late MockMembersCubit mockMembersCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockAuthCubit = MockAuthCubit();
    mockMembersCubit = MockMembersCubit();

    when(() => mockHomeCubit.state).thenReturn(const HomeState.initial());
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(() => mockAuthCubit.state).thenReturn(const AuthState.authenticated());
    when(() => mockAuthCubit.fetchProfile()).thenAnswer((_) async {});
    when(() => mockMembersCubit.state).thenReturn(const MembersState.initial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<MembersCubit>.value(value: mockMembersCubit),
        ],
        child: const HomePage(),
      ),
    );
  }

  group('HomePage - Navigation', () {
    testWidgets('should display 5 bottom navigation tabs', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items.length, 5);
    });

    testWidgets('should display correct tab labels', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Secretaria'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Gestão'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('should show Início tab by default', (tester) async {
      await tester.pumpWidget(buildSubject());

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 0);
    });

    testWidgets('should show "Em breve" when Agenda tab is tapped', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Agenda'));
      await tester.pump();

      expect(find.text('Em breve'), findsOneWidget);
    });
  });

  group('HomePage - AppBar', () {
    testWidgets('should display Atos Logos text in AppBar', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Atos Logos'), findsOneWidget);
    });

    testWidgets('should display hamburger menu icon', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/home/pages/home_page_test.dart`
Expected: FAIL — current HomePage has 4 tabs, not 5

- [ ] **Step 3: Rewrite HomePage with 5 tabs + AtosAppBar**

Rewrite `lib/features/home/presentation/pages/home_page.dart`:
- Use `AtosAppBar` with user initial from AuthCubit profile
- 5 tabs: Início (DashboardPage), Secretaria (MembersPage), Agenda (ComingSoonPage), Gestão (ComingSoonPage), Notificações (ComingSoonPage)
- BottomNavigationBar with 5 items: home, people, calendar, groups, notifications icons
- Call `homeCubit.loadDashboard()` and `authCubit.fetchProfile()` on init

```dart
// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atos_logos_mobile/shared/widgets/app_bar_widget.dart';
import 'package:atos_logos_mobile/shared/widgets/coming_soon_page.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/members_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDashboard();
    context.read<AuthCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final userInitial = authState.maybeWhen(
          authenticated: (profile) => profile?.user.name[0].toUpperCase(),
          orElse: () => null,
        );

        return Scaffold(
          appBar: AtosAppBar(userInitial: userInitial),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              DashboardPage(),
              MembersPage(),
              ComingSoonPage(),
              ComingSoonPage(),
              ComingSoonPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
              BottomNavigationBarItem(icon: Icon(Icons.people_outlined), activeIcon: Icon(Icons.people), label: 'Secretaria'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Agenda'),
              BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Gestão'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Notificações'),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/home/pages/home_page_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
cd atos_logos_mobile
git add lib/features/home/presentation/pages/home_page.dart test/features/home/pages/home_page_test.dart
git commit -m "feat(mobile): refactor HomePage to 5-tab navigation with AtosAppBar"
```

---

## Task 13: Mobile — Secretaria/Members Page Visual Refactor

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/presentation/pages/members_page.dart`
- Modify: `atos_logos_mobile/lib/features/members/presentation/cubit/members_cubit.dart`
- Modify: `atos_logos_mobile/lib/features/members/presentation/cubit/members_state.dart`
- Create: `atos_logos_mobile/test/features/members/pages/members_page_test.dart`
- Modify: `atos_logos_mobile/test/members_cubit_test.dart`

- [ ] **Step 1: Update MembersState to include search**

```dart
// lib/features/members/presentation/cubit/members_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:atos_logos_mobile/features/members/domain/models/membership.dart';

part 'members_state.freezed.dart';

@freezed
class MembersState with _$MembersState {
  const factory MembersState.initial() = _Initial;
  const factory MembersState.loading() = _Loading;
  const factory MembersState.loaded({
    required List<Membership> members,
    required int total,
    required int page,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory MembersState.error(String message) = _Error;
}
```

- [ ] **Step 2: Write failing cubit search test**

Add to `test/members_cubit_test.dart`:

```dart
group('MembersCubit - search', () {
  blocTest<MembersCubit, MembersState>(
    'should filter members by name when searching',
    seed: () => MembersState.loaded(
      members: testMembers,
      total: 2,
      page: 1,
    ),
    build: () => MembersCubit(mockRepo),
    act: (cubit) => cubit.search('Ricardo'),
    expect: () => [
      MembersState.loaded(
        members: testMembers,
        total: 2,
        page: 1,
        searchQuery: 'Ricardo',
      ),
    ],
  );
});
```

- [ ] **Step 3: Add search method to MembersCubit**

Add to `members_cubit.dart`:

```dart
void search(String query) {
  final current = state;
  current.maybeWhen(
    loaded: (members, total, page, _) {
      emit(MembersState.loaded(
        members: members,
        total: total,
        page: page,
        searchQuery: query,
      ));
    },
    orElse: () {},
  );
}
```

- [ ] **Step 4: Run cubit tests**

Run: `cd atos_logos_mobile && dart run build_runner build --delete-conflicting-outputs && flutter test test/members_cubit_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Write failing widget tests for MembersPage**

```dart
// test/features/members/pages/members_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/members_page.dart';
import 'package:atos_logos_mobile/features/members/domain/models/membership.dart';

class MockMembersCubit extends MockCubit<MembersState> implements MembersCubit {}

void main() {
  late MockMembersCubit mockCubit;

  final testMembers = [
    Membership(
      id: '1', userId: 'u1', churchId: 'c1', branchId: 'b1',
      role: 'ADMIN', status: 'ACTIVE',
      user: MembershipUser(id: 'u1', name: 'Ricardo Oliveira'),
      branch: MembershipBranch(id: 'b1', name: 'Sede'),
    ),
    Membership(
      id: '2', userId: 'u2', churchId: 'c1', branchId: 'b1',
      role: 'MEMBER', status: 'ACTIVE',
      user: MembershipUser(id: 'u2', name: 'Ana Paula Santos'),
      branch: MembershipBranch(id: 'b1', name: 'Sede'),
    ),
  ];

  setUp(() {
    mockCubit = MockMembersCubit();
  });

  Widget buildSubject(MembersState state) {
    when(() => mockCubit.state).thenReturn(state);
    return MaterialApp(
      home: BlocProvider<MembersCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: MembersPage()),
      ),
    );
  }

  group('MembersPage - Layout', () {
    testWidgets('should display page title', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      expect(find.text('Secretaria'), findsOneWidget);
      expect(find.text('Gerencie membros e voluntários'), findsOneWidget);
    });

    testWidgets('should display 3 tabs', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      expect(find.text('Membros'), findsOneWidget);
      expect(find.text('Visitantes'), findsOneWidget);
      expect(find.text('EBD'), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display member names', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      expect(find.text('Ricardo Oliveira'), findsOneWidget);
      expect(find.text('Ana Paula Santos'), findsOneWidget);
    });
  });

  group('MembersPage - Search', () {
    testWidgets('should call search on text input', (tester) async {
      when(() => mockCubit.search(any())).thenReturn(null);
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      await tester.enterText(find.byType(TextField), 'Ricardo');
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => mockCubit.search('Ricardo')).called(1);
    });
  });

  group('MembersPage - FAB', () {
    testWidgets('should display floating action button', (tester) async {
      await tester.pumpWidget(buildSubject(
        MembersState.loaded(members: testMembers, total: 2, page: 1),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
```

- [ ] **Step 6: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/members/pages/members_page_test.dart`
Expected: FAIL

- [ ] **Step 7: Rewrite MembersPage to match design**

Rewrite `lib/features/members/presentation/pages/members_page.dart` with:
- Title "Secretaria" + subtitle
- 3 tabs: Membros (active), Visitantes (ComingSoonPage), EBD (ComingSoonPage)
- Search field with debounce calling `cubit.search(query)`
- Member list without dividers, generous spacing, avatar with initials, name + role
- FAB lavender button for adding member
- Client-side filter using `searchQuery` from state

- [ ] **Step 8: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/members/pages/members_page_test.dart`
Expected: All tests PASS

- [ ] **Step 9: Commit**

```bash
cd atos_logos_mobile
git add lib/features/members/ test/features/members/ test/members_cubit_test.dart
git commit -m "feat(mobile): refactor MembersPage with search, tabs and design update"
```

---

## Task 14: Mobile — Create Member Page Visual Refactor

**Files:**
- Create: `atos_logos_mobile/lib/features/members/presentation/pages/create_member_page.dart`
- Create: `atos_logos_mobile/test/features/members/pages/create_member_page_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/members/pages/create_member_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_cubit.dart';
import 'package:atos_logos_mobile/features/members/presentation/cubit/members_state.dart';
import 'package:atos_logos_mobile/features/members/presentation/pages/create_member_page.dart';

class MockMembersCubit extends MockCubit<MembersState> implements MembersCubit {}

void main() {
  late MockMembersCubit mockCubit;

  setUp(() {
    mockCubit = MockMembersCubit();
    when(() => mockCubit.state).thenReturn(const MembersState.initial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<MembersCubit>.value(
        value: mockCubit,
        child: const CreateMemberPage(),
      ),
    );
  }

  group('CreateMemberPage - Layout', () {
    testWidgets('should display page title', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Novo Membro'), findsOneWidget);
    });

    testWidgets('should display avatar placeholder', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Foto do Perfil'), findsOneWidget);
    });

    testWidgets('should display personal info form fields', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('TELEFONE'), findsOneWidget);
      expect(find.text('DATA DE NASCIMENTO'), findsOneWidget);
    });

    testWidgets('should display collapsible section header', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Informações Pessoais'), findsOneWidget);
    });
  });

  group('CreateMemberPage - Validation', () {
    testWidgets('should show error when name is empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Find and tap submit/save button
      final saveButton = find.byType(FilledButton);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pump();

        expect(find.textContaining('nome'), findsWidgets);
      }
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd atos_logos_mobile && flutter test test/features/members/pages/create_member_page_test.dart`
Expected: FAIL — `CreateMemberPage` not found

- [ ] **Step 3: Implement CreateMemberPage**

Create `lib/features/members/presentation/pages/create_member_page.dart`:
- AppBar with back button
- Title "Novo Membro" + subtitle
- Circular teal avatar placeholder with "Foto do Perfil"
- Collapsible "Informações Pessoais" section with expand/collapse
- Fields: NOME COMPLETO, E-MAIL, TELEFONE, DATA DE NASCIMENTO (date picker), DATA DE MEMBRO/BATISMO (date picker)
- Same input styling as Login/Register (#F0F4F8, uppercase labels, rounded corners)
- Save button at bottom

```dart
// lib/features/members/presentation/pages/create_member_page.dart
import 'package:flutter/material.dart';

class CreateMemberPage extends StatefulWidget {
  const CreateMemberPage({super.key});

  @override
  State<CreateMemberPage> createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _admissionDateController = TextEditingController();
  bool _personalInfoExpanded = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _admissionDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Atos Logos',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Novo Membro',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados para criar um novo membro na sua Igreja',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Avatar
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Foto do Perfil',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Collapsible section
                GestureDetector(
                  onTap: () => setState(() => _personalInfoExpanded = !_personalInfoExpanded),
                  child: Row(
                    children: [
                      Text(
                        'Informações Pessoais',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(_personalInfoExpanded ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
                if (_personalInfoExpanded) ...[
                  const SizedBox(height: 16),
                  _buildLabel('NOME COMPLETO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(hint: 'Nome completo do membro'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('E-MAIL'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(hint: 'email@exemplo.com'),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('TELEFONE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(hint: '(00) 00000-0000'),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('DATA DE NASCIMENTO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: () => _selectDate(_birthDateController),
                    decoration: _inputDecoration(
                      hint: 'dd/mm/aaaa',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('DATA DE MEMBRO/BATISMO'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _admissionDateController,
                    readOnly: true,
                    onTap: () => _selectDate(_admissionDateController),
                    decoration: _inputDecoration(
                      hint: 'dd/mm/aaaa',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // TODO: Submit through cubit when backend integration is connected
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar Membro'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F4F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd atos_logos_mobile && flutter test test/features/members/pages/create_member_page_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
cd atos_logos_mobile
git add lib/features/members/presentation/pages/create_member_page.dart test/features/members/pages/create_member_page_test.dart
git commit -m "feat(mobile): add CreateMemberPage matching design spec"
```

---

## Task 15: Mobile — Navigation Wiring + Final Integration

**Files:**
- Modify: `atos_logos_mobile/lib/core/navigation/app_router.dart`
- Modify: `atos_logos_mobile/lib/core/di/injection.dart` (if needed)

- [ ] **Step 1: Update app_router.dart to add create-member route**

```dart
// Add to app_router.dart routes list:
GoRoute(
  path: '/create-member',
  builder: (context, state) => const CreateMemberPage(),
),
```

Add import:
```dart
import 'package:atos_logos_mobile/features/members/presentation/pages/create_member_page.dart';
```

- [ ] **Step 2: Run all tests to verify nothing is broken**

Run: `cd atos_logos_mobile && flutter test`
Expected: All tests PASS

- [ ] **Step 3: Run backend tests too**

Run: `cd atos-logos-backend && npm test`
Expected: All tests PASS

- [ ] **Step 4: Commit**

```bash
git add atos_logos_mobile/lib/core/navigation/app_router.dart
git commit -m "feat(mobile): add create-member route and finalize navigation wiring"
```

---

## Task 16: Full Test Suite Verification

- [ ] **Step 1: Run all backend tests**

Run: `cd atos-logos-backend && npm test`
Expected: All tests PASS, no failures

- [ ] **Step 2: Run all mobile tests**

Run: `cd atos_logos_mobile && flutter test`
Expected: All tests PASS, no failures

- [ ] **Step 3: Run mobile test coverage**

Run: `cd atos_logos_mobile && flutter test --coverage`
Expected: Coverage report generated at `coverage/lcov.info`

- [ ] **Step 4: Final commit if any fixes needed**

```bash
git add -A
git commit -m "test: ensure full test suite passes across backend and mobile"
```
