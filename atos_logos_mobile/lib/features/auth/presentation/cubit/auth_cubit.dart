import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/select_church_request.dart';
import '../../domain/models/signup_request.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  String? _selectionToken;

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      final result = await _repository.login(
        LoginRequest(email: email, password: password),
      );
      switch (result) {
        case LoginSuccess():
          emit(const AuthState.authenticated());
        case LoginChurchSelection(:final selectionToken, :final churches):
          _selectionToken = selectionToken;
          emit(AuthState.churchSelection(
            selectionToken: selectionToken,
            churches: churches,
          ));
      }
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(AuthState.error(message: message));
    }
  }

  Future<void> selectChurch(String churchId) async {
    if (_selectionToken == null) {
      emit(const AuthState.error(message: 'No selection token available'));
      return;
    }
    emit(const AuthState.loading());
    try {
      await _repository.selectChurch(
        SelectChurchRequest(
          selectionToken: _selectionToken!,
          churchId: churchId,
        ),
      );
      _selectionToken = null;
      emit(const AuthState.authenticated());
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(AuthState.error(message: message));
    }
  }

  /// Creates a new admin + church and transitions straight to
  /// `authenticated` because the backend auto-issues a token pair on
  /// successful signup. There is no separate "registered" state — the
  /// register screen reacts to `authenticated` exactly like the login
  /// screen does, so the user lands on `/home` without typing credentials
  /// again.
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String churchName,
  }) async {
    emit(const AuthState.loading());
    try {
      await _repository.signup(
        SignupRequest(
          name: name,
          email: email,
          password: password,
          churchName: churchName,
        ),
      );
      emit(const AuthState.authenticated());
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(AuthState.error(message: message));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.initial());
  }

  /// Boot-time session check.
  ///
  /// If a persisted access token exists we optimistically attempt to rotate
  /// it via the refresh endpoint. A successful refresh transitions the
  /// cubit to `authenticated`; any failure (no token, expired refresh,
  /// rotation reuse detected, network down with an expired access token…)
  /// leaves the cubit in its initial state so the router falls back to
  /// `/login`.
  Future<void> checkAuthStatus() async {
    final isAuth = await _repository.isAuthenticated();
    if (!isAuth) {
      return;
    }
    try {
      await _repository.refresh();
      emit(const AuthState.authenticated());
    } catch (_) {
      // Refresh failed — the repository already cleared the local tokens.
      // Fall through silently; the router redirect will send the user to
      // /login on the next navigation attempt.
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await _repository.getProfile();
      emit(AuthState.authenticated(profile: profile));
    } catch (_) {
      // Profile fetch failure should not destroy authenticated session
      emit(const AuthState.authenticated());
    }
  }
}
