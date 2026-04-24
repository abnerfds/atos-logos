import 'package:freezed_annotation/freezed_annotation.dart';

part 'ebd_class.freezed.dart';
part 'ebd_class.g.dart';

// ── EbdClassDetail ────────────────────────────────────────────────────────────

class EbdClassDetail {
  const EbdClassDetail({
    required this.id,
    required this.name,
    this.teacherName,
    this.quarterName,
    this.targetAudience,
  });

  factory EbdClassDetail.fromJson(Map<String, dynamic> json) {
    return EbdClassDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherName: json['teacherName'] as String?,
      quarterName: json['quarterName'] as String?,
      targetAudience: json['targetAudience'] as String?,
    );
  }

  final String id;
  final String name;
  final String? teacherName;
  final String? quarterName;
  final String? targetAudience;
}

// ── EbdLesson ─────────────────────────────────────────────────────────────────

class EbdLesson {
  const EbdLesson({
    required this.id,
    required this.classId,
    required this.number,
    required this.theme,
    required this.scheduledDate,
    required this.isCompleted,
    this.hasJournal = false,
  });

  factory EbdLesson.fromJson(Map<String, dynamic> json) {
    return EbdLesson(
      id: json['id'] as String,
      classId: json['classId'] as String,
      number: json['number'] as int,
      theme: json['theme'] as String? ?? '',
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasJournal: json['hasJournal'] as bool? ?? false,
    );
  }

  final String id;
  final String classId;
  final int number;
  final String theme;
  final DateTime scheduledDate;
  final bool isCompleted;
  final bool hasJournal;
}

// ── EbdAttendanceEntry ────────────────────────────────────────────────────────

class EbdAttendanceEntry {
  EbdAttendanceEntry({
    required this.memberId,
    required this.name,
    this.photoUrl,
    this.isPresent = false,
  });

  factory EbdAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return EbdAttendanceEntry(
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      isPresent: json['isPresent'] as bool? ?? false,
    );
  }

  final String memberId;
  final String name;
  final String? photoUrl;
  bool isPresent;
}

// ── EbdQuarterSummary ─────────────────────────────────────────────────────────

class EbdQuarterSummary {
  const EbdQuarterSummary({
    required this.totalStudents,
    required this.activeClasses,
    required this.averageFrequency,
    required this.totalTeachers,
  });

  factory EbdQuarterSummary.fromJson(Map<String, dynamic> json) {
    return EbdQuarterSummary(
      totalStudents: json['totalStudents'] as int? ?? 0,
      activeClasses: json['activeClasses'] as int? ?? 0,
      averageFrequency: (json['averageFrequency'] as num?)?.toDouble() ?? 0.0,
      totalTeachers: json['totalTeachers'] as int? ?? 0,
    );
  }

  final int totalStudents;
  final int activeClasses;
  final double averageFrequency;
  final int totalTeachers;
}

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
