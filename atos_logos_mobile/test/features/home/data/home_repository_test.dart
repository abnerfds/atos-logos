import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/home/data/home_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late HomeRepository repository;

  setUp(() {
    dio = MockDio();
    repository = HomeRepository(dio: dio);
  });

  Response<dynamic> fakeResponse(dynamic data, {int statusCode = 200}) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  DioException dioFailure({
    int? statusCode,
    dynamic data,
  }) {
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

  group('HomeRepository - getMyChurch', () {
    test(
        'should return a parsed Church instance when /churches/me responds 200',
        () async {
      // Given — backend returns a church row
      when(() => dio.get('/churches/me')).thenAnswer(
        (_) async => fakeResponse({
          'id': 'c1',
          'name': 'Igreja Central',
          'activePlan': 'free',
        }),
      );

      // When
      final church = await repository.getMyChurch();

      // Then
      expect(church.id, 'c1');
      expect(church.name, 'Igreja Central');
      expect(church.activePlan, 'free');
    });

    test(
        'should throw NetworkException when the /churches/me request fails',
        () async {
      when(() => dio.get('/churches/me')).thenThrow(
        dioFailure(
          statusCode: 500,
          data: {'message': 'Boom'},
        ),
      );

      await expectLater(
        repository.getMyChurch(),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
        'should fall back to a generic PT-BR message when the failure has no body',
        () async {
      when(() => dio.get('/churches/me'))
          .thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.getMyChurch(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar dados da igreja',
          ),
        ),
      );
    });
  });

  group('HomeRepository - getBirthdays', () {
    test('should parse a BirthdaysResponse when the backend responds 200',
        () async {
      when(() => dio.get(
            '/member-profiles/birthdays',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'data': [
            {'id': 'm1', 'name': 'Ana', 'birthDate': '1995-04-12'},
          ],
          'month': 4,
        }),
      );

      final response = await repository.getBirthdays();

      expect(response.month, 4);
      expect(response.data, hasLength(1));
      expect(response.data.first.name, 'Ana');
    });

    test(
        'should forward the month query param when the caller specifies it',
        () async {
      when(() => dio.get(
            '/member-profiles/birthdays',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({'data': <dynamic>[], 'month': 7}),
      );

      await repository.getBirthdays(month: 7);

      verify(() => dio.get(
            '/member-profiles/birthdays',
            queryParameters: {'month': 7},
          )).called(1);
    });

    test('should throw NetworkException when the request fails', () async {
      when(() => dio.get(
            '/member-profiles/birthdays',
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        dioFailure(statusCode: 500, data: {'message': 'Oops'}),
      );

      await expectLater(
        repository.getBirthdays(),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
        'should fall back to a PT-BR message when the /member-profiles/birthdays failure has no body',
        () async {
      // Given — Dio raises without a response body (e.g., timeout, 503)
      when(() => dio.get(
            '/member-profiles/birthdays',
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(dioFailure(statusCode: 503));

      // Then — the user-facing message is PT-BR, matching getMyChurch
      await expectLater(
        repository.getBirthdays(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar aniversariantes',
          ),
        ),
      );
    });
  });

  group('HomeRepository - getUpcomingEvents', () {
    test(
        'should parse each event into a typed UpcomingEvent with branchName flattened from the nested branch',
        () async {
      when(() => dio.get(
            '/events',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({
          'data': [
            {
              'id': 'e1',
              'title': 'Culto de Domingo',
              'startsAt': '2026-04-12T19:30:00.000Z',
              'type': 'SERVICE',
              'branch': {'id': 'b1', 'name': 'Sede Central'},
            },
          ],
          'total': 1,
          'page': 1,
          'limit': 5,
        }),
      );

      final events = await repository.getUpcomingEvents();

      expect(events, hasLength(1));
      expect(events.first.id, 'e1');
      expect(events.first.title, 'Culto de Domingo');
      expect(events.first.branchName, 'Sede Central');
      expect(events.first.type, 'SERVICE');
      // ISO parsed into a real DateTime
      expect(events.first.startsAt.year, 2026);
      expect(events.first.startsAt.month, 4);
      expect(events.first.startsAt.day, 12);
    });

    test(
        'should forward upcoming=true and limit when the caller specifies a limit',
        () async {
      when(() => dio.get(
            '/events',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({'data': <dynamic>[]}),
      );

      await repository.getUpcomingEvents(limit: 10);

      verify(() => dio.get(
            '/events',
            queryParameters: {'upcoming': true, 'limit': 10},
          )).called(1);
    });

    test('should return an empty list when the backend has no upcoming events',
        () async {
      when(() => dio.get(
            '/events',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => fakeResponse({'data': <dynamic>[]}),
      );

      final events = await repository.getUpcomingEvents();

      expect(events, isEmpty);
    });

    test('should throw NetworkException when the request fails', () async {
      when(() => dio.get(
            '/events',
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        dioFailure(statusCode: 500, data: {'message': 'Oops'}),
      );

      await expectLater(
        repository.getUpcomingEvents(),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
        'should fall back to a PT-BR message when the /events failure has no body',
        () async {
      when(() => dio.get(
            '/events',
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(dioFailure(statusCode: 503));

      await expectLater(
        repository.getUpcomingEvents(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro ao carregar eventos',
          ),
        ),
      );
    });
  });
}
