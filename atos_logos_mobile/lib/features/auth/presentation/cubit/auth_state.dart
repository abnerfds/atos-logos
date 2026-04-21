import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/church_option.dart';
import '../../domain/models/user_profile.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({UserProfile? profile}) =
      _Authenticated;
  const factory AuthState.churchSelection({
    required String selectionToken,
    required List<ChurchOption> churches,
  }) = _ChurchSelection;
  // NOTE: a dedicated `registered` state used to exist here. It was
  // removed when signupAdmin started returning a token pair (auto-login),
  // so a successful signup now transitions straight to `authenticated`.
  const factory AuthState.error({required String message}) = _Error;
}
