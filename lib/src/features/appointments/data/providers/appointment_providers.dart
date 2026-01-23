import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_jv_staff/src/core/network/dio_client.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../repositories/appointment_repository_impl.dart';

part 'appointment_providers.g.dart';

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepositoryImpl(dio: ref.read(dioClientProvider));
}