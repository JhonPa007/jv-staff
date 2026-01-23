import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_jv_staff/src/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
import 'package:app_jv_staff/src/features/appointments/data/repositories/appointment_repository_impl.dart';

part 'appointment_controller.g.dart';

@riverpod
class AppointmentController extends _$AppointmentController {
  @override
  FutureOr<List<AppointmentModel>> build() async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.getAppointments();
    
    return result.fold(
      (error) => throw error,
      (appointments) => appointments,
    );
  }
}
