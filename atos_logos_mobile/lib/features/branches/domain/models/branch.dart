import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';
part 'branch.g.dart';

@freezed
abstract class Branch with _$Branch {
  const factory Branch({
    required String id,
    required String name,
    required bool isHeadquarters,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    @JsonKey(name: '_count') BranchCount? count,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) =>
      _$BranchFromJson(json);
}

@freezed
abstract class BranchCount with _$BranchCount {
  const factory BranchCount({
    @Default(0) int memberships,
  }) = _BranchCount;

  factory BranchCount.fromJson(Map<String, dynamic> json) =>
      _$BranchCountFromJson(json);
}
