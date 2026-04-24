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
