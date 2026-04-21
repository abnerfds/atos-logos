import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/upcoming_event.dart';

void main() {
  group('Church', () {
    test(
        'should deserialize a JSON payload containing id, name and activePlan into a Church',
        () {
      // Given — the canonical church shape returned by /churches/me
      final json = <String, dynamic>{
        'id': 'c1',
        'name': 'Igreja Central',
        'activePlan': 'free',
      };

      // When
      final church = Church.fromJson(json);

      // Then
      expect(church.id, 'c1');
      expect(church.name, 'Igreja Central');
      expect(church.activePlan, 'free');
    });

    test('should accept an optional documentNumber (CNPJ) when present', () {
      final json = <String, dynamic>{
        'id': 'c1',
        'name': 'Igreja',
        'activePlan': 'free',
        'documentNumber': '12.345.678/0001-90',
      };

      final church = Church.fromJson(json);

      expect(church.documentNumber, '12.345.678/0001-90');
    });
  });

  group('BirthdayMember', () {
    test(
        'should deserialize a JSON payload containing id, name and birthDate',
        () {
      final json = <String, dynamic>{
        'id': 'm1',
        'name': 'Ana',
        'birthDate': '1995-04-12',
      };

      final member = BirthdayMember.fromJson(json);

      expect(member.id, 'm1');
      expect(member.name, 'Ana');
      expect(member.birthDate, '1995-04-12');
    });

    test('should deserialize an optional photoUrl when present', () {
      final json = <String, dynamic>{
        'id': 'm1',
        'name': 'Ana',
        'birthDate': '1995-04-12',
        'photoUrl': 'https://cdn/ana.jpg',
      };

      final member = BirthdayMember.fromJson(json);

      expect(member.photoUrl, 'https://cdn/ana.jpg');
    });
  });

  group('BirthdaysResponse', () {
    test(
        'should deserialize the month + data wrapper returned by /member-profiles/birthdays',
        () {
      final json = <String, dynamic>{
        'data': [
          {'id': 'm1', 'name': 'Ana', 'birthDate': '1995-04-12'},
          {'id': 'm2', 'name': 'Carlos', 'birthDate': '1988-04-25'},
        ],
        'month': 4,
      };

      final response = BirthdaysResponse.fromJson(json);

      expect(response.month, 4);
      expect(response.data, hasLength(2));
      expect(response.data.first.name, 'Ana');
      expect(response.data.last.name, 'Carlos');
    });
  });

  group('UpcomingEvent', () {
    test(
        'should flatten the nested branch.name into branchName and parse startsAt into a DateTime',
        () {
      // Given — the exact shape returned by `GET /events`, with a nested
      // `branch` object (id + name) that we want to flatten.
      final json = <String, dynamic>{
        'id': 'e1',
        'title': 'Culto de Domingo',
        'startsAt': '2026-04-12T19:30:00.000Z',
        'type': 'SERVICE',
        'branch': {'id': 'b1', 'name': 'Sede Central'},
      };

      // When
      final event = UpcomingEvent.fromJson(json);

      // Then
      expect(event.id, 'e1');
      expect(event.title, 'Culto de Domingo');
      expect(event.startsAt, DateTime.parse('2026-04-12T19:30:00.000Z'));
      expect(event.branchName, 'Sede Central');
      expect(event.type, 'SERVICE');
    });

    test(
        'should leave branchName null when the payload has no `branch` object',
        () {
      // Given — a payload without the nested branch
      final json = <String, dynamic>{
        'id': 'e2',
        'title': 'Reunião',
        'startsAt': '2026-04-12T19:30:00.000Z',
      };

      // When
      final event = UpcomingEvent.fromJson(json);

      // Then
      expect(event.branchName, isNull);
      expect(event.type, isNull);
    });

    test(
        'should leave branchName null when `branch` is present but has no `name` field',
        () {
      // Given — branch present but empty/malformed
      final json = <String, dynamic>{
        'id': 'e3',
        'title': 'Reunião',
        'startsAt': '2026-04-12T19:30:00.000Z',
        'branch': {'id': 'b1'},
      };

      // When
      final event = UpcomingEvent.fromJson(json);

      // Then
      expect(event.branchName, isNull);
    });
  });
}
