import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/core/error/backend_error_message.dart';

void main() {
  group('parseBackendErrorMessage', () {
    test('returns the string when the backend sends a plain string message', () {
      // Given — backend (NestJS, non-validation path) returns:
      //   { "message": "User not found", ... }
      final data = <String, dynamic>{'message': 'User not found'};

      // When / Then
      expect(parseBackendErrorMessage(data), 'User not found');
    });

    test(
        'joins the list with "; " when the backend sends class-validator errors '
        'as a list (fixes the "erro ao tentar salvar" crash on PATCH /memberships/by-user/:id/user-data)',
        () {
      // Given — class-validator default response shape:
      //   { "message": ["email must be an email", "cpf is not valid"], ... }
      final data = <String, dynamic>{
        'message': ['email must be an email', 'cpf is not valid'],
      };

      // When / Then
      expect(
        parseBackendErrorMessage(data),
        'email must be an email; cpf is not valid',
      );
    });

    test('returns the single list entry verbatim (no trailing separator)', () {
      final data = <String, dynamic>{
        'message': ['email must be an email'],
      };

      expect(parseBackendErrorMessage(data), 'email must be an email');
    });

    test('coerces non-string list entries to their String.toString()', () {
      final data = <String, dynamic>{
        'message': [123, 'other'],
      };

      expect(parseBackendErrorMessage(data), '123; other');
    });

    test('returns null when data is null', () {
      expect(parseBackendErrorMessage(null), isNull);
    });

    test('returns null when data has no message key', () {
      expect(parseBackendErrorMessage({'error': 'Bad Request'}), isNull);
    });

    test('returns null when message is an empty list', () {
      expect(parseBackendErrorMessage({'message': <String>[]}), isNull);
    });

    test('returns null when message is an unexpected type (map, number)', () {
      expect(parseBackendErrorMessage({'message': 42}), isNull);
      expect(parseBackendErrorMessage({'message': {'x': 'y'}}), isNull);
    });

    test('returns null when data is not a Map', () {
      expect(parseBackendErrorMessage('raw string'), isNull);
      expect(parseBackendErrorMessage(<String>['x']), isNull);
    });
  });
}
