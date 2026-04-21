import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/auth/presentation/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('should return "Informe o e-mail" when value is null', () {
      expect(validateEmail(null), 'Informe o e-mail');
    });

    test('should return "Informe o e-mail" when value is empty', () {
      expect(validateEmail(''), 'Informe o e-mail');
    });

    test('should return "Informe o e-mail" when value is whitespace-only', () {
      expect(validateEmail('   '), 'Informe o e-mail');
    });

    test(
        'should return "E-mail inválido" when the value does not contain an @',
        () {
      expect(validateEmail('not-an-email'), 'E-mail inválido');
    });

    test(
        'should return "E-mail inválido" when the value has no domain TLD',
        () {
      expect(validateEmail('user@host'), 'E-mail inválido');
    });

    test('should return null for a well-formed e-mail', () {
      expect(validateEmail('user@test.com'), isNull);
    });

    test(
        'should return null for an e-mail with a long TLD (e.g. .museum)',
        () {
      expect(validateEmail('curator@history.museum'), isNull);
    });

    test('should accept e-mails with subdomains', () {
      expect(validateEmail('admin@church.example.org'), isNull);
    });

    test('should return "E-mail inválido" when TLD has only 1 character', () {
      expect(validateEmail('user@domain.a'), 'E-mail inválido');
    });

    test('should accept e-mails with dots and plus in local part', () {
      expect(validateEmail('first.last+tag@test.com'), isNull);
    });

    test('should return "E-mail inválido" when domain has no TLD at all', () {
      expect(validateEmail('user@'), 'E-mail inválido');
    });
  });

  group('validatePassword', () {
    test('should return "Informe a senha" when value is null', () {
      expect(validatePassword(null), 'Informe a senha');
    });

    test('should return "Informe a senha" when value is empty', () {
      expect(validatePassword(''), 'Informe a senha');
    });

    test(
        'should return "A senha deve ter ao menos 6 caracteres" when value is shorter than the minimum',
        () {
      expect(
        validatePassword('12345'),
        'A senha deve ter ao menos 6 caracteres',
      );
    });

    test('should return null for a password exactly 6 characters long', () {
      expect(validatePassword('123456'), isNull);
    });

    test('should return null for a longer password', () {
      expect(validatePassword('a-strong-passphrase'), isNull);
    });

    test('should NOT trim whitespace (spaces can be part of a password)',
        () {
      // 6 spaces should pass — whitespace is intentionally allowed.
      expect(validatePassword('      '), isNull);
    });
  });

  group('validateRequired', () {
    test('should return "Informe X" when value is null', () {
      expect(validateRequired(null, 'o nome'), 'Informe o nome');
    });

    test('should return "Informe X" when value is empty', () {
      expect(validateRequired('', 'o nome'), 'Informe o nome');
    });

    test('should return "Informe X" when value is whitespace-only', () {
      expect(validateRequired('   ', 'o nome'), 'Informe o nome');
    });

    test('should return null for a non-empty value', () {
      expect(validateRequired('Pastor', 'o nome'), isNull);
    });
  });

  group('validatePasswordConfirmation', () {
    test('should return "Confirme a senha" when confirmation is null', () {
      expect(validatePasswordConfirmation(null, 'pwd123'), 'Confirme a senha');
    });

    test('should return "Confirme a senha" when confirmation is empty', () {
      expect(validatePasswordConfirmation('', 'pwd123'), 'Confirme a senha');
    });

    test(
        'should return "As senhas não coincidem" when confirmation differs from original',
        () {
      expect(
        validatePasswordConfirmation('pwd456', 'pwd123'),
        'As senhas não coincidem',
      );
    });

    test('should return null when confirmation matches the original', () {
      expect(validatePasswordConfirmation('pwd123', 'pwd123'), isNull);
    });
  });
}
