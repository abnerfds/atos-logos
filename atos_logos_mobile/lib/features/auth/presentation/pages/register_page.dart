import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../auth_validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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
  final _churchFocus = FocusNode();
  final _leaderFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// Recognizer for the inline "Entre aqui" link to /login. Kept stateful
  /// so its lifecycle is tied to the State and disposed correctly.
  late final TapGestureRecognizer _loginTapRecognizer;

  @override
  void initState() {
    super.initState();
    _loginTapRecognizer = TapGestureRecognizer()
      ..onTap = () => context.go('/login');
  }

  @override
  void dispose() {
    _churchNameController.dispose();
    _leaderNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _churchFocus.dispose();
    _leaderFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _loginTapRecognizer.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signup(
            name: _leaderNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            churchName: _churchNameController.text.trim(),
          );
    }
  }

  /// Re-runs form validation whenever the password changes so the
  /// confirm-password field updates its mismatch error live, instead of
  /// staying stale until the user submits the form.
  void _onPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: AppTheme.outline,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppTheme.surfaceContainerHigh,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta criada com sucesso!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
              context.go('/home');
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 448),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.surfaceContainerLow),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Logo --
                    Center(
                      child: Semantics(
                        label: 'Logo Atos Logos',
                        image: true,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXl),
                          ),
                          child: const Icon(
                            Icons.church,
                            size: 28,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // -- Brand --
                    Center(
                      child: Text(
                        'Atos Logos',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // -- Title --
                    Center(
                      child: Text(
                        'Criar Conta da Igreja',
                        style: GoogleFonts.manrope(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // -- Subtitle --
                    Center(
                      child: Text(
                        'Registre sua igreja e comece a gerenciar sua organização',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // -- Form --
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        );
                        return AbsorbPointer(
                          absorbing: isLoading,
                          child: _RegisterForm(
                            formKey: _formKey,
                            churchNameController: _churchNameController,
                            leaderNameController: _leaderNameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            churchFocus: _churchFocus,
                            leaderFocus: _leaderFocus,
                            emailFocus: _emailFocus,
                            passwordFocus: _passwordFocus,
                            confirmFocus: _confirmFocus,
                            obscurePassword: _obscurePassword,
                            obscureConfirm: _obscureConfirm,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onToggleConfirm: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            onPasswordChanged: _onPasswordChanged,
                            onSubmit: _submit,
                            isLoading: isLoading,
                            inputDecoration: _inputDecoration,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // -- Footer link to /login --
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Já tem uma conta? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: 'Entre aqui',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                              recognizer: _loginTapRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulled out of the build method so the BlocBuilder/AbsorbPointer wrapper
/// stays readable. Holds zero state of its own — every controller and
/// FocusNode lives in `_RegisterPageState`.
class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.churchNameController,
    required this.leaderNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.churchFocus,
    required this.leaderFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.inputDecoration,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController churchNameController;
  final TextEditingController leaderNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode churchFocus;
  final FocusNode leaderFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onPasswordChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final InputDecoration Function({
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) inputDecoration;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('NOME DA SUA IGREJA'),
          const SizedBox(height: 8),
          TextFormField(
            controller: churchNameController,
            focusNode: churchFocus,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.organizationName],
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(leaderFocus),
            decoration: inputDecoration(
              hintText: 'Ex: Comunidade da Graça',
              prefixIcon: const Icon(
                Icons.church_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
            validator: (v) => validateRequired(v, 'o nome da igreja'),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('NOME DO PASTOR/LÍDER'),
          const SizedBox(height: 8),
          TextFormField(
            controller: leaderNameController,
            focusNode: leaderFocus,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(emailFocus),
            decoration: inputDecoration(
              hintText: 'Nome completo',
              prefixIcon: const Icon(
                Icons.person_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
            validator: (v) => validateRequired(v, 'o nome do líder'),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('E-MAIL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            focusNode: emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocus),
            decoration: inputDecoration(
              hintText: 'pastor@igreja.com',
              prefixIcon: const Icon(
                Icons.mail_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
            validator: validateEmail,
          ),
          const SizedBox(height: 20),
          const _FieldLabel('SENHA'),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            // newPassword (vs. password) signals "this is a new credential"
            // so password managers offer to *generate* a strong one.
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) => onPasswordChanged(),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(confirmFocus),
            decoration: inputDecoration(
              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.outline,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
            validator: validatePassword,
          ),
          const SizedBox(height: 20),
          const _FieldLabel('CONFIRMAR SENHA'),
          const SizedBox(height: 8),
          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmFocus,
            obscureText: obscureConfirm,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) => onSubmit(),
            decoration: inputDecoration(
              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: AppTheme.outline,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.outline,
                  size: 20,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
            validator: (v) =>
                validatePasswordConfirmation(v, passwordController.text),
          ),
          const SizedBox(height: 28),

          // Submit button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.buttonShadow,
            ),
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Criar Conta',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
