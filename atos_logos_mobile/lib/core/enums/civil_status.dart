enum CivilStatus {
  single,
  married,
  divorced,
  widowed,
  separated,
  stableUnion,
}

extension CivilStatusLabel on CivilStatus {
  String get label {
    switch (this) {
      case CivilStatus.single:
        return 'Solteiro(a)';
      case CivilStatus.married:
        return 'Casado(a)';
      case CivilStatus.divorced:
        return 'Divorciado(a)';
      case CivilStatus.widowed:
        return 'Viúvo(a)';
      case CivilStatus.separated:
        return 'Separado(a)';
      case CivilStatus.stableUnion:
        return 'União Estável';
    }
  }

  String get wireValue {
    switch (this) {
      case CivilStatus.single:
        return 'SINGLE';
      case CivilStatus.married:
        return 'MARRIED';
      case CivilStatus.divorced:
        return 'DIVORCED';
      case CivilStatus.widowed:
        return 'WIDOWED';
      case CivilStatus.separated:
        return 'SEPARATED';
      case CivilStatus.stableUnion:
        return 'STABLE_UNION';
    }
  }
}
