// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) {
  return _DashboardResponse.fromJson(json);
}

/// @nodoc
mixin _$DashboardResponse {
  String get period => throw _privateConstructorUsedError;
  DashboardMetrics get metrics => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_appointment')
  NextAppointment? get nextAppointment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardResponseCopyWith<DashboardResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardResponseCopyWith<$Res> {
  factory $DashboardResponseCopyWith(
          DashboardResponse value, $Res Function(DashboardResponse) then) =
      _$DashboardResponseCopyWithImpl<$Res, DashboardResponse>;
  @useResult
  $Res call(
      {String period,
      DashboardMetrics metrics,
      @JsonKey(name: 'next_appointment') NextAppointment? nextAppointment});

  $DashboardMetricsCopyWith<$Res> get metrics;
  $NextAppointmentCopyWith<$Res>? get nextAppointment;
}

/// @nodoc
class _$DashboardResponseCopyWithImpl<$Res, $Val extends DashboardResponse>
    implements $DashboardResponseCopyWith<$Res> {
  _$DashboardResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? metrics = null,
    Object? nextAppointment = freezed,
  }) {
    return _then(_value.copyWith(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DashboardMetrics,
      nextAppointment: freezed == nextAppointment
          ? _value.nextAppointment
          : nextAppointment // ignore: cast_nullable_to_non_nullable
              as NextAppointment?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DashboardMetricsCopyWith<$Res> get metrics {
    return $DashboardMetricsCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NextAppointmentCopyWith<$Res>? get nextAppointment {
    if (_value.nextAppointment == null) {
      return null;
    }

    return $NextAppointmentCopyWith<$Res>(_value.nextAppointment!, (value) {
      return _then(_value.copyWith(nextAppointment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardResponseImplCopyWith<$Res>
    implements $DashboardResponseCopyWith<$Res> {
  factory _$$DashboardResponseImplCopyWith(_$DashboardResponseImpl value,
          $Res Function(_$DashboardResponseImpl) then) =
      __$$DashboardResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String period,
      DashboardMetrics metrics,
      @JsonKey(name: 'next_appointment') NextAppointment? nextAppointment});

  @override
  $DashboardMetricsCopyWith<$Res> get metrics;
  @override
  $NextAppointmentCopyWith<$Res>? get nextAppointment;
}

/// @nodoc
class __$$DashboardResponseImplCopyWithImpl<$Res>
    extends _$DashboardResponseCopyWithImpl<$Res, _$DashboardResponseImpl>
    implements _$$DashboardResponseImplCopyWith<$Res> {
  __$$DashboardResponseImplCopyWithImpl(_$DashboardResponseImpl _value,
      $Res Function(_$DashboardResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? metrics = null,
    Object? nextAppointment = freezed,
  }) {
    return _then(_$DashboardResponseImpl(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DashboardMetrics,
      nextAppointment: freezed == nextAppointment
          ? _value.nextAppointment
          : nextAppointment // ignore: cast_nullable_to_non_nullable
              as NextAppointment?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardResponseImpl implements _DashboardResponse {
  const _$DashboardResponseImpl(
      {required this.period,
      required this.metrics,
      @JsonKey(name: 'next_appointment') this.nextAppointment});

  factory _$DashboardResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardResponseImplFromJson(json);

  @override
  final String period;
  @override
  final DashboardMetrics metrics;
  @override
  @JsonKey(name: 'next_appointment')
  final NextAppointment? nextAppointment;

  @override
  String toString() {
    return 'DashboardResponse(period: $period, metrics: $metrics, nextAppointment: $nextAppointment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardResponseImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            (identical(other.nextAppointment, nextAppointment) ||
                other.nextAppointment == nextAppointment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, period, metrics, nextAppointment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardResponseImplCopyWith<_$DashboardResponseImpl> get copyWith =>
      __$$DashboardResponseImplCopyWithImpl<_$DashboardResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardResponseImplToJson(
      this,
    );
  }
}

abstract class _DashboardResponse implements DashboardResponse {
  const factory _DashboardResponse(
      {required final String period,
      required final DashboardMetrics metrics,
      @JsonKey(name: 'next_appointment')
      final NextAppointment? nextAppointment}) = _$DashboardResponseImpl;

  factory _DashboardResponse.fromJson(Map<String, dynamic> json) =
      _$DashboardResponseImpl.fromJson;

  @override
  String get period;
  @override
  DashboardMetrics get metrics;
  @override
  @JsonKey(name: 'next_appointment')
  NextAppointment? get nextAppointment;
  @override
  @JsonKey(ignore: true)
  _$$DashboardResponseImplCopyWith<_$DashboardResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardMetrics _$DashboardMetricsFromJson(Map<String, dynamic> json) {
  return _DashboardMetrics.fromJson(json);
}

/// @nodoc
mixin _$DashboardMetrics {
  @JsonKey(name: 'total_production')
  double get totalProduction => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_commission_paid')
  double get totalCommissionPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_commission_pending')
  double get totalCommissionPending => throw _privateConstructorUsedError;
  @JsonKey(name: 'appointments_completed')
  int get appointmentsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double get averageRating => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardMetricsCopyWith<DashboardMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardMetricsCopyWith<$Res> {
  factory $DashboardMetricsCopyWith(
          DashboardMetrics value, $Res Function(DashboardMetrics) then) =
      _$DashboardMetricsCopyWithImpl<$Res, DashboardMetrics>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_production') double totalProduction,
      @JsonKey(name: 'total_commission_paid') double totalCommissionPaid,
      @JsonKey(name: 'total_commission_pending') double totalCommissionPending,
      @JsonKey(name: 'appointments_completed') int appointmentsCompleted,
      @JsonKey(name: 'average_rating') double averageRating});
}

/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res, $Val extends DashboardMetrics>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProduction = null,
    Object? totalCommissionPaid = null,
    Object? totalCommissionPending = null,
    Object? appointmentsCompleted = null,
    Object? averageRating = null,
  }) {
    return _then(_value.copyWith(
      totalProduction: null == totalProduction
          ? _value.totalProduction
          : totalProduction // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionPaid: null == totalCommissionPaid
          ? _value.totalCommissionPaid
          : totalCommissionPaid // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionPending: null == totalCommissionPending
          ? _value.totalCommissionPending
          : totalCommissionPending // ignore: cast_nullable_to_non_nullable
              as double,
      appointmentsCompleted: null == appointmentsCompleted
          ? _value.appointmentsCompleted
          : appointmentsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardMetricsImplCopyWith<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  factory _$$DashboardMetricsImplCopyWith(_$DashboardMetricsImpl value,
          $Res Function(_$DashboardMetricsImpl) then) =
      __$$DashboardMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_production') double totalProduction,
      @JsonKey(name: 'total_commission_paid') double totalCommissionPaid,
      @JsonKey(name: 'total_commission_pending') double totalCommissionPending,
      @JsonKey(name: 'appointments_completed') int appointmentsCompleted,
      @JsonKey(name: 'average_rating') double averageRating});
}

/// @nodoc
class __$$DashboardMetricsImplCopyWithImpl<$Res>
    extends _$DashboardMetricsCopyWithImpl<$Res, _$DashboardMetricsImpl>
    implements _$$DashboardMetricsImplCopyWith<$Res> {
  __$$DashboardMetricsImplCopyWithImpl(_$DashboardMetricsImpl _value,
      $Res Function(_$DashboardMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProduction = null,
    Object? totalCommissionPaid = null,
    Object? totalCommissionPending = null,
    Object? appointmentsCompleted = null,
    Object? averageRating = null,
  }) {
    return _then(_$DashboardMetricsImpl(
      totalProduction: null == totalProduction
          ? _value.totalProduction
          : totalProduction // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionPaid: null == totalCommissionPaid
          ? _value.totalCommissionPaid
          : totalCommissionPaid // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionPending: null == totalCommissionPending
          ? _value.totalCommissionPending
          : totalCommissionPending // ignore: cast_nullable_to_non_nullable
              as double,
      appointmentsCompleted: null == appointmentsCompleted
          ? _value.appointmentsCompleted
          : appointmentsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardMetricsImpl implements _DashboardMetrics {
  const _$DashboardMetricsImpl(
      {@JsonKey(name: 'total_production') required this.totalProduction,
      @JsonKey(name: 'total_commission_paid') required this.totalCommissionPaid,
      @JsonKey(name: 'total_commission_pending')
      required this.totalCommissionPending,
      @JsonKey(name: 'appointments_completed')
      required this.appointmentsCompleted,
      @JsonKey(name: 'average_rating') required this.averageRating});

  factory _$DashboardMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardMetricsImplFromJson(json);

  @override
  @JsonKey(name: 'total_production')
  final double totalProduction;
  @override
  @JsonKey(name: 'total_commission_paid')
  final double totalCommissionPaid;
  @override
  @JsonKey(name: 'total_commission_pending')
  final double totalCommissionPending;
  @override
  @JsonKey(name: 'appointments_completed')
  final int appointmentsCompleted;
  @override
  @JsonKey(name: 'average_rating')
  final double averageRating;

  @override
  String toString() {
    return 'DashboardMetrics(totalProduction: $totalProduction, totalCommissionPaid: $totalCommissionPaid, totalCommissionPending: $totalCommissionPending, appointmentsCompleted: $appointmentsCompleted, averageRating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardMetricsImpl &&
            (identical(other.totalProduction, totalProduction) ||
                other.totalProduction == totalProduction) &&
            (identical(other.totalCommissionPaid, totalCommissionPaid) ||
                other.totalCommissionPaid == totalCommissionPaid) &&
            (identical(other.totalCommissionPending, totalCommissionPending) ||
                other.totalCommissionPending == totalCommissionPending) &&
            (identical(other.appointmentsCompleted, appointmentsCompleted) ||
                other.appointmentsCompleted == appointmentsCompleted) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalProduction,
      totalCommissionPaid,
      totalCommissionPending,
      appointmentsCompleted,
      averageRating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      __$$DashboardMetricsImplCopyWithImpl<_$DashboardMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardMetricsImplToJson(
      this,
    );
  }
}

abstract class _DashboardMetrics implements DashboardMetrics {
  const factory _DashboardMetrics(
      {@JsonKey(name: 'total_production') required final double totalProduction,
      @JsonKey(name: 'total_commission_paid')
      required final double totalCommissionPaid,
      @JsonKey(name: 'total_commission_pending')
      required final double totalCommissionPending,
      @JsonKey(name: 'appointments_completed')
      required final int appointmentsCompleted,
      @JsonKey(name: 'average_rating')
      required final double averageRating}) = _$DashboardMetricsImpl;

  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) =
      _$DashboardMetricsImpl.fromJson;

  @override
  @JsonKey(name: 'total_production')
  double get totalProduction;
  @override
  @JsonKey(name: 'total_commission_paid')
  double get totalCommissionPaid;
  @override
  @JsonKey(name: 'total_commission_pending')
  double get totalCommissionPending;
  @override
  @JsonKey(name: 'appointments_completed')
  int get appointmentsCompleted;
  @override
  @JsonKey(name: 'average_rating')
  double get averageRating;
  @override
  @JsonKey(ignore: true)
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NextAppointment _$NextAppointmentFromJson(Map<String, dynamic> json) {
  return _NextAppointment.fromJson(json);
}

/// @nodoc
mixin _$NextAppointment {
  @JsonKey(name: 'client_name')
  String get clientName => throw _privateConstructorUsedError;
  String get service => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NextAppointmentCopyWith<NextAppointment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NextAppointmentCopyWith<$Res> {
  factory $NextAppointmentCopyWith(
          NextAppointment value, $Res Function(NextAppointment) then) =
      _$NextAppointmentCopyWithImpl<$Res, NextAppointment>;
  @useResult
  $Res call(
      {@JsonKey(name: 'client_name') String clientName,
      String service,
      String time});
}

/// @nodoc
class _$NextAppointmentCopyWithImpl<$Res, $Val extends NextAppointment>
    implements $NextAppointmentCopyWith<$Res> {
  _$NextAppointmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientName = null,
    Object? service = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NextAppointmentImplCopyWith<$Res>
    implements $NextAppointmentCopyWith<$Res> {
  factory _$$NextAppointmentImplCopyWith(_$NextAppointmentImpl value,
          $Res Function(_$NextAppointmentImpl) then) =
      __$$NextAppointmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'client_name') String clientName,
      String service,
      String time});
}

/// @nodoc
class __$$NextAppointmentImplCopyWithImpl<$Res>
    extends _$NextAppointmentCopyWithImpl<$Res, _$NextAppointmentImpl>
    implements _$$NextAppointmentImplCopyWith<$Res> {
  __$$NextAppointmentImplCopyWithImpl(
      _$NextAppointmentImpl _value, $Res Function(_$NextAppointmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientName = null,
    Object? service = null,
    Object? time = null,
  }) {
    return _then(_$NextAppointmentImpl(
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NextAppointmentImpl implements _NextAppointment {
  const _$NextAppointmentImpl(
      {@JsonKey(name: 'client_name') required this.clientName,
      required this.service,
      required this.time});

  factory _$NextAppointmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$NextAppointmentImplFromJson(json);

  @override
  @JsonKey(name: 'client_name')
  final String clientName;
  @override
  final String service;
  @override
  final String time;

  @override
  String toString() {
    return 'NextAppointment(clientName: $clientName, service: $service, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NextAppointmentImpl &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, clientName, service, time);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NextAppointmentImplCopyWith<_$NextAppointmentImpl> get copyWith =>
      __$$NextAppointmentImplCopyWithImpl<_$NextAppointmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NextAppointmentImplToJson(
      this,
    );
  }
}

abstract class _NextAppointment implements NextAppointment {
  const factory _NextAppointment(
      {@JsonKey(name: 'client_name') required final String clientName,
      required final String service,
      required final String time}) = _$NextAppointmentImpl;

  factory _NextAppointment.fromJson(Map<String, dynamic> json) =
      _$NextAppointmentImpl.fromJson;

  @override
  @JsonKey(name: 'client_name')
  String get clientName;
  @override
  String get service;
  @override
  String get time;
  @override
  @JsonKey(ignore: true)
  _$$NextAppointmentImplCopyWith<_$NextAppointmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
