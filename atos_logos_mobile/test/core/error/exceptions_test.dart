import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('should store the message', () {
      final ex = AppException('something went wrong');
      expect(ex.message, 'something went wrong');
    });

    test('should return the message from toString()', () {
      final ex = AppException('something went wrong');
      expect(ex.toString(), 'something went wrong');
    });
  });

  group('NetworkException', () {
    test('should store the message and statusCode', () {
      final ex = NetworkException('Not found', statusCode: 404);
      expect(ex.message, 'Not found');
      expect(ex.statusCode, 404);
    });

    test('should default statusCode to null', () {
      final ex = NetworkException('Timeout');
      expect(ex.statusCode, isNull);
    });
  });

  group('AuthException', () {
    test('should store the message', () {
      final ex = AuthException('Unauthorized');
      expect(ex.message, 'Unauthorized');
    });
  });
}
