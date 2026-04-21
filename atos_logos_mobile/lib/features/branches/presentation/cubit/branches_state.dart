import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/branch.dart';

part 'branches_state.freezed.dart';

@freezed
class BranchesState with _$BranchesState {
  const factory BranchesState.initial() = _Initial;
  const factory BranchesState.loading() = _Loading;
  const factory BranchesState.loaded({
    required List<Branch> branches,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory BranchesState.error({required String message}) = _Error;
}
