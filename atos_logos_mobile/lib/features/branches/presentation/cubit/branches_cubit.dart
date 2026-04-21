import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/branches_repository.dart';
import 'branches_state.dart';

@injectable
class BranchesCubit extends Cubit<BranchesState> {
  final BranchesRepository _repository;

  BranchesCubit({required BranchesRepository repository})
      : _repository = repository,
        super(const BranchesState.initial());

  /// Current server-side search term. Preserved across [loadBranches]
  /// calls so pulling to refresh (or a post-save reload) doesn't blow
  /// away the active filter.
  String _currentQuery = '';

  Future<void> loadBranches({String? search}) async {
    if (search != null) _currentQuery = search;
    emit(const BranchesState.loading());
    try {
      final branches = await _repository.getBranches(
        q: _currentQuery.isEmpty ? null : _currentQuery,
      );
      emit(BranchesState.loaded(
        branches: branches,
        searchQuery: _currentQuery,
      ));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(BranchesState.error(message: message));
    }
  }

  /// Server-side search. Fires a fresh list request with the new query
  /// so pagination + filtering stay consistent as the backend's `q` param
  /// filters at the database level.
  Future<void> search(String query) async {
    await loadBranches(search: query);
  }

  Future<void> createBranch({
    required String name,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
  }) async {
    emit(const BranchesState.loading());
    try {
      await _repository.createBranch(
        name: name,
        country: country,
        state: state,
        city: city,
        neighborhood: neighborhood,
        street: street,
        number: number,
      );
      await loadBranches();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(BranchesState.error(message: message));
    }
  }

  /// Partial update. Rethrows so the edit page can surface the backend
  /// message via SnackBar without losing the form state (no `emit(error)`
  /// here — that would unmount the form).
  Future<void> updateBranch({
    required String id,
    String? name,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
  }) async {
    await _repository.updateBranch(
      id: id,
      name: name,
      country: country,
      state: state,
      city: city,
      neighborhood: neighborhood,
      street: street,
      number: number,
    );
    await loadBranches();
  }

  /// Delete. Rethrows the Last-HQ guard message when the backend
  /// refuses; otherwise reloads the list.
  Future<void> deleteBranch(String id) async {
    await _repository.deleteBranch(id);
    await loadBranches();
  }

  /// Promote this branch to HQ (atomic swap on backend). Rethrows the
  /// "already headquarters" conflict and other errors so the page can
  /// surface them via SnackBar without unmounting the form.
  Future<void> promoteToHeadquarters(String id) async {
    await _repository.promoteToHeadquarters(id);
    await loadBranches();
  }
}
