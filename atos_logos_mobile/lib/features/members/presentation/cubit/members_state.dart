import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/membership.dart';

part 'members_state.freezed.dart';

@freezed
class MembersState with _$MembersState {
  const factory MembersState.initial() = _Initial;
  const factory MembersState.loading() = _Loading;
  const factory MembersState.loaded({
    required List<Membership> members,
    required int total,
    required int page,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory MembersState.error({required String message}) = _Error;
}
