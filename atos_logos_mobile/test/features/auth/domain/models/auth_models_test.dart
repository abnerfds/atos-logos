import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/auth/domain/models/auth_response.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/church_option.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/login_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/select_church_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/signup_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';

void main() {
  group('LoginRequest', () {
    test(
        'should deserialize a JSON payload containing email and password into a LoginRequest',
        () {
      // Given — a canonical JSON payload the backend accepts
      final json = <String, dynamic>{
        'email': 'admin@church.com',
        'password': 'password123',
      };

      // When — fromJson is invoked
      final req = LoginRequest.fromJson(json);

      // Then — the fields round-trip verbatim
      expect(req.email, 'admin@church.com');
      expect(req.password, 'password123');
    });

    test('should serialize a LoginRequest back to the same JSON shape', () {
      // Given — a LoginRequest instance
      const req = LoginRequest(email: 'a@b.com', password: 'pwd123');

      // When — toJson is invoked
      final json = req.toJson();

      // Then — the JSON has the expected keys
      expect(json, {'email': 'a@b.com', 'password': 'pwd123'});
    });
  });

  group('SignupRequest', () {
    test(
        'should deserialize a JSON payload into a SignupRequest with every required field',
        () {
      // Given — the canonical signup payload (no `phone` — admins set
      // phone later via the profile-edit screen)
      final json = <String, dynamic>{
        'name': 'Pastor John',
        'email': 'pastor@church.com',
        'password': 'password123',
        'churchName': 'Grace Church',
      };

      // When
      final req = SignupRequest.fromJson(json);

      // Then
      expect(req.name, 'Pastor John');
      expect(req.email, 'pastor@church.com');
      expect(req.password, 'password123');
      expect(req.churchName, 'Grace Church');
    });

    test('should serialize a SignupRequest back to the same JSON shape', () {
      // Given
      const req = SignupRequest(
        name: 'Pastor',
        email: 'a@b.com',
        password: 'pwd123',
        churchName: 'C',
      );

      // When
      final json = req.toJson();

      // Then — exactly the four expected keys, no `phone` ghost field
      expect(json, {
        'name': 'Pastor',
        'email': 'a@b.com',
        'password': 'pwd123',
        'churchName': 'C',
      });
    });
  });

  group('SelectChurchRequest', () {
    test(
        'should deserialize a JSON payload containing selectionToken and churchId',
        () {
      // Given — a canonical JSON payload
      final json = <String, dynamic>{
        'selectionToken': 'sel-tkn',
        'churchId': 'c1-uuid',
      };

      // When
      final req = SelectChurchRequest.fromJson(json);

      // Then
      expect(req.selectionToken, 'sel-tkn');
      expect(req.churchId, 'c1-uuid');
    });

    test('should serialize a SelectChurchRequest back to JSON', () {
      // Given
      const req =
          SelectChurchRequest(selectionToken: 'sel-tkn', churchId: 'c1-uuid');

      // When
      final json = req.toJson();

      // Then
      expect(json, {'selectionToken': 'sel-tkn', 'churchId': 'c1-uuid'});
    });
  });

  group('AuthResponse', () {
    test(
        'should deserialize a JSON payload containing access_token and refresh_token',
        () {
      // Given
      final json = <String, dynamic>{
        'access_token': 'acc-tkn',
        'refresh_token': 'rfr-tkn',
      };

      // When
      final res = AuthResponse.fromJson(json);

      // Then
      expect(res.accessToken, 'acc-tkn');
      expect(res.refreshToken, 'rfr-tkn');
    });
  });

  group('ChurchOption', () {
    test(
        'should deserialize a JSON payload into a ChurchOption with all fields populated',
        () {
      // Given
      final json = <String, dynamic>{
        'id': 'c1',
        'name': 'Grace Church',
        'branchName': 'Headquarters',
        'role': 'ADMIN',
      };

      // When
      final option = ChurchOption.fromJson(json);

      // Then
      expect(option.id, 'c1');
      expect(option.name, 'Grace Church');
      expect(option.branchName, 'Headquarters');
      expect(option.role, 'ADMIN');
    });
  });

  group('UserProfile', () {
    test(
        'should deserialize a full profile JSON including the nested profile detail and positions',
        () {
      // Given — a payload shaped like /auth/me with all optional nested fields
      final json = <String, dynamic>{
        'user': {
          'id': 'u1',
          'name': 'Ana',
          'email': 'ana@test.com',
          'phone': '11999999999',
          'cpf': '12345678900',
          'country': 'Brasil',
          'state': 'SP',
          'city': 'Sao Paulo',
          'neighborhood': 'Jardins',
          'street': 'Rua X',
          'number': '123',
          'complement': 'Apto 4',
        },
        'profile': {
          'photoUrl': 'https://cdn/ana.jpg',
          'admissionDate': '2020-03-15',
          'birthDate': '1990-05-20',
          'registrationNumber': '2020-ABCD-001',
        },
        'membership': {'role': 'ADMIN', 'status': 'ACTIVE'},
        'positions': [
          {'id': 'pos-1', 'name': 'Pastor'},
          {'id': 'pos-2', 'name': 'Ensino'},
        ],
        'church': {'id': 'c1', 'name': 'Igreja Central'},
        'branch': {'id': 'b1', 'name': 'Sede'},
      };

      // When
      final profile = UserProfile.fromJson(json);

      // Then — top-level
      expect(profile.user.name, 'Ana');
      expect(profile.user.email, 'ana@test.com');
      expect(profile.church.name, 'Igreja Central');
      expect(profile.branch.name, 'Sede');

      // Then — nested UserProfileDetail (exercises fromJson lines 51-52)
      expect(profile.profile, isNotNull);
      expect(profile.profile!.photoUrl, 'https://cdn/ana.jpg');
      expect(profile.profile!.registrationNumber, '2020-ABCD-001');

      // Then — nested UserProfilePosition (exercises fromJson lines 73-74)
      expect(profile.positions, hasLength(2));
      expect(profile.positions.first.id, 'pos-1');
      expect(profile.positions.first.name, 'Pastor');
      expect(profile.positions.last.name, 'Ensino');
    });

    test(
        'should deserialize a minimal profile JSON when profile detail is null and positions is empty',
        () {
      // Given — a member without any MemberProfile row and no positions
      final json = <String, dynamic>{
        'user': {'id': 'u2', 'name': 'Joao', 'email': 'j@x.com'},
        'profile': null,
        'membership': {'role': 'MEMBER', 'status': 'ACTIVE'},
        'positions': <dynamic>[],
        'church': {'id': 'c1', 'name': 'Igreja'},
        'branch': {'id': 'b1', 'name': 'Sede'},
      };

      // When
      final profile = UserProfile.fromJson(json);

      // Then
      expect(profile.profile, isNull);
      expect(profile.positions, isEmpty);
    });
  });
}
