// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventModel _$EventModelFromJson(Map<String, dynamic> json) {
  return _EventModel.fromJson(json);
}

/// @nodoc
mixin _$EventModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_id')
  String get teamId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get organizer => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_type')
  String get eventType => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String get academicYear => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventModelCopyWith<EventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventModelCopyWith<$Res> {
  factory $EventModelCopyWith(
          EventModel value, $Res Function(EventModel) then) =
      _$EventModelCopyWithImpl<$Res, EventModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      String name,
      String organizer,
      @JsonKey(name: 'event_type') String eventType,
      String location,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'start_date')
      DateTime? startDate,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'end_date')
      DateTime? endDate,
      @JsonKey(name: 'academic_year') String academicYear,
      String status,
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
class _$EventModelCopyWithImpl<$Res, $Val extends EventModel>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? name = null,
    Object? organizer = null,
    Object? eventType = null,
    Object? location = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? academicYear = null,
    Object? status = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicYear: null == academicYear
          ? _value.academicYear
          : academicYear // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$EventModelImplCopyWith<$Res>
    implements $EventModelCopyWith<$Res> {
  factory _$$EventModelImplCopyWith(
          _$EventModelImpl value, $Res Function(_$EventModelImpl) then) =
      __$$EventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'team_id') String teamId,
      String name,
      String organizer,
      @JsonKey(name: 'event_type') String eventType,
      String location,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'start_date')
      DateTime? startDate,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'end_date')
      DateTime? endDate,
      @JsonKey(name: 'academic_year') String academicYear,
      String status,
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
class __$$EventModelImplCopyWithImpl<$Res>
    extends _$EventModelCopyWithImpl<$Res, _$EventModelImpl>
    implements _$$EventModelImplCopyWith<$Res> {
  __$$EventModelImplCopyWithImpl(
      _$EventModelImpl _value, $Res Function(_$EventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? name = null,
    Object? organizer = null,
    Object? eventType = null,
    Object? location = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? academicYear = null,
    Object? status = null,
    Object? notes = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicYear: null == academicYear
          ? _value.academicYear
          : academicYear // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$EventModelImpl implements _EventModel {
  const _$EventModelImpl(
      {required this.id,
      @JsonKey(name: 'team_id') required this.teamId,
      required this.name,
      required this.organizer,
      @JsonKey(name: 'event_type') required this.eventType,
      required this.location,
      @TimestampDateTimeConverter() @JsonKey(name: 'start_date') this.startDate,
      @TimestampDateTimeConverter() @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'academic_year') required this.academicYear,
      this.status = 'upcoming',
      this.notes = '',
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt});

  factory _$EventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'team_id')
  final String teamId;
  @override
  final String name;
  @override
  final String organizer;
  @override
  @JsonKey(name: 'event_type')
  final String eventType;
  @override
  final String location;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'academic_year')
  final String academicYear;
  @override
  @JsonKey()
  final String status;
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
    return 'EventModel(id: $id, teamId: $teamId, name: $name, organizer: $organizer, eventType: $eventType, location: $location, startDate: $startDate, endDate: $endDate, academicYear: $academicYear, status: $status, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.organizer, organizer) ||
                other.organizer == organizer) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.status, status) || other.status == status) &&
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
      name,
      organizer,
      eventType,
      location,
      startDate,
      endDate,
      academicYear,
      status,
      notes,
      createdBy,
      createdAt,
      updatedAt);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      __$$EventModelImplCopyWithImpl<_$EventModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventModelImplToJson(
      this,
    );
  }
}

abstract class _EventModel implements EventModel {
  const factory _EventModel(
      {required final String id,
      @JsonKey(name: 'team_id') required final String teamId,
      required final String name,
      required final String organizer,
      @JsonKey(name: 'event_type') required final String eventType,
      required final String location,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'start_date')
      final DateTime? startDate,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'end_date')
      final DateTime? endDate,
      @JsonKey(name: 'academic_year') required final String academicYear,
      final String status,
      final String notes,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$EventModelImpl;

  factory _EventModel.fromJson(Map<String, dynamic> json) =
      _$EventModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'team_id')
  String get teamId;
  @override
  String get name;
  @override
  String get organizer;
  @override
  @JsonKey(name: 'event_type')
  String get eventType;
  @override
  String get location;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'academic_year')
  String get academicYear;
  @override
  String get status;
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

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
