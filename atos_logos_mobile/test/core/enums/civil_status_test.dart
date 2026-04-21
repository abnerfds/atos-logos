import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/core/enums/civil_status.dart';

void main() {
  group('CivilStatus', () {
    test('label returns the PT-BR human-readable label for every value', () {
      // Given/When/Then — labels are the strings shown in the secretariat
      // form's civil-status dropdown.
      expect(CivilStatus.single.label, 'Solteiro(a)');
      expect(CivilStatus.married.label, 'Casado(a)');
      expect(CivilStatus.divorced.label, 'Divorciado(a)');
      expect(CivilStatus.widowed.label, 'Viúvo(a)');
      expect(CivilStatus.separated.label, 'Separado(a)');
      expect(CivilStatus.stableUnion.label, 'União Estável');
    });

    test('wireValue returns the backend enum string for every value', () {
      // Given/When/Then — wireValue is the value posted to the backend DTO
      // (Prisma enum CivilStatus). Must be upper-case + snake_case for the
      // multi-word stableUnion case.
      expect(CivilStatus.single.wireValue, 'SINGLE');
      expect(CivilStatus.married.wireValue, 'MARRIED');
      expect(CivilStatus.divorced.wireValue, 'DIVORCED');
      expect(CivilStatus.widowed.wireValue, 'WIDOWED');
      expect(CivilStatus.separated.wireValue, 'SEPARATED');
      expect(CivilStatus.stableUnion.wireValue, 'STABLE_UNION');
    });
  });
}
