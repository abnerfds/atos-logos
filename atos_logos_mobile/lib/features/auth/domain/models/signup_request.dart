import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request.freezed.dart';
part 'signup_request.g.dart';

/// Payload sent to `POST /auth/signup-admin`.
///
/// Phone is intentionally NOT part of this model — admins set their phone
/// later via the profile-edit screen so signup stays minimal and never
/// fails on a phone-uniqueness collision.
@freezed
abstract class SignupRequest with _$SignupRequest {
  const factory SignupRequest({
    required String name,
    required String email,
    required String password,
    required String churchName,
  }) = _SignupRequest;

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);
}
