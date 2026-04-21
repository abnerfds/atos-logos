import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/profile_repository.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState.initial());

  Future<void> loadMemberProfile(String profileId) async {
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getMemberProfile(profileId);
      emit(ProfileState.loaded(profile: profile));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(ProfileState.error(message: message));
    }
  }

  Future<void> loadMemberProfileByUserId(String userId) async {
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getMemberProfileByUserId(userId);
      emit(ProfileState.loaded(profile: profile));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(ProfileState.error(message: message));
    }
  }

  Future<void> updateMyProfile(Map<String, dynamic> data) async {
    emit(const ProfileState.saving());
    try {
      await _repository.updateMyProfile(data);
      emit(const ProfileState.saved());
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(ProfileState.error(message: message));
    }
  }
}
