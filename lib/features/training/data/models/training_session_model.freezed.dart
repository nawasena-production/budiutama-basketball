// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingSessionModel _$TrainingSessionModelFromJson(Map<String, dynamic> json) {
  return _TrainingSessionModel.fromJson(json);
}

/// @nodoc
mixin _$TrainingSessionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_id')
  String get teamId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_type')
  String get sessionType => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_cancelled')
  bool get isCancelled => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TrainingSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingSessionModelCopyWith<TrainingSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingSessionModelCopyWith<$Res> {
  factory $TrainingSessionModelCopyWith(TrainingSessionModel value,
          $Res Function(TrainingSessionModel) then) =
      _$TrainingSessionModelCopyWithImpl<$Res, TrainingSessionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      String title,
      @JsonKey(name: 'session_type') String sessionType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      String location,
      String description,
      @JsonKey(name: 'is_cancelled') bool isCancelled,
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
class _$TrainingSessionModelCopyWithImpl<$Res,
        $Val extends TrainingSessionModel>
    implements $TrainingSessionModelCopyWith<$Res> {
  _$TrainingSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? title = null,
    Object? sessionType = null,
    Object? scheduledAt = freezed,
    Object? durationMinutes = null,
    Object? location = null,
    Object? description = null,
    Object? isCancelled = null,
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
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$TrainingSessionModelImplCopyWith<$Res>
    implements $TrainingSessionModelCopyWith<$Res> {
  factory _$$TrainingSessionModelImplCopyWith(_$TrainingSessionModelImpl value,
          $Res Function(_$TrainingSessionModelImpl) then) =
      __$$TrainingSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      String title,
      @JsonKey(name: 'session_type') String sessionType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      String location,
      String description,
      @JsonKey(name: 'is_cancelled') bool isCancelled,
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
class __$$TrainingSessionModelImplCopyWithImpl<$Res>
    extends _$TrainingSessionModelCopyWithImpl<$Res, _$TrainingSessionModelImpl>
    implements _$$TrainingSessionModelImplCopyWith<$Res> {
  __$$TrainingSessionModelImplCopyWithImpl(_$TrainingSessionModelImpl _value,
      $Res Function(_$TrainingSessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? title = null,
    Object? sessionType = null,
    Object? scheduledAt = freezed,
    Object? durationMinutes = null,
    Object? location = null,
    Object? description = null,
    Object? isCancelled = null,
    Object? notes = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TrainingSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$TrainingSessionModelImpl implements _TrainingSessionModel {
  const _$TrainingSessionModelImpl(
      {required this.id,
      @JsonKey(name: 'team_id') required this.teamId,
      required this.title,
      @JsonKey(name: 'session_type') required this.sessionType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      this.scheduledAt,
      @JsonKey(name: 'duration_minutes') required this.durationMinutes,
      required this.location,
      required this.description,
      @JsonKey(name: 'is_cancelled') this.isCancelled = false,
      this.notes = '',
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt});

  factory _$TrainingSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'team_id')
  final String teamId;
  @override
  final String title;
  @override
  @JsonKey(name: 'session_type')
  final String sessionType;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  final String location;
  @override
  final String description;
  @override
  @JsonKey(name: 'is_cancelled')
  final bool isCancelled;
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
    return 'TrainingSessionModel(id: $id, teamId: $teamId, title: $title, sessionType: $sessionType, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, location: $location, description: $description, isCancelled: $isCancelled, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
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
      teamId,
      title,
      sessionType,
      scheduledAt,
      durationMinutes,
      location,
      description,
      isCancelled,
      notes,
      createdBy,
      createdAt,
      updatedAt);

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingSessionModelImplCopyWith<_$TrainingSessionModelImpl>
      get copyWith =>
          __$$TrainingSessionModelImplCopyWithImpl<_$TrainingSessionModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingSessionModelImplToJson(
      this,
    );
  }
}

abstract class _TrainingSessionModel implements TrainingSessionModel {
  const factory _TrainingSessionModel(
      {required final String id,
      @JsonKey(name: 'team_id') required final String teamId,
      required final String title,
      @JsonKey(name: 'session_type') required final String sessionType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      final DateTime? scheduledAt,
      @JsonKey(name: 'duration_minutes') required final int durationMinutes,
      required final String location,
      required final String description,
      @JsonKey(name: 'is_cancelled') final bool isCancelled,
      final String notes,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$TrainingSessionModelImpl;

  factory _TrainingSessionModel.fromJson(Map<String, dynamic> json) =
      _$TrainingSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'team_id')
  String get teamId;
  @override
  String get title;
  @override
  @JsonKey(name: 'session_type')
  String get sessionType;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  String get location;
  @override
  String get description;
  @override
  @JsonKey(name: 'is_cancelled')
  bool get isCancelled;
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

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingSessionModelImplCopyWith<_$TrainingSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
