import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../members/domain/models/member_profile.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({required MemberProfile profile}) = _Loaded;
  const factory ProfileState.saving() = _Saving;
  const factory ProfileState.saved() = _Saved;
  const factory ProfileState.error({required String message}) = _Error;
}
