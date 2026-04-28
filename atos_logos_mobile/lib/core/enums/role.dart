/// User role enum matching the backend Role enum from Prisma schema.
enum Role {
  admin('ADMIN', 'Administrador', 'Acesso total ao sistema'),
  secretary('SECRETARY', 'Secretário', 'Gestão de membros, registros e atas de reuniões'),
  member('MEMBER', 'Membro', 'Acesso pessoal e engajamento na comunidade');

  const Role(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static Role fromValue(String value) {
    return Role.values.firstWhere(
      (r) => r.value == value.toUpperCase(),
      orElse: () => Role.member,
    );
  }
}
