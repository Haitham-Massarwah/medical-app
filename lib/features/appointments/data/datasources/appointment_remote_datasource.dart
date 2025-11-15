import 'package:logger/logger.dart';

import '../../../../core/network/api_client.dart';
import '../models/appointment_models.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments(Map<String, dynamic> query);
  Future<AppointmentModel> getAppointment(String id);
  Future<AppointmentModel> bookAppointment(BookAppointmentRequest request);
  Future<AppointmentModel> updateAppointment(String id, UpdateAppointmentRequest request);
  Future<void> cancelAppointment(String id);
  Future<AppointmentModel> rescheduleAppointment(String id, RescheduleAppointmentRequest request);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient _apiClient;
  final Logger _logger;

  AppointmentRemoteDataSourceImpl(this._apiClient, this._logger);

  @override
  Future<List<AppointmentModel>> getAppointments(Map<String, dynamic> query) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppointmentModel> getAppointment(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppointmentModel> bookAppointment(BookAppointmentRequest request) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppointmentModel> updateAppointment(String id, UpdateAppointmentRequest request) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<void> cancelAppointment(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppointmentModel> rescheduleAppointment(String id, RescheduleAppointmentRequest request) async {
    // TODO: Implement
    throw UnimplementedError();
  }
}
