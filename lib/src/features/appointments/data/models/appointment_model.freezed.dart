// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) {
  return _AppointmentModel.fromJson(json);
}

/// @nodoc
mixin _$AppointmentModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_name')
  String get clientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_list')
  List<String> get serviceList => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_vip')
  bool get isVip => throw _privateConstructorUsedError;
  @JsonKey(name: 'evidence_url')
  String? get evidenceUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppointmentModelCopyWith<AppointmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentModelCopyWith<$Res> {
  factory $AppointmentModelCopyWith(
          AppointmentModel value, $Res Function(AppointmentModel) then) =
      _$AppointmentModelCopyWithImpl<$Res, AppointmentModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'client_name') String clientName,
      @JsonKey(name: 'service_list') List<String> serviceList,
      @JsonKey(name: 'start_time') DateTime startTime,
      String status,
      @JsonKey(name: 'is_vip') bool isVip,
      @JsonKey(name: 'evidence_url') String? evidenceUrl});
}

/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res, $Val extends AppointmentModel>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientName = null,
    Object? serviceList = null,
    Object? startTime = null,
    Object? status = null,
    Object? isVip = null,
    Object? evidenceUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      serviceList: null == serviceList
          ? _value.serviceList
          : serviceList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isVip: null == isVip
          ? _value.isVip
          : isVip // ignore: cast_nullable_to_non_nullable
              as bool,
      evidenceUrl: freezed == evidenceUrl
          ? _value.evidenceUrl
          : evidenceUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppointmentModelImplCopyWith<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  factory _$$AppointmentModelImplCopyWith(_$AppointmentModelImpl value,
          $Res Function(_$AppointmentModelImpl) then) =
      __$$AppointmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'client_name') String clientName,
      @JsonKey(name: 'service_list') List<String> serviceList,
      @JsonKey(name: 'start_time') DateTime startTime,
      String status,
      @JsonKey(name: 'is_vip') bool isVip,
      @JsonKey(name: 'evidence_url') String? evidenceUrl});
}

/// @nodoc
class __$$AppointmentModelImplCopyWithImpl<$Res>
    extends _$AppointmentModelCopyWithImpl<$Res, _$AppointmentModelImpl>
    implements _$$AppointmentModelImplCopyWith<$Res> {
  __$$AppointmentModelImplCopyWithImpl(_$AppointmentModelImpl _value,
      $Res Function(_$AppointmentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientName = null,
    Object? serviceList = null,
    Object? startTime = null,
    Object? status = null,
    Object? isVip = null,
    Object? evidenceUrl = freezed,
  }) {
    return _then(_$AppointmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      serviceList: null == serviceList
          ? _value._serviceList
          : serviceList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isVip: null == isVip
          ? _value.isVip
          : isVip // ignore: cast_nullable_to_non_nullable
              as bool,
      evidenceUrl: freezed == evidenceUrl
          ? _value.evidenceUrl
          : evidenceUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentModelImpl implements _AppointmentModel {
  const _$AppointmentModelImpl(
      {required this.id,
      @JsonKey(name: 'client_name') required this.clientName,
      @JsonKey(name: 'service_list') required final List<String> serviceList,
      @JsonKey(name: 'start_time') required this.startTime,
      required this.status,
      @JsonKey(name: 'is_vip') required this.isVip,
      @JsonKey(name: 'evidence_url') this.evidenceUrl})
      : _serviceList = serviceList;

  factory _$AppointmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'client_name')
  final String clientName;
  final List<String> _serviceList;
  @override
  @JsonKey(name: 'service_list')
  List<String> get serviceList {
    if (_serviceList is EqualUnmodifiableListView) return _serviceList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serviceList);
  }

  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  final String status;
  @override
  @JsonKey(name: 'is_vip')
  final bool isVip;
  @override
  @JsonKey(name: 'evidence_url')
  final String? evidenceUrl;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, clientName: $clientName, serviceList: $serviceList, startTime: $startTime, status: $status, isVip: $isVip, evidenceUrl: $evidenceUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            const DeepCollectionEquality()
                .equals(other._serviceList, _serviceList) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isVip, isVip) || other.isVip == isVip) &&
            (identical(other.evidenceUrl, evidenceUrl) ||
                other.evidenceUrl == evidenceUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      clientName,
      const DeepCollectionEquality().hash(_serviceList),
      startTime,
      status,
      isVip,
      evidenceUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      __$$AppointmentModelImplCopyWithImpl<_$AppointmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentModelImplToJson(
      this,
    );
  }
}

abstract class _AppointmentModel implements AppointmentModel {
  const factory _AppointmentModel(
      {required final int id,
      @JsonKey(name: 'client_name') required final String clientName,
      @JsonKey(name: 'service_list') required final List<String> serviceList,
      @JsonKey(name: 'start_time') required final DateTime startTime,
      required final String status,
      @JsonKey(name: 'is_vip') required final bool isVip,
      @JsonKey(name: 'evidence_url')
      final String? evidenceUrl}) = _$AppointmentModelImpl;

  factory _AppointmentModel.fromJson(Map<String, dynamic> json) =
      _$AppointmentModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'client_name')
  String get clientName;
  @override
  @JsonKey(name: 'service_list')
  List<String> get serviceList;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  String get status;
  @override
  @JsonKey(name: 'is_vip')
  bool get isVip;
  @override
  @JsonKey(name: 'evidence_url')
  String? get evidenceUrl;
  @override
  @JsonKey(ignore: true)
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
