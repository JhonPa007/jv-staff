import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<Either<ServerException, List<AppointmentModel>>> getAppointments();
  Future<bool> finalizeAppointment(int id, String evidenceUrl);
}
