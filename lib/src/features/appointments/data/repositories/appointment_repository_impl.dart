import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/networking/api_client.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';

part 'appointment_repository_impl.g.dart';

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepositoryImpl(ref.watch(dioProvider));
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final Dio _dio;

  AppointmentRepositoryImpl(this._dio);

  @override
  Future<Either<ServerException, List<AppointmentModel>>> getAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.appointments);
      final List<dynamic> data = response.data;
      final appointments = data.map((json) => AppointmentModel.fromJson(json)).toList();
      return right(appointments);
    } on DioException catch (e) {
      return left(ServerException(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(ServerException(e.toString()));
    }
  }
  @override
  Future<bool> finalizeAppointment(int id, String evidenceUrl) async {
    try {
      final response = await _dio.post(
        '/appointments/$id/finalize',
        data: {'evidence_url': evidenceUrl},
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw ServerException('Failed to finalize appointment');
    }
  }
}
