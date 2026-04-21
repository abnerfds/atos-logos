import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

void main() {
  group('UserProfileUser - identity fields', () {
    test(
        'should round-trip the new identity fields (rg, sex, civilStatus, fatherName, motherName) through fromJson/toJson',
        () {
      // Given — a /me-style payload that carries every identity field
      final json = <String, dynamic>{
        'id': 'u1',
        'name': 'Ana Silva',
        'email': 'ana@example.com',
        'phone': '+5511999999999',
        'cpf': '12345678900',
        'rg': 'MG-12.345.678',
        'sex': 'FEMALE',
        'civilStatus': 'MARRIED',
        'fatherName': 'João Silva',
        'motherName': 'Maria Silva',
        'country': 'Brasil',
        'state': 'MG',
        'city': 'Belo Horizonte',
        'neighborhood': 'Centro',
        'street': 'Rua A',
        'number': '100',
        'complement': 'Apto 1',
      };

      // When — parse + re-serialize
      final user = UserProfileUser.fromJson(json);
      final reJson = user.toJson();

      // Then — every identity field survives the round-trip with wire values
      expect(user.rg, 'MG-12.345.678');
      expect(user.sex, 'FEMALE');
      expect(user.civilStatus, 'MARRIED');
      expect(user.fatherName, 'João Silva');
      expect(user.motherName, 'Maria Silva');
      expect(reJson['rg'], 'MG-12.345.678');
      expect(reJson['sex'], 'FEMALE');
      expect(reJson['civilStatus'], 'MARRIED');
      expect(reJson['fatherName'], 'João Silva');
      expect(reJson['motherName'], 'Maria Silva');
    });

    test(
        'should keep identity fields null when the backend omits them (all optional)',
        () {
      // Given — a minimal /me payload (only required fields)
      final json = <String, dynamic>{
        'id': 'u1',
        'name': 'Ana',
        'email': 'ana@example.com',
      };

      // When
      final user = UserProfileUser.fromJson(json);

      // Then — every new identity field is null, not crashing the parser
      expect(user.rg, isNull);
      expect(user.sex, isNull);
      expect(user.civilStatus, isNull);
      expect(user.fatherName, isNull);
      expect(user.motherName, isNull);
    });
  });

  group('UserProfileDetail - consecrationDate', () {
    test('should round-trip consecrationDate through fromJson/toJson', () {
      // Given — a profile payload that includes the new consecrationDate
      final json = <String, dynamic>{
        'photoUrl': 'https://cdn/photo.jpg',
        'admissionDate': '2020-03-15',
        'birthDate': '1990-05-20',
        'baptismDate': '2018-06-10',
        'consecrationDate': '2022-11-01',
        'registrationNumber': '2026-BRAN-001',
      };

      // When
      final detail = UserProfileDetail.fromJson(json);
      final reJson = detail.toJson();

      // Then
      expect(detail.consecrationDate, '2022-11-01');
      expect(reJson['consecrationDate'], '2022-11-01');
    });

    test(
        'should keep consecrationDate null when the backend omits it (optional)',
        () {
      // Given — a profile payload without consecrationDate
      final json = <String, dynamic>{
        'birthDate': '1990-05-20',
        'admissionDate': '2020-03-15',
      };

      // When
      final detail = UserProfileDetail.fromJson(json);

      // Then
      expect(detail.consecrationDate, isNull);
    });
  });
}
