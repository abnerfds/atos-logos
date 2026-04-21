import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/member_profile.dart';
import '../domain/models/membership.dart';

@lazySingleton
class MembersRepository {
  final Dio _dio;

  MembersRepository({required Dio dio}) : _dio = dio;

  Future<MembershipPage> getMemberships({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      // Only attach `q` when it's non-empty so the default list request
      // stays clean (and the backend treats missing q as no filter).
      if (q != null && q.trim().isNotEmpty) {
        queryParams['q'] = q.trim();
      }
      final response = await _dio.get(
        '/memberships',
        queryParameters: queryParams,
      );
      return MembershipPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar membros',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Membership> createMembership({
    required String userId,
    required String branchId,
    String? role,
  }) async {
    try {
      final response = await _dio.post('/memberships', data: {
        'userId': userId,
        'branchId': branchId,
        if (role != null) 'role': role,
      });
      return Membership.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar membro',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Secretariat onboarding — matches `POST /memberships/with-user` on the
  /// backend. Creates a User + Membership (and, when `birthDate` AND
  /// `admissionDate` are present, a MemberProfile) atomically. The raw
  /// server response is returned as a Map because the cubit refreshes
  /// the members list on success rather than consuming the composite.
  Future<Map<String, dynamic>> createMemberWithUser({
    required String name,
    required String password,
    required String branchId,
    String? email,
    String? cpf,
    String? phone,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? role,
    String? positionId,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
  }) async {
    // Strip null/empty optionals so the backend DTO's @IsEmail /
    // @IsDateString validators don't fire on JSON nulls.
    final payload = <String, dynamic>{
      'name': name,
      'password': password,
      'branchId': branchId,
      if (email != null && email.isNotEmpty) 'email': email,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (rg != null && rg.isNotEmpty) 'rg': rg,
      if (sex != null && sex.isNotEmpty) 'sex': sex,
      if (civilStatus != null && civilStatus.isNotEmpty)
        'civilStatus': civilStatus,
      if (fatherName != null && fatherName.isNotEmpty) 'fatherName': fatherName,
      if (motherName != null && motherName.isNotEmpty) 'motherName': motherName,
      if (role != null && role.isNotEmpty) 'role': role,
      if (positionId != null && positionId.isNotEmpty)
        'positionId': positionId,
      if (birthDate != null && birthDate.isNotEmpty) 'birthDate': birthDate,
      if (baptismDate != null && baptismDate.isNotEmpty)
        'baptismDate': baptismDate,
      if (admissionDate != null && admissionDate.isNotEmpty)
        'admissionDate': admissionDate,
      if (consecrationDate != null && consecrationDate.isNotEmpty)
        'consecrationDate': consecrationDate,
    };

    try {
      final response = await _dio.post<dynamic>(
        '/memberships/with-user',
        data: payload,
      );
      return (response.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar membro',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Secretariat edit form: updates the User columns behind a membership
  /// (keyed by userId to match the /edit-member/:userId mobile URL).
  /// Strips empty-string optionals so the backend `@IsEmail` etc. don't
  /// validate blank strings.
  Future<Map<String, dynamic>> updateMemberUserData({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
    String? branchId,
    String? positionId,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (rg != null && rg.isNotEmpty) 'rg': rg,
      if (sex != null && sex.isNotEmpty) 'sex': sex,
      if (civilStatus != null && civilStatus.isNotEmpty)
        'civilStatus': civilStatus,
      if (fatherName != null && fatherName.isNotEmpty) 'fatherName': fatherName,
      if (motherName != null && motherName.isNotEmpty) 'motherName': motherName,
      if (country != null && country.isNotEmpty) 'country': country,
      if (state != null && state.isNotEmpty) 'state': state,
      if (city != null && city.isNotEmpty) 'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty)
        'neighborhood': neighborhood,
      if (street != null && street.isNotEmpty) 'street': street,
      if (number != null && number.isNotEmpty) 'number': number,
      if (complement != null && complement.isNotEmpty) 'complement': complement,
      if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
      if (positionId != null && positionId.isNotEmpty) 'positionId': positionId,
    };

    try {
      final response = await _dio.patch<dynamic>(
        '/memberships/by-user/$userId/user-data',
        data: payload,
      );
      return (response.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao atualizar dados do membro',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Secretariat "Inativar Membro" button. The Last-Admin guard lives on
  /// the backend and surfaces as a 403 here — the caller should show the
  /// server's PT-BR message rather than a generic one.
  Future<void> inactivateMemberByUserId(String userId) async {
    try {
      await _dio.patch<dynamic>('/memberships/by-user/$userId/inactivate');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao inativar membro',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<MemberProfile> getMemberProfile(String profileId) async {
    try {
      final response = await _dio.get('/member-profiles/$profileId');
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Secretariat edit-form PATCH for the ecclesiastical date fields that
  /// live on `MemberProfile` (birth / baptism / admission / consecration).
  /// Pairs with `updateMemberUserData` — the edit page runs both in
  /// parallel because the User row and the MemberProfile row are
  /// separate tables.
  Future<MemberProfile> updateMemberProfile({
    required String profileId,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
    String? photoUrl,
  }) async {
    final payload = <String, dynamic>{
      if (birthDate != null && birthDate.isNotEmpty) 'birthDate': birthDate,
      if (baptismDate != null && baptismDate.isNotEmpty)
        'baptismDate': baptismDate,
      if (admissionDate != null && admissionDate.isNotEmpty)
        'admissionDate': admissionDate,
      if (consecrationDate != null && consecrationDate.isNotEmpty)
        'consecrationDate': consecrationDate,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
    };
    try {
      final response = await _dio.patch<dynamic>(
        '/member-profiles/$profileId',
        data: payload,
      );
      return MemberProfile.fromJson(
        (response.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ??
            'Erro ao atualizar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<MemberProfile> createMemberProfile({
    required String userId,
    required String branchId,
    required String birthDate,
    String? baptismDate,
    required String admissionDate,
    String? consecrationDate,
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post('/member-profiles', data: {
        'userId': userId,
        'branchId': branchId,
        'birthDate': birthDate,
        'admissionDate': admissionDate,
        if (baptismDate != null) 'baptismDate': baptismDate,
        if (consecrationDate != null) 'consecrationDate': consecrationDate,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
