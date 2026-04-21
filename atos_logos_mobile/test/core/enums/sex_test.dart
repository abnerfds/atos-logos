import 'package:flutter_test/flutter_test.dart';

import 'package:atos_logos_mobile/core/enums/sex.dart';

void main() {
  group('Sex', () {
    test('label returns the PT-BR human-readable label for each value', () {
      // Given/When/Then — labels are the strings shown in dropdowns/forms.
      expect(Sex.male.label, 'Masculino');
      expect(Sex.female.label, 'Feminino');
    });

    test('wireValue returns the backend enum string for each value', () {
      // Given/When/Then — wireValue is the value sent to the backend DTO,
      // which expects the upper-case English token.
      expect(Sex.male.wireValue, 'MALE');
      expect(Sex.female.wireValue, 'FEMALE');
    });
  });
}
