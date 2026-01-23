import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required int id,
    @JsonKey(name: 'client_name') required String clientName,
    @JsonKey(name: 'service_list') required List<String> serviceList,
    @JsonKey(name: 'start_time') required DateTime startTime,
    required String status,
    @JsonKey(name: 'is_vip') required bool isVip,
    @JsonKey(name: 'evidence_url') String? evidenceUrl,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);
}
