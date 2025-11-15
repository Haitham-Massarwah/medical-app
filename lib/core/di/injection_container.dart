import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/cache_manager.dart';

// Features
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../features/appointments/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/book_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/cancel_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/reschedule_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/get_appointments_usecase.dart';
import '../../features/appointments/presentation/bloc/appointment_bloc.dart';

import '../../features/doctors/data/datasources/doctor_local_datasource.dart';
import '../../features/doctors/data/datasources/doctor_remote_datasource.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_doctors_usecase.dart';
import '../../features/doctors/domain/usecases/get_doctor_details_usecase.dart';
import '../../features/doctors/domain/usecases/update_doctor_availability_usecase.dart';
import '../../features/doctors/presentation/bloc/doctor_bloc.dart';

import '../../features/patients/data/datasources/patient_local_datasource.dart';
import '../../features/patients/data/datasources/patient_remote_datasource.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/domain/usecases/get_patient_profile_usecase.dart';
import '../../features/patients/domain/usecases/update_patient_profile_usecase.dart';
import '../../features/patients/domain/usecases/create_patient_usecase.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';

import '../../features/payments/data/datasources/payment_local_datasource.dart';
import '../../features/payments/data/datasources/payment_remote_datasource.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usecases/process_payment_usecase.dart';
import '../../features/payments/domain/usecases/refund_payment_usecase.dart';
import '../../features/payments/domain/usecases/get_payment_history_usecase.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';

import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/send_notification_usecase.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core Dependencies
  getIt.registerLazySingleton<Logger>(() => AppConfig.logger);
  
  getIt.registerLazySingleton<SharedPreferences>(() => throw UnimplementedError());
  
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
    ));
    
    // Add interceptors
    dio.interceptors.addAll([
      LoggingInterceptor(getIt<Logger>()),
      AuthInterceptor(getIt<SharedPreferences>()),
      ErrorInterceptor(getIt<Logger>()),
    ]);
    
    return dio;
  });
  
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
  
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage(getIt<SharedPreferences>()));
  
  getIt.registerLazySingleton<CacheManager>(() => CacheManager(getIt<LocalStorage>()));
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  
  // Auth Feature
  _initializeAuthFeature();
  
  // Appointments Feature
  _initializeAppointmentsFeature();
  
  // Doctors Feature
  _initializeDoctorsFeature();
  
  // Patients Feature
  _initializePatientsFeature();
  
  // Payments Feature
  _initializePaymentsFeature();
  
  // Notifications Feature
  _initializeNotificationsFeature();
}

void _initializeAuthFeature() {
  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(getIt<AuthRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<LoginUseCase>(),
      getIt<RegisterUseCase>(),
      getIt<LogoutUseCase>(),
      getIt<RefreshTokenUseCase>(),
    ),
  );
}

void _initializeAppointmentsFeature() {
  // Data Sources
  getIt.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      getIt<AppointmentRemoteDataSource>(),
      getIt<AppointmentLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<BookAppointmentUseCase>(
    () => BookAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  
  getIt.registerLazySingleton<CancelAppointmentUseCase>(
    () => CancelAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  
  getIt.registerLazySingleton<RescheduleAppointmentUseCase>(
    () => RescheduleAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  
  getIt.registerLazySingleton<GetAppointmentsUseCase>(
    () => GetAppointmentsUseCase(getIt<AppointmentRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<AppointmentBloc>(
    () => AppointmentBloc(
      getIt<BookAppointmentUseCase>(),
      getIt<CancelAppointmentUseCase>(),
      getIt<RescheduleAppointmentUseCase>(),
      getIt<GetAppointmentsUseCase>(),
    ),
  );
}

void _initializeDoctorsFeature() {
  // Data Sources
  getIt.registerLazySingleton<DoctorLocalDataSource>(
    () => DoctorLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(
      getIt<DoctorRemoteDataSource>(),
      getIt<DoctorLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<GetDoctorsUseCase>(
    () => GetDoctorsUseCase(getIt<DoctorRepository>()),
  );
  
  getIt.registerLazySingleton<GetDoctorDetailsUseCase>(
    () => GetDoctorDetailsUseCase(getIt<DoctorRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateDoctorAvailabilityUseCase>(
    () => UpdateDoctorAvailabilityUseCase(getIt<DoctorRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<DoctorBloc>(
    () => DoctorBloc(
      getIt<GetDoctorsUseCase>(),
      getIt<GetDoctorDetailsUseCase>(),
      getIt<UpdateDoctorAvailabilityUseCase>(),
    ),
  );
}

void _initializePatientsFeature() {
  // Data Sources
  getIt.registerLazySingleton<PatientLocalDataSource>(
    () => PatientLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(
      getIt<PatientRemoteDataSource>(),
      getIt<PatientLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<GetPatientProfileUseCase>(
    () => GetPatientProfileUseCase(getIt<PatientRepository>()),
  );
  
  getIt.registerLazySingleton<UpdatePatientProfileUseCase>(
    () => UpdatePatientProfileUseCase(getIt<PatientRepository>()),
  );
  
  getIt.registerLazySingleton<CreatePatientUseCase>(
    () => CreatePatientUseCase(getIt<PatientRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<PatientBloc>(
    () => PatientBloc(
      getIt<GetPatientProfileUseCase>(),
      getIt<UpdatePatientProfileUseCase>(),
      getIt<CreatePatientUseCase>(),
    ),
  );
}

void _initializePaymentsFeature() {
  // Data Sources
  getIt.registerLazySingleton<PaymentLocalDataSource>(
    () => PaymentLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      getIt<PaymentRemoteDataSource>(),
      getIt<PaymentLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<ProcessPaymentUseCase>(
    () => ProcessPaymentUseCase(getIt<PaymentRepository>()),
  );
  
  getIt.registerLazySingleton<RefundPaymentUseCase>(
    () => RefundPaymentUseCase(getIt<PaymentRepository>()),
  );
  
  getIt.registerLazySingleton<GetPaymentHistoryUseCase>(
    () => GetPaymentHistoryUseCase(getIt<PaymentRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      getIt<ProcessPaymentUseCase>(),
      getIt<RefundPaymentUseCase>(),
      getIt<GetPaymentHistoryUseCase>(),
    ),
  );
}

void _initializeNotificationsFeature() {
  // Data Sources
  getIt.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSource(getIt<LocalStorage>()),
  );
  
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(getIt<ApiClient>()),
  );
  
  // Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      getIt<NotificationRemoteDataSource>(),
      getIt<NotificationLocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<SendNotificationUseCase>(
    () => SendNotificationUseCase(getIt<NotificationRepository>()),
  );
  
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  
  // Bloc
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getIt<SendNotificationUseCase>(),
      getIt<GetNotificationsUseCase>(),
    ),
  );
}
