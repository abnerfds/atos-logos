import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/members/data/members_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late MembersRepository repository;

  setUp(() {
    dio = MockDio();
    repository = MembersRepository(dio: dio);
  });

  Response<dynamic> fakeResponse(dynamic data, {int statusCode = 201}) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  DioException dioFailure({int? statusCode, dynamic data}) {
    return DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.badResponse,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: ''),
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('MembersRepository - getMemberships', () {
    test(
        'should GET /memberships with pagination params and forward q when provided',
        () async {
      when(() => dio.get(
            '/memberships',
            queryParameters: any<dynamic>(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'data': [],
          'total': 0,
          'page': 2,
          'limit': 50,
        }, statusCode: 200),
      );

      await repository.getMemberships(page: 2, limit: 50, q: 'Ana');

      verify(() => dio.get(
            '/memberships',
            queryParameters: {'page': 2, 'limit': 50, 'q': 'Ana'},
          )).called(1);
    });

    test(
        'should strip q from the query when the caller passes an empty/whitespace string',
        () async {
      when(() => dio.get(
            '/memberships',
            queryParameters: any<dynamic>(named: 'queryParameters'),
          )).thenAnswer(
        (_) async =>
            fakeResponse({'data': [], 'total': 0, 'page': 1, 'limit': 20}),
      );

      await repository.getMemberships(q: '   ');

      verify(() => dio.get(
            '/memberships',
            queryParameters: {'page': 1, 'limit': 20},
          )).called(1);
    });

    test('should throw NetworkException on failure with PT-BR fallback',
        () async {
      when(() => dio.get(
            '/memberships',
            queryParameters: any<dynamic>(named: 'queryParameters'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.getMemberships(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar membros',
          ),
        ),
      );
    });
  });

  group('MembersRepository - createMembership (legacy)', () {
    test(
        'should POST to /memberships and parse the response into a Membership',
        () async {
      when(() => dio.post(
            '/memberships',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'm1',
          'userId': 'u1',
          'churchId': 'c1',
          'branchId': 'b1',
          'role': 'MEMBER',
          'status': 'ACTIVE',
          'user': {'id': 'u1', 'name': 'Ana'},
          'branch': {'id': 'b1', 'name': 'Sede'},
        }),
      );

      final membership = await repository.createMembership(
        userId: 'u1',
        branchId: 'b1',
        role: 'MEMBER',
      );

      expect(membership.id, 'm1');
      expect(membership.user.name, 'Ana');
    });

    test('should omit role when the caller does not provide one', () async {
      when(() => dio.post(
            '/memberships',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'm1',
          'userId': 'u1',
          'churchId': 'c1',
          'branchId': 'b1',
          'role': 'MEMBER',
          'status': 'ACTIVE',
          'user': {'id': 'u1', 'name': 'Ana'},
          'branch': {'id': 'b1', 'name': 'Sede'},
        }),
      );

      await repository.createMembership(userId: 'u1', branchId: 'b1');

      verify(() => dio.post(
            '/memberships',
            data: {'userId': 'u1', 'branchId': 'b1'},
          )).called(1);
    });

    test('should throw NetworkException with PT-BR fallback on failure',
        () async {
      when(() => dio.post(
            '/memberships',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.createMembership(userId: 'u1', branchId: 'b1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao criar membro',
          ),
        ),
      );
    });
  });

  group('MembersRepository - getMemberProfile + createMemberProfile', () {
    test('should GET /member-profiles/:id and parse the response', () async {
      when(() => dio.get('/member-profiles/p1')).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'registrationNumber': '2026-BRAN-001',
        }),
      );

      final profile = await repository.getMemberProfile('p1');

      expect(profile.id, 'p1');
      expect(profile.registrationNumber, '2026-BRAN-001');
    });

    test('should surface a PT-BR fallback when /member-profiles/:id fails',
        () async {
      when(() => dio.get('/member-profiles/p1'))
          .thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.getMemberProfile('p1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar perfil',
          ),
        ),
      );
    });

    test(
        'should POST /member-profiles with the full payload when creating a profile',
        () async {
      when(() => dio.post(
            '/member-profiles',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'registrationNumber': '2026-BRAN-001',
          'birthDate': '1990-05-20',
          'admissionDate': '2020-03-15',
          'baptismDate': '2018-06-10',
          'photoUrl': 'https://cdn/photo.jpg',
        }),
      );

      final profile = await repository.createMemberProfile(
        userId: 'u1',
        branchId: 'b1',
        birthDate: '1990-05-20',
        admissionDate: '2020-03-15',
        baptismDate: '2018-06-10',
        photoUrl: 'https://cdn/photo.jpg',
      );

      expect(profile.id, 'p1');
      verify(() => dio.post(
            '/member-profiles',
            data: {
              'userId': 'u1',
              'branchId': 'b1',
              'birthDate': '1990-05-20',
              'admissionDate': '2020-03-15',
              'baptismDate': '2018-06-10',
              'photoUrl': 'https://cdn/photo.jpg',
            },
          )).called(1);
    });

    test(
        'should omit optional fields from the POST /member-profiles payload when absent',
        () async {
      when(() => dio.post(
            '/member-profiles',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'registrationNumber': '2026-BRAN-001',
          'birthDate': '1990-05-20',
          'admissionDate': '2020-03-15',
        }),
      );

      await repository.createMemberProfile(
        userId: 'u1',
        branchId: 'b1',
        birthDate: '1990-05-20',
        admissionDate: '2020-03-15',
      );

      verify(() => dio.post(
            '/member-profiles',
            data: {
              'userId': 'u1',
              'branchId': 'b1',
              'birthDate': '1990-05-20',
              'admissionDate': '2020-03-15',
            },
          )).called(1);
    });

    test(
        'should surface a PT-BR fallback when POST /member-profiles fails',
        () async {
      when(() => dio.post(
            '/member-profiles',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.createMemberProfile(
          userId: 'u1',
          branchId: 'b1',
          birthDate: '1990-05-20',
          admissionDate: '2020-03-15',
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao criar perfil',
          ),
        ),
      );
    });
  });

  group('MembersRepository - updateMemberProfile (date fields on edit)', () {
    test(
        'should PATCH /member-profiles/:id with every supplied date field so the secretary can actually edit birth/baptism/admission/consecration dates',
        () async {
      when(() => dio.patch(
            '/member-profiles/p1',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'registrationNumber': '2026-BRAN-001',
          'birthDate': '1985-01-10',
          'admissionDate': '2019-07-15',
          'baptismDate': '2000-12-20',
          'consecrationDate': '2022-11-30',
        }),
      );

      final profile = await repository.updateMemberProfile(
        profileId: 'p1',
        birthDate: '1985-01-10',
        admissionDate: '2019-07-15',
        baptismDate: '2000-12-20',
        consecrationDate: '2022-11-30',
      );

      expect(profile.id, 'p1');
      verify(() => dio.patch(
            '/member-profiles/p1',
            data: {
              'birthDate': '1985-01-10',
              'baptismDate': '2000-12-20',
              'admissionDate': '2019-07-15',
              'consecrationDate': '2022-11-30',
            },
          )).called(1);
    });

    test(
        'should omit null / empty-string dates from the payload so the backend does not blank unchanged columns',
        () async {
      when(() => dio.patch(
            '/member-profiles/p1',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'registrationNumber': '2026-BRAN-001',
        }),
      );

      await repository.updateMemberProfile(
        profileId: 'p1',
        birthDate: null,
        admissionDate: '',
        baptismDate: '2000-12-20',
        // consecrationDate intentionally omitted
      );

      final captured = verify(() => dio.patch(
            '/member-profiles/p1',
            data: captureAny<dynamic>(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured.keys.toSet(), {'baptismDate'});
      expect(captured['baptismDate'], '2000-12-20');
    });

    test(
        'should surface the backend validation message (list → joined) via parseBackendErrorMessage',
        () async {
      when(() => dio.patch(
            '/member-profiles/p1',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(
        statusCode: 400,
        data: {'message': ['birthDate must be a valid ISO date string']},
      ));

      await expectLater(
        repository.updateMemberProfile(
          profileId: 'p1',
          birthDate: 'garbage',
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'birthDate must be a valid ISO date string',
          ),
        ),
      );
    });

    test(
        'should surface a PT-BR fallback when the backend does not send a message',
        () async {
      when(() => dio.patch(
            '/member-profiles/p1',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.updateMemberProfile(profileId: 'p1', birthDate: '1990-01-01'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao atualizar perfil',
          ),
        ),
      );
    });
  });

  group('MembersRepository - createMemberWithUser', () {
    test(
        'should POST the full secretariat payload to /memberships/with-user',
        () async {
      // Given — the backend accepts the payload
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'user': {'id': 'u1', 'name': 'Ana'},
          'membership': {'id': 'm1'},
          'profile': null,
        }),
      );

      // When
      await repository.createMemberWithUser(
        name: 'Ana Silva',
        password: 'tmp-123456',
        branchId: 'b1',
        email: 'ana@example.com',
        cpf: '12345678900',
        phone: '+5511999999999',
        role: 'MEMBER',
        birthDate: '1990-05-20',
        baptismDate: '2018-06-10',
        admissionDate: '2020-03-15',
      );

      // Then — every field forwarded (no server-side defaults to hide bugs)
      verify(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: {
              'name': 'Ana Silva',
              'password': 'tmp-123456',
              'branchId': 'b1',
              'email': 'ana@example.com',
              'cpf': '12345678900',
              'phone': '+5511999999999',
              'role': 'MEMBER',
              'birthDate': '1990-05-20',
              'baptismDate': '2018-06-10',
              'admissionDate': '2020-03-15',
            },
          )).called(1);
    });

    test(
        'should omit optional fields from the payload when the caller does not provide them',
        () async {
      // Given — minimal valid payload (name + password + branchId only)
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer((_) async => fakeResponse({'user': {}, 'membership': {}}));

      // When
      await repository.createMemberWithUser(
        name: 'Joao',
        password: 'tmp-123456',
        branchId: 'b1',
      );

      // Then — nulls are stripped, NOT sent as JSON nulls (backend DTO is
      // @IsOptional — sending null would fail @IsEmail etc.)
      final captured = verify(
        () => dio.post<dynamic>(
          '/memberships/with-user',
          data: captureAny<dynamic>(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured, equals({
        'name': 'Joao',
        'password': 'tmp-123456',
        'branchId': 'b1',
      }));
    });

    test(
        'should throw NetworkException when the backend returns an error with a body message',
        () async {
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(
        dioFailure(
          statusCode: 400,
          data: {'message': 'A user with this email already exists'},
        ),
      );

      await expectLater(
        repository.createMemberWithUser(
          name: 'Ana',
          password: 'tmp-123456',
          branchId: 'b1',
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'A user with this email already exists',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the failure has no body',
        () async {
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.createMemberWithUser(
          name: 'Ana',
          password: 'tmp-123456',
          branchId: 'b1',
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao criar membro',
          ),
        ),
      );
    });
  });

  group('MembersRepository - updateMemberUserData', () {
    test(
        'should PATCH /memberships/by-user/:userId/user-data and strip empty optionals from the payload',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({'id': 'u1', 'name': 'Ana'}, statusCode: 200),
      );

      await repository.updateMemberUserData(
        userId: 'u1',
        name: 'Ana',
        email: '',
        phone: '+5511999999999',
      );

      verify(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: {
              'name': 'Ana',
              'phone': '+5511999999999',
            },
          )).called(1);
    });

    test(
        'should surface the backend message verbatim on a 400 so the UI shows which field collided',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(
        dioFailure(
          statusCode: 400,
          data: {
            'message': 'A user with this email, phone or cpf already exists',
          },
        ),
      );

      await expectLater(
        repository.updateMemberUserData(userId: 'u1', email: 'taken@example.com'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'A user with this email, phone or cpf already exists',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the failure has no body',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.updateMemberUserData(userId: 'u1', name: 'Ana'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao atualizar dados do membro',
          ),
        ),
      );
    });
  });

  group('MembersRepository - identity & consecration fields', () {
    test(
        'createMemberWithUser should forward rg/sex/civilStatus/fatherName/motherName/consecrationDate to the request body',
        () async {
      // Given — every new identity + consecration field provided
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({'user': {}, 'membership': {}}),
      );

      // When
      await repository.createMemberWithUser(
        name: 'Ana Silva',
        password: 'tmp-123456',
        branchId: 'b1',
        rg: 'MG-12.345.678',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'João Silva',
        motherName: 'Maria Silva',
        consecrationDate: '2022-11-01',
      );

      // Then — every new field present in the body
      final captured = verify(
        () => dio.post<dynamic>(
          '/memberships/with-user',
          data: captureAny<dynamic>(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured['rg'], 'MG-12.345.678');
      expect(captured['sex'], 'FEMALE');
      expect(captured['civilStatus'], 'MARRIED');
      expect(captured['fatherName'], 'João Silva');
      expect(captured['motherName'], 'Maria Silva');
      expect(captured['consecrationDate'], '2022-11-01');
    });

    test(
        'createMemberWithUser should strip null/empty identity & consecration fields from the body',
        () async {
      // Given — caller leaves new fields null OR empty (mixed)
      when(() => dio.post<dynamic>(
            '/memberships/with-user',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({'user': {}, 'membership': {}}),
      );

      // When
      await repository.createMemberWithUser(
        name: 'Ana',
        password: 'tmp-123456',
        branchId: 'b1',
        rg: '',
        sex: null,
        civilStatus: '',
        fatherName: null,
        motherName: '',
        consecrationDate: null,
      );

      // Then — none of the new keys are present in the body
      final captured = verify(
        () => dio.post<dynamic>(
          '/memberships/with-user',
          data: captureAny<dynamic>(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured.containsKey('rg'), isFalse);
      expect(captured.containsKey('sex'), isFalse);
      expect(captured.containsKey('civilStatus'), isFalse);
      expect(captured.containsKey('fatherName'), isFalse);
      expect(captured.containsKey('motherName'), isFalse);
      expect(captured.containsKey('consecrationDate'), isFalse);
    });

    test(
        'updateMemberUserData should forward rg/sex/civilStatus/fatherName/motherName to the PATCH body',
        () async {
      // Given
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({'id': 'u1'}, statusCode: 200),
      );

      // When
      await repository.updateMemberUserData(
        userId: 'u1',
        rg: 'MG-12.345.678',
        sex: 'MALE',
        civilStatus: 'SINGLE',
        fatherName: 'José',
        motherName: 'Maria',
      );

      // Then
      final captured = verify(
        () => dio.patch<dynamic>(
          '/memberships/by-user/u1/user-data',
          data: captureAny<dynamic>(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured['rg'], 'MG-12.345.678');
      expect(captured['sex'], 'MALE');
      expect(captured['civilStatus'], 'SINGLE');
      expect(captured['fatherName'], 'José');
      expect(captured['motherName'], 'Maria');
    });

    test(
        'updateMemberUserData should strip null/empty identity fields from the PATCH body',
        () async {
      // Given
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({'id': 'u1'}, statusCode: 200),
      );

      // When — only name provided; identity fields are null/empty
      await repository.updateMemberUserData(
        userId: 'u1',
        name: 'Ana',
        rg: '',
        sex: null,
        civilStatus: '',
        fatherName: null,
        motherName: '',
      );

      // Then — body only carries name
      verify(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/user-data',
            data: {'name': 'Ana'},
          )).called(1);
    });

    test(
        'createMemberProfile should include consecrationDate in the body when provided',
        () async {
      // Given
      when(() => dio.post(
            '/member-profiles',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'birthDate': '1990-05-20',
          'admissionDate': '2020-03-15',
          'consecrationDate': '2022-11-01',
        }),
      );

      // When
      await repository.createMemberProfile(
        userId: 'u1',
        branchId: 'b1',
        birthDate: '1990-05-20',
        admissionDate: '2020-03-15',
        consecrationDate: '2022-11-01',
      );

      // Then
      verify(() => dio.post(
            '/member-profiles',
            data: {
              'userId': 'u1',
              'branchId': 'b1',
              'birthDate': '1990-05-20',
              'admissionDate': '2020-03-15',
              'consecrationDate': '2022-11-01',
            },
          )).called(1);
    });

    test(
        'createMemberProfile should omit consecrationDate from the body when not provided',
        () async {
      // Given
      when(() => dio.post(
            '/member-profiles',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'p1',
          'userId': 'u1',
          'churchId': 'c1',
          'birthDate': '1990-05-20',
          'admissionDate': '2020-03-15',
        }),
      );

      // When — caller does not pass consecrationDate
      await repository.createMemberProfile(
        userId: 'u1',
        branchId: 'b1',
        birthDate: '1990-05-20',
        admissionDate: '2020-03-15',
      );

      // Then — key is absent (consistent with baptismDate/photoUrl pattern)
      final captured = verify(
        () => dio.post(
          '/member-profiles',
          data: captureAny<dynamic>(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured.containsKey('consecrationDate'), isFalse);
    });
  });

  group('MembersRepository - inactivateMemberByUserId', () {
    test(
        'should PATCH /memberships/by-user/:userId/inactivate with an empty body',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/inactivate',
          )).thenAnswer(
        (_) async => fakeResponse({'id': 'm1', 'status': 'INACTIVE'}, statusCode: 200),
      );

      await repository.inactivateMemberByUserId('u1');

      verify(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/inactivate',
          )).called(1);
    });

    test(
        'should propagate the backend message when the Last-Admin guard rejects the inactivation',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/inactivate',
          )).thenThrow(
        dioFailure(
          statusCode: 403,
          data: {
            'message': 'Cannot remove or demote the last admin of this church',
          },
        ),
      );

      await expectLater(
        repository.inactivateMemberByUserId('u1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Cannot remove or demote the last admin of this church',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the failure has no body',
        () async {
      when(() => dio.patch<dynamic>(
            '/memberships/by-user/u1/inactivate',
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.inactivateMemberByUserId('u1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao inativar membro',
          ),
        ),
      );
    });
  });
}
