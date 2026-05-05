import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import 'injection.config.dart';
import '../network/dio_client.dart';
import '../network/session_expired_notifier.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  getIt.registerLazySingleton<SessionExpiredNotifier>(
    () => SessionExpiredNotifier(),
  );
  getIt.init();
}

@module
abstract class AppModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio get dio => DioClient.getInstance(
        storage: getIt<FlutterSecureStorage>(),
        sessionNotifier: getIt<SessionExpiredNotifier>(),
      );
}
