import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';
part 'position.g.dart';

@freezed
abstract class PositionUserInfo with _$PositionUserInfo {
  const factory PositionUserInfo({
    required String id,
    required String name,
  }) = _PositionUserInfo;

  factory PositionUserInfo.fromJson(Map<String, dynamic> json) =>
      _$PositionUserInfoFromJson(json);
}

@freezed
abstract class PositionUserPivot with _$PositionUserPivot {
  const factory PositionUserPivot({
    required String id,
    required String userId,
    required String positionId,
    required PositionUserInfo user,
  }) = _PositionUserPivot;

  factory PositionUserPivot.fromJson(Map<String, dynamic> json) =>
      _$PositionUserPivotFromJson(json);
}

@freezed
abstract class Position with _$Position {
  const factory Position({
    required String id,
    required String churchId,
    required String name,
    @Default([]) List<PositionUserPivot> users,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
}
