// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardResponseImpl _$$DashboardResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardResponseImpl(
      period: json['period'] as String,
      metrics:
          DashboardMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      nextAppointment: json['next_appointment'] == null
          ? null
          : NextAppointment.fromJson(
              json['next_appointment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardResponseImplToJson(
        _$DashboardResponseImpl instance) =>
    <String, dynamic>{
      'period': instance.period,
      'metrics': instance.metrics,
      'next_appointment': instance.nextAppointment,
    };

_$DashboardMetricsImpl _$$DashboardMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardMetricsImpl(
      totalProduction: (json['total_production'] as num).toDouble(),
      totalCommissionPaid: (json['total_commission_paid'] as num).toDouble(),
      totalCommissionPending:
          (json['total_commission_pending'] as num).toDouble(),
      appointmentsCompleted: (json['appointments_completed'] as num).toInt(),
      averageRating: (json['average_rating'] as num).toDouble(),
    );

Map<String, dynamic> _$$DashboardMetricsImplToJson(
        _$DashboardMetricsImpl instance) =>
    <String, dynamic>{
      'total_production': instance.totalProduction,
      'total_commission_paid': instance.totalCommissionPaid,
      'total_commission_pending': instance.totalCommissionPending,
      'appointments_completed': instance.appointmentsCompleted,
      'average_rating': instance.averageRating,
    };

_$NextAppointmentImpl _$$NextAppointmentImplFromJson(
        Map<String, dynamic> json) =>
    _$NextAppointmentImpl(
      clientName: json['client_name'] as String,
      service: json['service'] as String,
      time: json['time'] as String,
    );

Map<String, dynamic> _$$NextAppointmentImplToJson(
        _$NextAppointmentImpl instance) =>
    <String, dynamic>{
      'client_name': instance.clientName,
      'service': instance.service,
      'time': instance.time,
    };
