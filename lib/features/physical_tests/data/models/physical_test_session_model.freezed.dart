// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'physical_test_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhysicalTestSessionModel _$PhysicalTestSessionModelFromJson(
    Map<String, dynamic> json) {
  return _PhysicalTestSessionModel.fromJson(json);
}

/// @nodoc
mixin _$PhysicalTestSessionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_id')
  String get teamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'test_type')
  String get testType => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String get academicYear => throw _privateConstructorUsedError;
  int get semester => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_stopped_early')
  bool get isStoppedEarly => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PhysicalTestSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhysicalTestSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhysicalTestSessionModelCopyWith<PhysicalTestSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhysicalTestSessionModelCopyWith<$Res> {
  factory $PhysicalTestSessionModelCopyWith(PhysicalTestSessionModel value,
          $Res Function(PhysicalTestSessionModel) then) =
      _$PhysicalTestSessionModelCopyWithImpl<$Res, PhysicalTestSessionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      @JsonKey(name: 'test_type') String testType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      @JsonKey(name: 'academic_year') String academicYear,
      int semester,
      String notes,
      @JsonKey(name: 'is_stopped_early') bool isStoppedEarly,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class _$PhysicalTestSessionModelCopyWithImpl<$Res,
        $Val extends PhysicalTestSessionModel>
    implements $PhysicalTestSessionModelCopyWith<$Res> {
  _$PhysicalTestSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhysicalTestSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? testType = null,
    Object? scheduledAt = freezed,
    Object? academicYear = null,
    Object? semester = null,
    Object? notes = null,
    Object? isStoppedEarly = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
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
      testType: null == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicYear: null == academicYear
          ? _value.academicYear
          : academicYear // ignore: cast_nullable_to_non_nullable
              as String,
      semester: null == semester
          ? _value.semester
          : semester // ignore: cast_nullable_to_non_nullable
              as int,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      isStoppedEarly: null == isStoppedEarly
          ? _value.isStoppedEarly
          : isStoppedEarly // ignore: cast_nullable_to_non_nullable
              as bool,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhysicalTestSessionModelImplCopyWith<$Res>
    implements $PhysicalTestSessionModelCopyWith<$Res> {
  factory _$$PhysicalTestSessionModelImplCopyWith(
          _$PhysicalTestSessionModelImpl value,
          $Res Function(_$PhysicalTestSessionModelImpl) then) =
      __$$PhysicalTestSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      @JsonKey(name: 'test_type') String testType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      @JsonKey(name: 'academic_year') String academicYear,
      int semester,
      String notes,
      @JsonKey(name: 'is_stopped_early') bool isStoppedEarly,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class __$$PhysicalTestSessionModelImplCopyWithImpl<$Res>
    extends _$PhysicalTestSessionModelCopyWithImpl<$Res,
        _$PhysicalTestSessionModelImpl>
    implements _$$PhysicalTestSessionModelImplCopyWith<$Res> {
  __$$PhysicalTestSessionModelImplCopyWithImpl(
      _$PhysicalTestSessionModelImpl _value,
      $Res Function(_$PhysicalTestSessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhysicalTestSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? testType = null,
    Object? scheduledAt = freezed,
    Object? academicYear = null,
    Object? semester = null,
    Object? notes = null,
    Object? isStoppedEarly = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$PhysicalTestSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      testType: null == testType
          ? _value.testType
          : testType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicYear: null == academicYear
          ? _value.academicYear
          : academicYear // ignore: cast_nullable_to_non_nullable
              as String,
      semester: null == semester
          ? _value.semester
          : semester // ignore: cast_nullable_to_non_nullable
              as int,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      isStoppedEarly: null == isStoppedEarly
          ? _value.isStoppedEarly
          : isStoppedEarly // ignore: cast_nullable_to_non_nullable
              as bool,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhysicalTestSessionModelImpl implements _PhysicalTestSessionModel {
  const _$PhysicalTestSessionModelImpl(
      {required this.id,
      @JsonKey(name: 'team_id') required this.teamId,
      @JsonKey(name: 'test_type') required this.testType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      this.scheduledAt,
      @JsonKey(name: 'academic_year') required this.academicYear,
      required this.semester,
      this.notes = '',
      @JsonKey(name: 'is_stopped_early') this.isStoppedEarly = false,
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      this.createdAt});

  factory _$PhysicalTestSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhysicalTestSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'team_id')
  final String teamId;
  @override
  @JsonKey(name: 'test_type')
  final String testType;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  @override
  @JsonKey(name: 'academic_year')
  final String academicYear;
  @override
  final int semester;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'is_stopped_early')
  final bool isStoppedEarly;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PhysicalTestSessionModel(id: $id, teamId: $teamId, testType: $testType, scheduledAt: $scheduledAt, academicYear: $academicYear, semester: $semester, notes: $notes, isStoppedEarly: $isStoppedEarly, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhysicalTestSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.testType, testType) ||
                other.testType == testType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.semester, semester) ||
                other.semester == semester) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isStoppedEarly, isStoppedEarly) ||
                other.isStoppedEarly == isStoppedEarly) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      teamId,
      testType,
      scheduledAt,
      academicYear,
      semester,
      notes,
      isStoppedEarly,
      createdBy,
      createdAt);

  /// Create a copy of PhysicalTestSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhysicalTestSessionModelImplCopyWith<_$PhysicalTestSessionModelImpl>
      get copyWith => __$$PhysicalTestSessionModelImplCopyWithImpl<
          _$PhysicalTestSessionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhysicalTestSessionModelImplToJson(
      this,
    );
  }
}

abstract class _PhysicalTestSessionModel implements PhysicalTestSessionModel {
  const factory _PhysicalTestSessionModel(
      {required final String id,
      @JsonKey(name: 'team_id') required final String teamId,
      @JsonKey(name: 'test_type') required final String testType,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      final DateTime? scheduledAt,
      @JsonKey(name: 'academic_year') required final String academicYear,
      required final int semester,
      final String notes,
      @JsonKey(name: 'is_stopped_early') final bool isStoppedEarly,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$PhysicalTestSessionModelImpl;

  factory _PhysicalTestSessionModel.fromJson(Map<String, dynamic> json) =
      _$PhysicalTestSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'team_id')
  String get teamId;
  @override
  @JsonKey(name: 'test_type')
  String get testType;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt;
  @override
  @JsonKey(name: 'academic_year')
  String get academicYear;
  @override
  int get semester;
  @override
  String get notes;
  @override
  @JsonKey(name: 'is_stopped_early')
  bool get isStoppedEarly;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of PhysicalTestSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhysicalTestSessionModelImplCopyWith<_$PhysicalTestSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
