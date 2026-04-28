// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/auth_repository.dart' as _i726;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/branches/data/branches_repository.dart' as _i49;
import '../../features/branches/presentation/cubit/branches_cubit.dart'
    as _i822;
import '../../features/ebd/data/ebd_repository.dart' as _i605;
import '../../features/ebd/presentation/cubit/ebd_attendance_cubit.dart'
    as _i71;
import '../../features/ebd/presentation/cubit/ebd_class_details_cubit.dart'
    as _i330;
import '../../features/ebd/presentation/cubit/ebd_cubit.dart' as _i1013;
import '../../features/events/data/events_repository.dart' as _i595;
import '../../features/events/presentation/cubit/events_cubit.dart' as _i496;
import '../../features/financial/data/financial_repository.dart' as _i241;
import '../../features/financial/presentation/cubit/financial_cubit.dart'
    as _i758;
import '../../features/home/data/home_repository.dart' as _i65;
import '../../features/home/presentation/cubit/home_cubit.dart' as _i9;
import '../../features/members/data/members_repository.dart' as _i467;
import '../../features/members/presentation/cubit/members_cubit.dart' as _i750;
import '../../features/positions/data/positions_repository.dart' as _i46;
import '../../features/positions/presentation/cubit/positions_cubit.dart'
    as _i1003;
import '../../features/profile/data/profile_repository.dart' as _i680;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../../features/role_permissions/data/repositories/role_permissions_repository.dart'
    as _i170;
import '../../features/role_permissions/presentation/cubit/role_permissions_cubit.dart'
    as _i600;
import '../../features/visitors/data/visitors_repository.dart' as _i44;
import '../../features/visitors/presentation/cubit/visitors_cubit.dart' as _i9;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i49.BranchesRepository>(
      () => _i49.BranchesRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i605.EbdRepository>(
      () => _i605.EbdRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i595.EventsRepository>(
      () => _i595.EventsRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i241.FinancialRepository>(
      () => _i241.FinancialRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i65.HomeRepository>(
      () => _i65.HomeRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i467.MembersRepository>(
      () => _i467.MembersRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i46.PositionsRepository>(
      () => _i46.PositionsRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i680.ProfileRepository>(
      () => _i680.ProfileRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i170.RolePermissionsRepository>(
      () => _i170.RolePermissionsRepository(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i44.VisitorsRepository>(
      () => _i44.VisitorsRepository(dio: gh<_i361.Dio>()),
    );
    gh.factory<_i71.EbdAttendanceCubit>(
      () => _i71.EbdAttendanceCubit(repository: gh<_i605.EbdRepository>()),
    );
    gh.factory<_i330.EbdClassDetailsCubit>(
      () => _i330.EbdClassDetailsCubit(repository: gh<_i605.EbdRepository>()),
    );
    gh.factory<_i1013.EbdCubit>(
      () => _i1013.EbdCubit(repository: gh<_i605.EbdRepository>()),
    );
    gh.factory<_i600.RolePermissionsCubit>(
      () => _i600.RolePermissionsCubit(
        repository: gh<_i170.RolePermissionsRepository>(),
      ),
    );
    gh.lazySingleton<_i726.AuthRepository>(
      () => _i726.AuthRepository(
        dio: gh<_i361.Dio>(),
        storage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i1003.PositionsCubit>(
      () => _i1003.PositionsCubit(repository: gh<_i46.PositionsRepository>()),
    );
    gh.factory<_i750.MembersCubit>(
      () => _i750.MembersCubit(repository: gh<_i467.MembersRepository>()),
    );
    gh.factory<_i9.VisitorsCubit>(
      () => _i9.VisitorsCubit(repository: gh<_i44.VisitorsRepository>()),
    );
    gh.factory<_i758.FinancialCubit>(
      () => _i758.FinancialCubit(repository: gh<_i241.FinancialRepository>()),
    );
    gh.factory<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(repository: gh<_i680.ProfileRepository>()),
    );
    gh.factory<_i822.BranchesCubit>(
      () => _i822.BranchesCubit(repository: gh<_i49.BranchesRepository>()),
    );
    gh.factory<_i9.HomeCubit>(
      () => _i9.HomeCubit(repository: gh<_i65.HomeRepository>()),
    );
    gh.factory<_i496.EventsCubit>(
      () => _i496.EventsCubit(repository: gh<_i595.EventsRepository>()),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(repository: gh<_i726.AuthRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i464.AppModule {}
