/// Normalises the `message` field of a NestJS/class-validator error body
/// into a single user-facing string.
///
/// NestJS returns two shapes depending on where the 400/409/etc. came
/// from:
///
///   • **Business errors** (thrown manually from a service):
///     `{ "message": "Membro já cadastrado", "statusCode": 400 }`
///
///   • **class-validator errors** (DTO ValidationPipe failing):
///     `{ "message": ["email must be an email", "cpf is not valid"],
///        "error": "Bad Request", "statusCode": 400 }`
///
/// The old repository pattern `e.response?.data?['message']` mixed both
/// shapes — when `message` was a list, passing it as a positional
/// argument to `NetworkException(String)` threw a TypeError on
/// construction, and the cubit's outer `catch (_)` fell back to the
/// generic "Erro inesperado ao salvar." SnackBar.
///
/// This helper returns:
///   - the plain string when `message` is a String
///   - `list.join('; ')` when `message` is a non-empty List
///   - `null` otherwise (no `message`, empty list, unexpected type, or
///     non-Map body) so the caller can fall back to its per-action
///     default ("Erro ao atualizar dados do membro", etc.)
String? parseBackendErrorMessage(dynamic data) {
  if (data is! Map) return null;
  final raw = data['message'];
  if (raw is String) return raw;
  if (raw is List) {
    if (raw.isEmpty) return null;
    return raw.map((e) => e.toString()).join('; ');
  }
  return null;
}
