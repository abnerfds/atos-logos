import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';

void main() {
  group('Branch', () {
    test(
        'should deserialize the canonical /branches entry including every address column and the isHeadquarters flag',
        () {
      final json = <String, dynamic>{
        'id': 'b1',
        'name': 'Sede Central',
        'isHeadquarters': true,
        'country': 'Brasil',
        'state': 'SP',
        'city': 'São Paulo',
        'neighborhood': 'Centro',
        'street': 'Av. Principal',
        'number': '1000',
      };

      final branch = Branch.fromJson(json);

      expect(branch.id, 'b1');
      expect(branch.name, 'Sede Central');
      expect(branch.isHeadquarters, isTrue);
      expect(branch.country, 'Brasil');
      expect(branch.state, 'SP');
      expect(branch.city, 'São Paulo');
      expect(branch.neighborhood, 'Centro');
      expect(branch.street, 'Av. Principal');
      expect(branch.number, '1000');
    });

    test(
        'should deserialize the nested `_count.memberships` via its JsonKey mapping',
        () {
      final json = <String, dynamic>{
        'id': 'b1',
        'name': 'Sede',
        'isHeadquarters': true,
        '_count': {'memberships': 42},
      };

      final branch = Branch.fromJson(json);

      expect(branch.count, isNotNull);
      expect(branch.count!.memberships, 42);
    });

    test(
        'should keep count null when the backend omits the _count field entirely',
        () {
      final json = <String, dynamic>{
        'id': 'b1',
        'name': 'Simples',
        'isHeadquarters': false,
      };

      final branch = Branch.fromJson(json);

      expect(branch.count, isNull);
    });
  });

  group('BranchCount', () {
    test(
        'should default memberships to 0 when the field is absent in the payload',
        () {
      final count = BranchCount.fromJson(<String, dynamic>{});

      expect(count.memberships, 0);
    });
  });
}
