// Shared validators for the auth screens (LoginPage, RegisterPage, etc.).
//
// Both pages used to inline their own regex and min-length constants,
// which led to drift (different patterns, different error messages, one
// allowed `.museum` TLDs and the other did not). Centralized here so the
// validation surface stays consistent — and matches the backend DTOs.

/// Lightweight RFC-5322-ish email pattern. Good enough for client-side
/// UX; the backend's `class-validator` `@IsEmail()` is the source of truth.
final RegExp kEmailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Minimum password length, mirrors `LoginDto.@MinLength(6)` and
/// `SignupAdminDto.@MinLength(6)` on the backend.
const int kPasswordMinLength = 6;

/// Returns the error message for an email field, or `null` if valid.
/// Trims whitespace before checking emptiness so a `"   "` value is
/// treated as empty.
String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Informe o e-mail';
  }
  if (!kEmailRegex.hasMatch(trimmed)) {
    return 'E-mail inválido';
  }
  return null;
}

/// Returns the error message for a password field, or `null` if valid.
/// Does NOT trim — whitespace can legitimately be part of a password.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Informe a senha';
  }
  if (value.length < kPasswordMinLength) {
    return 'A senha deve ter ao menos $kPasswordMinLength caracteres';
  }
  return null;
}

/// Returns the error for a non-empty required text field. Used for things
/// like "nome da igreja", "nome do líder", etc. The [fieldLabel] is
/// inserted into the error message.
String? validateRequired(String? value, String fieldLabel) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe $fieldLabel';
  }
  return null;
}

/// Returns the error when [confirmation] does not match [original].
/// Empty confirmation is treated as a separate failure case.
String? validatePasswordConfirmation(String? confirmation, String original) {
  if (confirmation == null || confirmation.isEmpty) {
    return 'Confirme a senha';
  }
  if (confirmation != original) {
    return 'As senhas não coincidem';
  }
  return null;
}
