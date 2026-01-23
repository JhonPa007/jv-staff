// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentModelImpl _$$AppointmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppointmentModelImpl(
      id: (json['id'] as num).toInt(),
      clientName: json['client_name'] as String,
      serviceList: (json['service_list'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      status: json['status'] as String,
      isVip: json['is_vip'] as bool,
      evidenceUrl: json['evidence_url'] as String?,
    );

Map<String, dynamic> _$$AppointmentModelImplToJson(
        _$AppointmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_name': instance.clientName,
      'service_list': instance.serviceList,
      'start_time': instance.startTime.toIso8601String(),
      'status': instance.status,
      'is_vip': instance.isVip,
      'evidence_url': instance.evidenceUrl,
    };
