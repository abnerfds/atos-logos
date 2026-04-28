import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/ebd_class.dart';

@lazySingleton
class EbdRepository {
  final Dio _dio;

  EbdRepository({required Dio dio}) : _dio = dio;

  Future<EbdSetupOptions> getSetupOptions() async {
    try {
      final response = await _dio.get('/ebd/setup-options');
      return EbdSetupOptions.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar dados da EBD',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<EbdClass>> getClasses() async {
    try {
      final response = await _dio.get('/ebd/classes');
      final data = response.data;
      final items = data is Map<String, dynamic> ? data['data'] : data;
      return (items as List)
          .map((e) => EbdClass.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar turmas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdClass> createClass({
    required String name,
    required String branchId,
    String targetAudience = 'Geral',
    String? quarterId,
    String? quarterName,
    List<String> teacherIds = const [],
    List<String> studentIds = const [],
    List<EbdLessonInput> lessons = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/ebd/classes',
        data: {
          'name': name,
          'branchId': branchId,
          'targetAudience': targetAudience,
          if (quarterId != null && quarterId.isNotEmpty) 'quarterId': quarterId,
          if (quarterName != null && quarterName.isNotEmpty)
            'quarterName': quarterName,
          'teacherIds': teacherIds,
          'studentIds': studentIds,
          'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
        },
      );
      return EbdClass.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar turma',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdFrequency> getFrequency(String classId, String userId) async {
    try {
      final response = await _dio.get(
        '/ebd/classes/$classId/frequency/$userId',
      );
      return EbdFrequency.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar frequencia',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdClassDetail> getClassDetail(String classId) async {
    try {
      final response = await _dio.get('/ebd/classes/$classId');
      return EbdClassDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar dados da classe',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<EbdLesson>> getLessons(String classId) async {
    try {
      final response = await _dio.get('/ebd/classes/$classId/lessons');
      return (response.data as List)
          .map((e) => EbdLesson.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar lições',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<String>> getEnrollmentIds(String classId) async {
    try {
      final response = await _dio.get('/ebd/classes/$classId/enrollments');
      return (response.data as List)
          .map((e) => (e as Map<String, dynamic>)['userId'] as String)
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar matrículas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<EbdAttendanceEntry>> getLessonAttendance(
    String lessonId,
  ) async {
    try {
      final response = await _dio.get('/ebd/lessons/$lessonId/attendance');
      return (response.data as List)
          .map((e) => EbdAttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar chamada',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> saveLessonAttendance({
    required String lessonId,
    required List<EbdAttendanceEntry> attendances,
    required double offeringAmount,
    int visitorCount = 0,
  }) async {
    try {
      await _dio.post(
        '/ebd/lessons/$lessonId/attendance',
        data: {
          'visitorCount': visitorCount,
          'offeringAmount': offeringAmount,
          'attendances': attendances
              .map((a) => {'memberId': a.memberId, 'isPresent': a.isPresent})
              .toList(),
        },
      );
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao salvar chamada',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdQuarterSummary> getQuarterSummary() async {
    try {
      final response = await _dio.get('/ebd/quarter-summary');
      return EbdQuarterSummary.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao carregar resumo do trimestre',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updateClass({
    required String classId,
    String? name,
    String? targetAudience,
    String? quarterName,
    List<String>? teacherIds,
    List<String>? studentIds,
    List<EbdLessonInput>? lessons,
  }) async {
    try {
      await _dio.patch(
        '/ebd/classes/$classId',
        data: {
          if (name != null) 'name': name,
          if (targetAudience != null) 'targetAudience': targetAudience,
          if (quarterName != null) 'quarterName': quarterName,
          if (teacherIds != null) 'teacherIds': teacherIds,
          if (studentIds != null) 'studentIds': studentIds,
          if (lessons != null)
            'lessons': lessons.map((l) => l.toJson()).toList(),
        },
      );
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao atualizar classe',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class EbdSetupOptions {
  const EbdSetupOptions({
    this.activeQuarter,
    required this.teachers,
    required this.students,
  });

  factory EbdSetupOptions.fromJson(Map<String, dynamic> json) {
    return EbdSetupOptions(
      activeQuarter: json['activeQuarter'] == null
          ? null
          : EbdQuarterOption.fromJson(
              json['activeQuarter'] as Map<String, dynamic>,
            ),
      teachers: ((json['teachers'] as List?) ?? const [])
          .map((item) => EbdPersonOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      students: ((json['students'] as List?) ?? const [])
          .map((item) => EbdPersonOption.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final EbdQuarterOption? activeQuarter;
  final List<EbdPersonOption> teachers;
  final List<EbdPersonOption> students;
}

class EbdQuarterOption {
  const EbdQuarterOption({required this.id, required this.name});

  factory EbdQuarterOption.fromJson(Map<String, dynamic> json) {
    return EbdQuarterOption(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String name;
}

class EbdPersonOption {
  const EbdPersonOption({
    required this.memberId,
    required this.name,
    required this.role,
    this.photoUrl,
  });

  factory EbdPersonOption.fromJson(Map<String, dynamic> json) {
    return EbdPersonOption(
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'MEMBER',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  final String memberId;
  final String name;
  final String role;
  final String? photoUrl;
}

class EbdLessonInput {
  const EbdLessonInput({required this.theme, required this.scheduledDate});

  final String theme;
  final String scheduledDate;

  Map<String, dynamic> toJson() {
    return {'theme': theme, 'scheduledDate': scheduledDate};
  }
}
