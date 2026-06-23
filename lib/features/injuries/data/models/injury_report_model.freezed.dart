// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'injury_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InjuryReportModel _$InjuryReportModelFromJson(Map<String, dynamic> json) {
  return _InjuryReportModel.fromJson(json);
}

/// @nodoc
mixin _$InjuryReportModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_id')
  String get playerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_id')
  String get teamId => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'injury_date')
  DateTime? get injuryDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_part')
  String get bodyPart => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_recovery_days')
  int? get estimatedRecoveryDays => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_base64')
  String? get photoBase64 => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'cleared_at')
  DateTime? get clearedAt => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this InjuryReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InjuryReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InjuryReportModelCopyWith<InjuryReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InjuryReportModelCopyWith<$Res> {
  factory $InjuryReportModelCopyWith(
          InjuryReportModel value, $Res Function(InjuryReportModel) then) =
      _$InjuryReportModelCopyWithImpl<$Res, InjuryReportModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'team_id') String teamId,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'injury_date')
      DateTime? injuryDate,
      @JsonKey(name: 'body_part') String bodyPart,
      String severity,
      String description,
      @JsonKey(name: 'estimated_recovery_days') int? estimatedRecoveryDays,
      String status,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'cleared_at')
      DateTime? clearedAt,
      String notes,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$InjuryReportModelCopyWithImpl<$Res, $Val extends InjuryReportModel>
    implements $InjuryReportModelCopyWith<$Res> {
  _$InjuryReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InjuryReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? teamId = null,
    Object? injuryDate = freezed,
    Object? bodyPart = null,
    Object? severity = null,
    Object? description = null,
    Object? estimatedRecoveryDays = freezed,
    Object? status = null,
    Object? photoUrl = freezed,
    Object? photoBase64 = freezed,
    Object? clearedAt = freezed,
    Object? notes = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      injuryDate: freezed == injuryDate
          ? _value.injuryDate
          : injuryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bodyPart: null == bodyPart
          ? _value.bodyPart
          : bodyPart // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedRecoveryDays: freezed == estimatedRecoveryDays
          ? _value.estimatedRecoveryDays
          : estimatedRecoveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      clearedAt: freezed == clearedAt
          ? _value.clearedAt
          : clearedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InjuryReportModelImplCopyWith<$Res>
    implements $InjuryReportModelCopyWith<$Res> {
  factory _$$InjuryReportModelImplCopyWith(_$InjuryReportModelImpl value,
          $Res Function(_$InjuryReportModelImpl) then) =
      __$$InjuryReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'team_id') String teamId,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'injury_date')
      DateTime? injuryDate,
      @JsonKey(name: 'body_part') String bodyPart,
      String severity,
      String description,
      @JsonKey(name: 'estimated_recovery_days') int? estimatedRecoveryDays,
      String status,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'cleared_at')
      DateTime? clearedAt,
      String notes,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$InjuryReportModelImplCopyWithImpl<$Res>
    extends _$InjuryReportModelCopyWithImpl<$Res, _$InjuryReportModelImpl>
    implements _$$InjuryReportModelImplCopyWith<$Res> {
  __$$InjuryReportModelImplCopyWithImpl(_$InjuryReportModelImpl _value,
      $Res Function(_$InjuryReportModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of InjuryReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? teamId = null,
    Object? injuryDate = freezed,
    Object? bodyPart = null,
    Object? severity = null,
    Object? description = null,
    Object? estimatedRecoveryDays = freezed,
    Object? status = null,
    Object? photoUrl = freezed,
    Object? photoBase64 = freezed,
    Object? clearedAt = freezed,
    Object? notes = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$InjuryReportModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      injuryDate: freezed == injuryDate
          ? _value.injuryDate
          : injuryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bodyPart: null == bodyPart
          ? _value.bodyPart
          : bodyPart // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedRecoveryDays: freezed == estimatedRecoveryDays
          ? _value.estimatedRecoveryDays
          : estimatedRecoveryDays // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      clearedAt: freezed == clearedAt
          ? _value.clearedAt
          : clearedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InjuryReportModelImpl implements _InjuryReportModel {
  const _$InjuryReportModelImpl(
      {required this.id,
      @JsonKey(name: 'player_id') required this.playerId,
      @JsonKey(name: 'team_id') required this.teamId,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'injury_date')
      this.injuryDate,
      @JsonKey(name: 'body_part') required this.bodyPart,
      required this.severity,
      required this.description,
      @JsonKey(name: 'estimated_recovery_days') this.estimatedRecoveryDays,
      this.status = 'active',
      @JsonKey(name: 'photo_url') this.photoUrl,
      @JsonKey(name: 'photo_base64') this.photoBase64,
      @TimestampDateTimeConverter() @JsonKey(name: 'cleared_at') this.clearedAt,
      this.notes = '',
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt});

  factory _$InjuryReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InjuryReportModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'player_id')
  final String playerId;
  @override
  @JsonKey(name: 'team_id')
  final String teamId;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'injury_date')
  final DateTime? injuryDate;
  @override
  @JsonKey(name: 'body_part')
  final String bodyPart;
  @override
  final String severity;
  @override
  final String description;
  @override
  @JsonKey(name: 'estimated_recovery_days')
  final int? estimatedRecoveryDays;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  @JsonKey(name: 'photo_base64')
  final String? photoBase64;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'cleared_at')
  final DateTime? clearedAt;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'InjuryReportModel(id: $id, playerId: $playerId, teamId: $teamId, injuryDate: $injuryDate, bodyPart: $bodyPart, severity: $severity, description: $description, estimatedRecoveryDays: $estimatedRecoveryDays, status: $status, photoUrl: $photoUrl, photoBase64: $photoBase64, clearedAt: $clearedAt, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InjuryReportModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.injuryDate, injuryDate) ||
                other.injuryDate == injuryDate) &&
            (identical(other.bodyPart, bodyPart) ||
                other.bodyPart == bodyPart) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.estimatedRecoveryDays, estimatedRecoveryDays) ||
                other.estimatedRecoveryDays == estimatedRecoveryDays) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.clearedAt, clearedAt) ||
                other.clearedAt == clearedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      playerId,
      teamId,
      injuryDate,
      bodyPart,
      severity,
      description,
      estimatedRecoveryDays,
      status,
      photoUrl,
      photoBase64,
      clearedAt,
      notes,
      createdBy,
      createdAt,
      updatedAt);

  /// Create a copy of InjuryReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InjuryReportModelImplCopyWith<_$InjuryReportModelImpl> get copyWith =>
      __$$InjuryReportModelImplCopyWithImpl<_$InjuryReportModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InjuryReportModelImplToJson(
      this,
    );
  }
}

abstract class _InjuryReportModel implements InjuryReportModel {
  const factory _InjuryReportModel(
      {required final String id,
      @JsonKey(name: 'player_id') required final String playerId,
      @JsonKey(name: 'team_id') required final String teamId,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'injury_date')
      final DateTime? injuryDate,
      @JsonKey(name: 'body_part') required final String bodyPart,
      required final String severity,
      required final String description,
      @JsonKey(name: 'estimated_recovery_days')
      final int? estimatedRecoveryDays,
      final String status,
      @JsonKey(name: 'photo_url') final String? photoUrl,
      @JsonKey(name: 'photo_base64') final String? photoBase64,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'cleared_at')
      final DateTime? clearedAt,
      final String notes,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$InjuryReportModelImpl;

  factory _InjuryReportModel.fromJson(Map<String, dynamic> json) =
      _$InjuryReportModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'player_id')
  String get playerId;
  @override
  @JsonKey(name: 'team_id')
  String get teamId;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'injury_date')
  DateTime? get injuryDate;
  @override
  @JsonKey(name: 'body_part')
  String get bodyPart;
  @override
  String get severity;
  @override
  String get description;
  @override
  @JsonKey(name: 'estimated_recovery_days')
  int? get estimatedRecoveryDays;
  @override
  String get status;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  @JsonKey(name: 'photo_base64')
  String? get photoBase64;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'cleared_at')
  DateTime? get clearedAt;
  @override
  String get notes;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of InjuryReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InjuryReportModelImplCopyWith<_$InjuryReportModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
