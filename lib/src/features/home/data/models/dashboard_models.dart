import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

@freezed
class DashboardResponse with _$DashboardResponse {
  const factory DashboardResponse({
    required String period,
    required DashboardMetrics metrics,
    @JsonKey(name: 'next_appointment') NextAppointment? nextAppointment,
  }) = _DashboardResponse;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);
}

@freezed
class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    @JsonKey(name: 'total_production') required double totalProduction,
    @JsonKey(name: 'total_commission_paid') required double totalCommissionPaid,
    @JsonKey(name: 'total_commission_pending') required double totalCommissionPending,
    @JsonKey(name: 'appointments_completed') required int appointmentsCompleted,
    @JsonKey(name: 'average_rating') required double averageRating,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) => _$DashboardMetricsFromJson(json);
}

@freezed
class NextAppointment with _$NextAppointment {
  const factory NextAppointment({
    @JsonKey(name: 'client_name') required String clientName,
    required String service,
    required String time,
  }) = _NextAppointment;

  factory NextAppointment.fromJson(Map<String, dynamic> json) => _$NextAppointmentFromJson(json);
}
