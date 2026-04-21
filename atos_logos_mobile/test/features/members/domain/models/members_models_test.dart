import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/members/domain/models/member_profile.dart';
import 'package:atos_logos_mobile/features/members/domain/models/membership.dart';

void main() {
  group('Membership', () {
    test(
        'should deserialize the canonical JSON returned by /memberships into a Membership with a nested user and branch',
        () {
      final json = <String, dynamic>{
        'id': 'm1',
        'userId': 'u1',
        'churchId': 'c1',
        'branchId': 'b1',
        'role': 'MEMBER',
        'status': 'ACTIVE',
        'user': {
          'id': 'u1',
          'name': 'Ana Silva',
          'phone': '+5511999999999',
          'email': 'ana@example.com',
        },
        'branch': {'id': 'b1', 'name': 'Sede'},
      };

      final membership = Membership.fromJson(json);

      expect(membership.id, 'm1');
      expect(membership.role, 'MEMBER');
      expect(membership.status, 'ACTIVE');
      expect(membership.user.name, 'Ana Silva');
      expect(membership.branch.name, 'Sede');
    });

    test(
        'should keep user phone and email null when the backend omits them',
        () {
      final membership = Membership.fromJson(<String, dynamic>{
        'id': 'm1',
        'userId': 'u1',
        'churchId': 'c1',
        'branchId': 'b1',
        'role': 'MEMBER',
        'status': 'ACTIVE',
        'user': {'id': 'u1', 'name': 'Ana'},
        'branch': {'id': 'b1', 'name': 'Sede'},
      });

      expect(membership.user.phone, isNull);
      expect(membership.user.email, isNull);
    });
  });

  group('MembershipPage', () {
    test(
        'should deserialize the paginated wrapper with data + total + page + limit',
        () {
      final json = <String, dynamic>{
        'data': [
          {
            'id': 'm1',
            'userId': 'u1',
            'churchId': 'c1',
            'branchId': 'b1',
            'role': 'MEMBER',
            'status': 'ACTIVE',
            'user': {'id': 'u1', 'name': 'Ana'},
            'branch': {'id': 'b1', 'name': 'Sede'},
          },
        ],
        'total': 1,
        'page': 2,
        'limit': 20,
      };

      final page = MembershipPage.fromJson(json);

      expect(page.data, hasLength(1));
      expect(page.total, 1);
      expect(page.page, 2);
      expect(page.limit, 20);
    });
  });

  group('MemberProfile', () {
    test(
        'should deserialize a profile with a nested user + full address set',
        () {
      final json = <String, dynamic>{
        'id': 'p1',
        'userId': 'u1',
        'churchId': 'c1',
        'registrationNumber': '2026-BRAN-001',
        'birthDate': '1990-05-20',
        'admissionDate': '2020-03-15',
        'baptismDate': '2018-06-10',
        'photoUrl': 'https://cdn/photo.jpg',
        'user': {
          'id': 'u1',
          'name': 'Ana Silva',
          'email': 'ana@example.com',
          'phone': '+5511999999999',
          'cpf': '12345678900',
          'country': 'Brasil',
          'state': 'SP',
          'city': 'São Paulo',
          'neighborhood': 'Centro',
          'street': 'Rua X',
          'number': '42',
          'complement': 'Apto 3',
        },
      };

      final profile = MemberProfile.fromJson(json);

      expect(profile.id, 'p1');
      expect(profile.registrationNumber, '2026-BRAN-001');
      expect(profile.user?.name, 'Ana Silva');
      expect(profile.user?.city, 'São Paulo');
      expect(profile.user?.complement, 'Apto 3');
    });

    test(
        'should accept a profile with null top-level id (by-user endpoint returns this when no profile exists)',
        () {
      final json = <String, dynamic>{
        'id': null,
        'userId': 'u1',
        'churchId': 'c1',
        'registrationNumber': null,
        'birthDate': null,
        'baptismDate': null,
        'admissionDate': null,
        'photoUrl': null,
        'user': {'id': 'u1', 'name': 'Ana'},
      };

      final profile = MemberProfile.fromJson(json);

      expect(profile.id, isNull);
      expect(profile.registrationNumber, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.user?.name, 'Ana');
    });
  });
}
