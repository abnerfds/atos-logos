import 'package:freezed_annotation/freezed_annotation.dart';

part 'ebd_class.freezed.dart';
part 'ebd_class.g.dart';

@freezed
abstract class EbdClassBranch with _$EbdClassBranch {
  const factory EbdClassBranch({required String id, required String name}) =
      _EbdClassBranch;
  factory EbdClassBranch.fromJson(Map<String, dynamic> json) =>
      _$EbdClassBranchFromJson(json);
}

@freezed
abstract class EbdClass with _$EbdClass {
  const factory EbdClass({
    required String id,
    required String churchId,
    required String branchId,
    required String name,
    EbdClassBranch? branch,
    String? targetAudience,
    bool? status,
    String? teacherName,
    @Default(0) int enrolledCount,
    @Default(false) bool certificateAvailable,
  }) = _EbdClass;
  factory EbdClass.fromJson(Map<String, dynamic> json) =>
      _$EbdClassFromJson(json);
}

@freezed
abstract class EbdFrequency with _$EbdFrequency {
  const factory EbdFrequency({
    required String userId,
    required String classId,
    required int totalSessions,
    required int presentCount,
    required double frequency,
    required bool certificateEligible,
  }) = _EbdFrequency;
  factory EbdFrequency.fromJson(Map<String, dynamic> json) =>
      _$EbdFrequencyFromJson(json);
}
