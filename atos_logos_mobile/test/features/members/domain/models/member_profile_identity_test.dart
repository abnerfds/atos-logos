import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';

void main() {
  group('MemberProfileUser - identity fields', () {
    test(
        'should round-trip the 5 new identity fields (rg, sex, civilStatus, fatherName, motherName) through fromJson/toJson',
        () {
      // Given — a /member-profiles payload with the nested user populated
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
      };

      // When
      final user = MemberProfileUser.fromJson(json);
      final reJson = user.toJson();

      // Then — fields preserved with their wire values
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
      // Given — minimal user payload (only id + name required)
      final json = <String, dynamic>{
        'id': 'u1',
        'name': 'Ana',
      };

      // When
      final user = MemberProfileUser.fromJson(json);

      // Then
      expect(user.rg, isNull);
      expect(user.sex, isNull);
      expect(user.civilStatus, isNull);
      expect(user.fatherName, isNull);
      expect(user.motherName, isNull);
    });
  });

  group('MemberProfile - consecrationDate', () {
    test('should round-trip consecrationDate through fromJson/toJson', () {
      // Given — a /member-profiles payload with the new consecrationDate
      final json = <String, dynamic>{
        'id': 'p1',
        'userId': 'u1',
        'churchId': 'c1',
        'registrationNumber': '2026-BRAN-001',
        'birthDate': '1990-05-20',
        'admissionDate': '2020-03-15',
        'baptismDate': '2018-06-10',
        'consecrationDate': '2022-11-01',
        'photoUrl': 'https://cdn/photo.jpg',
      };

      // When
      final profile = MemberProfile.fromJson(json);
      final reJson = profile.toJson();

      // Then
      expect(profile.consecrationDate, '2022-11-01');
      expect(reJson['consecrationDate'], '2022-11-01');
    });

    test(
        'should keep consecrationDate null when the backend omits it (optional)',
        () {
      // Given — a profile payload without consecrationDate
      final json = <String, dynamic>{
        'userId': 'u1',
        'churchId': 'c1',
      };

      // When
      final profile = MemberProfile.fromJson(json);

      // Then
      expect(profile.consecrationDate, isNull);
    });
  });
}
