import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/branches/data/branches_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late BranchesRepository repository;

  setUp(() {
    dio = MockDio();
    repository = BranchesRepository(dio: dio);
  });

  Response<dynamic> fakeResponse(dynamic data, {int statusCode = 200}) {
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

  group('BranchesRepository - getBranches', () {
    test(
        'should GET /branches and parse each entry into a typed Branch with nested _count flattened',
        () async {
      // Given — canonical shape from backend: isHeadquarters flag,
      // address fields, and `_count.memberships` for list ordering UX.
      when(() => dio.get('/branches')).thenAnswer(
        (_) async => fakeResponse([
          {
            'id': 'b1',
            'name': 'Sede Central',
            'isHeadquarters': true,
            'country': 'Brasil',
            'state': 'SP',
            'city': 'São Paulo',
            '_count': {'memberships': 42},
          },
          {
            'id': 'b2',
            'name': 'Filial Norte',
            'isHeadquarters': false,
          },
        ]),
      );

      // When
      final branches = await repository.getBranches();

      // Then
      expect(branches, hasLength(2));
      expect(branches.first.id, 'b1');
      expect(branches.first.isHeadquarters, isTrue);
      expect(branches.first.city, 'São Paulo');
      expect(branches.first.count?.memberships, 42);
      expect(branches.last.isHeadquarters, isFalse);
      expect(branches.last.count, isNull);
    });

    test(
        'should return an empty list when the backend has no branches yet',
        () async {
      when(() => dio.get('/branches'))
          .thenAnswer((_) async => fakeResponse(<dynamic>[]));

      final branches = await repository.getBranches();

      expect(branches, isEmpty);
    });

    test(
        'should surface the server message when /branches fails with a body',
        () async {
      when(() => dio.get('/branches')).thenThrow(
        dioFailure(statusCode: 500, data: {'message': 'Boom'}),
      );

      await expectLater(
        repository.getBranches(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Boom',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when /branches fails without a body',
        () async {
      when(() => dio.get('/branches'))
          .thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.getBranches(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar congregações',
          ),
        ),
      );
    });
  });

  group('BranchesRepository - getBranches with search', () {
    test(
        'should forward the q query parameter to GET /branches when provided',
        () async {
      when(() => dio.get(
            '/branches',
            queryParameters: any<dynamic>(named: 'queryParameters'),
          )).thenAnswer((_) async => fakeResponse(<dynamic>[]));

      await repository.getBranches(q: 'Sede');

      verify(() => dio.get(
            '/branches',
            queryParameters: {'q': 'Sede'},
          )).called(1);
    });

    test(
        'should omit queryParameters entirely when q is whitespace-only',
        () async {
      when(() => dio.get('/branches', queryParameters: null))
          .thenAnswer((_) async => fakeResponse(<dynamic>[]));

      await repository.getBranches(q: '   ');

      verify(() => dio.get('/branches', queryParameters: null)).called(1);
    });
  });

  group('BranchesRepository - updateBranch', () {
    test(
        'should PATCH every optional address column when the full edit payload is provided',
        () async {
      when(() => dio.patch(
            '/branches/b1',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'b1',
          'name': 'Filial',
          'isHeadquarters': false,
        }),
      );

      await repository.updateBranch(
        id: 'b1',
        name: 'Filial',
        country: 'Brasil',
        state: 'SP',
        city: 'São Paulo',
        neighborhood: 'Centro',
        street: 'Rua X',
        number: '42',
      );

      verify(() => dio.patch(
            '/branches/b1',
            data: {
              'name': 'Filial',
              'country': 'Brasil',
              'state': 'SP',
              'city': 'São Paulo',
              'neighborhood': 'Centro',
              'street': 'Rua X',
              'number': '42',
            },
          )).called(1);
    });

    test(
        'should PATCH /branches/:id with every field provided and parse the response',
        () async {
      when(() => dio.patch(
            '/branches/b1',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'b1',
          'name': 'Filial Renomeada',
          'isHeadquarters': false,
          'city': 'Nova Cidade',
        }),
      );

      final branch = await repository.updateBranch(
        id: 'b1',
        name: 'Filial Renomeada',
        city: 'Nova Cidade',
      );

      expect(branch.name, 'Filial Renomeada');
      verify(() => dio.patch(
            '/branches/b1',
            data: {'name': 'Filial Renomeada', 'city': 'Nova Cidade'},
          )).called(1);
    });

    test(
        'should surface the server message when the PATCH fails with a body',
        () async {
      when(() => dio.patch(
            '/branches/b1',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(
        dioFailure(statusCode: 404, data: {'message': 'Branch not found'}),
      );

      await expectLater(
        repository.updateBranch(id: 'b1', name: 'X'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Branch not found',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when PATCH fails without a body',
        () async {
      when(() => dio.patch(
            '/branches/b1',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.updateBranch(id: 'b1', name: 'X'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao atualizar congregação',
          ),
        ),
      );
    });
  });

  group('BranchesRepository - promoteToHeadquarters', () {
    test(
        'should PATCH /branches/:id/promote-to-headquarters and return the promoted Branch',
        () async {
      when(() => dio.patch('/branches/b2/promote-to-headquarters'))
          .thenAnswer(
        (_) async => fakeResponse({
          'id': 'b2',
          'name': 'Nova Sede',
          'isHeadquarters': true,
        }),
      );

      final branch = await repository.promoteToHeadquarters('b2');

      expect(branch.id, 'b2');
      expect(branch.isHeadquarters, isTrue);
      verify(() => dio.patch('/branches/b2/promote-to-headquarters'))
          .called(1);
    });

    test(
        'should surface the backend 409 message when the branch is already HQ',
        () async {
      when(() => dio.patch('/branches/b1/promote-to-headquarters')).thenThrow(
        dioFailure(
          statusCode: 409,
          data: {'message': 'Branch is already the headquarters'},
        ),
      );

      await expectLater(
        repository.promoteToHeadquarters('b1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Branch is already the headquarters',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the PATCH fails without a body',
        () async {
      when(() => dio.patch('/branches/b2/promote-to-headquarters'))
          .thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.promoteToHeadquarters('b2'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao promover congregação',
          ),
        ),
      );
    });
  });

  group('BranchesRepository - deleteBranch', () {
    test('should DELETE /branches/:id', () async {
      when(() => dio.delete('/branches/b1'))
          .thenAnswer((_) async => fakeResponse(null, statusCode: 204));

      await repository.deleteBranch('b1');

      verify(() => dio.delete('/branches/b1')).called(1);
    });

    test(
        'should propagate the backend message when the HQ guard blocks the delete',
        () async {
      when(() => dio.delete('/branches/b1')).thenThrow(
        dioFailure(
          statusCode: 403,
          data: {'message': 'Cannot delete the headquarters branch'},
        ),
      );

      await expectLater(
        repository.deleteBranch('b1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Cannot delete the headquarters branch',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the DELETE fails without a body',
        () async {
      when(() => dio.delete('/branches/b1'))
          .thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.deleteBranch('b1'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao remover congregação',
          ),
        ),
      );
    });
  });

  group('BranchesRepository - createBranch', () {
    test(
        'should POST to /branches with every field that was provided and parse the response',
        () async {
      when(() => dio.post(
            '/branches',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse(
          {
            'id': 'b2',
            'name': 'Filial Norte',
            'isHeadquarters': false,
            'country': 'Brasil',
            'state': 'SP',
            'city': 'São Paulo',
            'neighborhood': 'Centro',
            'street': 'Rua X',
            'number': '42',
          },
          statusCode: 201,
        ),
      );

      final branch = await repository.createBranch(
        name: 'Filial Norte',
        country: 'Brasil',
        state: 'SP',
        city: 'São Paulo',
        neighborhood: 'Centro',
        street: 'Rua X',
        number: '42',
      );

      expect(branch.id, 'b2');
      expect(branch.name, 'Filial Norte');
      verify(() => dio.post(
            '/branches',
            data: {
              'name': 'Filial Norte',
              'country': 'Brasil',
              'state': 'SP',
              'city': 'São Paulo',
              'neighborhood': 'Centro',
              'street': 'Rua X',
              'number': '42',
            },
          )).called(1);
    });

    test(
        'should omit optional address fields from the POST body when the caller did not provide them',
        () async {
      when(() => dio.post(
            '/branches',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'id': 'b3',
          'name': 'Simples',
          'isHeadquarters': false,
        }),
      );

      await repository.createBranch(name: 'Simples');

      verify(() => dio.post(
            '/branches',
            data: {'name': 'Simples'},
          )).called(1);
    });

    test(
        'should surface the server message when the /branches POST fails with a body',
        () async {
      when(() => dio.post(
            '/branches',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(
        dioFailure(
          statusCode: 403,
          data: {'message': 'Forbidden'},
        ),
      );

      await expectLater(
        repository.createBranch(name: 'Filial'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Forbidden',
          ),
        ),
      );
    });

    test(
        'should fall back to a PT-BR message when the POST fails without a body',
        () async {
      when(() => dio.post(
            '/branches',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.createBranch(name: 'Filial'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao criar congregação',
          ),
        ),
      );
    });
  });
}
