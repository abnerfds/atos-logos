import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/members_repository.dart';
import 'members_state.dart';

@injectable
class MembersCubit extends Cubit<MembersState> {
  final MembersRepository _repository;

  MembersCubit({required MembersRepository repository})
    : _repository = repository,
      super(const MembersState.initial());

  /// Current server-side search term. Preserved across [loadMembers] calls
  /// so pulling to refresh doesn't blow away the active filter.
  String _currentQuery = '';

  /// Debounce timer for [search] — prevents a request per keystroke.
  Timer? _searchDebounce;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> loadMembers({int page = 1, String? search}) async {
    // Overriding `search` wins; otherwise keep the last active query so
    // an in-form reload (e.g., after a save) doesn't reset the filter.
    if (search != null) _currentQuery = search;
    emit(const MembersState.loading());
    try {
      final result = await _repository.getMemberships(
        page: page,
        q: _currentQuery.isEmpty ? null : _currentQuery,
      );
      emit(
        MembersState.loaded(
          members: result.data,
          total: result.total,
          page: result.page,
          searchQuery: _currentQuery,
        ),
      );
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(MembersState.error(message: message));
    }
  }

  /// Server-side search. Fires a fresh list request with the new query
  /// so pagination + filtering stay consistent (the old client-side
  /// filter could only see the first 20 rows).
  ///
  /// Debounced at 300ms so typing a name doesn't blast one request per
  /// keystroke (which also avoids the out-of-order response problem
  /// where the /ana response arrives after /a and replaces the list).
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      loadMembers(search: query);
    });
  }

  /// Test-only entry that skips the debounce so widget/unit tests don't
  /// have to pump 300ms timers.
  @visibleForTesting
  Future<void> searchImmediate(String query) => loadMembers(search: query);

  Future<void> createMembership({
    required String userId,
    required String branchId,
    String? role,
  }) async {
    emit(const MembersState.loading());
    try {
      await _repository.createMembership(
        userId: userId,
        branchId: branchId,
        role: role,
      );
      await loadMembers();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(MembersState.error(message: message));
    }
  }

  /// Secretariat onboarding. Pairs with `POST /memberships/with-user` on
  /// the backend. On success, reloads the members list so the new row
  /// appears on the MembersPage without a manual pull-to-refresh. Rethrows
  /// the underlying exception so the UI can keep the form visible + show
  /// a SnackBar with the server's message instead of emitting an error
  /// state (which would unmount the form and lose user input).
  /// Secretariat edit form save. Propagates exceptions so the UI can
  /// show a SnackBar with the backend's PT-BR message without unmounting
  /// the form (no `emit(error)` here).
  Future<void> updateMemberUserData({
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
    await _repository.updateMemberUserData(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      cpf: cpf,
      rg: rg,
      sex: sex,
      civilStatus: civilStatus,
      fatherName: fatherName,
      motherName: motherName,
      country: country,
      state: state,
      city: city,
      neighborhood: neighborhood,
      street: street,
      number: number,
      complement: complement,
      branchId: branchId,
      positionId: positionId,
    );
    // Reload so the edited member's row reflects the new name/phone/etc.
    // when the user navigates back to /secretaria.
    await loadMembers();
  }

  /// Secretariat edit form: updates the MemberProfile date fields
  /// (birth / baptism / admission / consecration). Pairs with
  /// [updateMemberUserData] — the edit page calls both so the User row
  /// and the MemberProfile row are updated in the same save action.
  Future<void> updateMemberProfile({
    required String profileId,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
  }) async {
    await _repository.updateMemberProfile(
      profileId: profileId,
      birthDate: birthDate,
      baptismDate: baptismDate,
      admissionDate: admissionDate,
      consecrationDate: consecrationDate,
    );
  }

  /// Creates the MemberProfile row from the edit screen when the member was
  /// originally onboarded without enough date data to create one.
  Future<void> createMemberProfile({
    required String userId,
    required String branchId,
    required String birthDate,
    required String admissionDate,
    String? baptismDate,
    String? consecrationDate,
  }) async {
    await _repository.createMemberProfile(
      userId: userId,
      branchId: branchId,
      birthDate: birthDate,
      baptismDate: baptismDate,
      admissionDate: admissionDate,
      consecrationDate: consecrationDate,
    );
  }

  /// Secretariat inactivation button. Rethrows so the dialog / page can
  /// surface the Last-Admin guard message verbatim.
  Future<void> inactivateMemberByUserId(String userId) async {
    await _repository.inactivateMemberByUserId(userId);
    await loadMembers();
  }

  Future<void> createMemberWithUser({
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
    await _repository.createMemberWithUser(
      name: name,
      password: password,
      branchId: branchId,
      email: email,
      cpf: cpf,
      phone: phone,
      rg: rg,
      sex: sex,
      civilStatus: civilStatus,
      fatherName: fatherName,
      motherName: motherName,
      role: role,
      positionId: positionId,
      birthDate: birthDate,
      baptismDate: baptismDate,
      admissionDate: admissionDate,
      consecrationDate: consecrationDate,
    );
    // Refresh the members list so the just-added row is visible as soon
    // as the user navigates back to /secretaria.
    await loadMembers();
  }
}
