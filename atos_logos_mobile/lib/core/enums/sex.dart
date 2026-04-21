enum Sex {
  male,
  female,
}

extension SexLabel on Sex {
  String get label {
    switch (this) {
      case Sex.male:
        return 'Masculino';
      case Sex.female:
        return 'Feminino';
    }
  }

  String get wireValue {
    switch (this) {
      case Sex.male:
        return 'MALE';
      case Sex.female:
        return 'FEMALE';
    }
  }
}
