import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Registers core networking + auth stack. Call after [AppConfig] is initialized.
Future<void> initializeDependencies() async {
  getIt.registerLazySingleton<Logger>(() => AppConfig.logger);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        sendTimeout: AppConfig.apiTimeout,
      ),
    );
    dio.interceptors.addAll([
      LoggingInterceptor(getIt<Logger>()),
      AuthInterceptor(getIt<SharedPreferences>()),
      ErrorInterceptor(getIt<Logger>()),
    ]);
    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorage(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<CacheManager>(
    () => CacheManager(getIt<LocalStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<LocalStorage>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
      getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>(), getIt<Logger>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>(), getIt<Logger>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>(), getIt<Logger>()),
  );
  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(getIt<AuthRepository>(), getIt<Logger>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      login: getIt<LoginUseCase>(),
      register: getIt<RegisterUseCase>(),
      logout: getIt<LogoutUseCase>(),
      refresh: getIt<RefreshTokenUseCase>(),
    ),
  );
}
