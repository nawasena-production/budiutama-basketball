// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) {
  return _MatchModel.fromJson(json);
}

/// @nodoc
mixin _$MatchModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'home_team_id')
  String get homeTeamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'opponent_name')
  String get opponentName => throw _privateConstructorUsedError;
  String get venue => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_type')
  String get matchType => throw _privateConstructorUsedError;
  String get phase => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_state')
  String get currentState => throw _privateConstructorUsedError;
  @JsonKey(name: 'home_score')
  int get homeScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'opponent_score')
  int get opponentScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'quarter_duration_minutes')
  int get quarterDurationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'num_periods')
  int get numPeriods => throw _privateConstructorUsedError;
  @JsonKey(name: 'ot_duration_minutes')
  int get otDurationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'timer_config_locked')
  bool get timerConfigLocked => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'finished_at')
  DateTime? get finishedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MatchModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchModelCopyWith<MatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchModelCopyWith<$Res> {
  factory $MatchModelCopyWith(
          MatchModel value, $Res Function(MatchModel) then) =
      _$MatchModelCopyWithImpl<$Res, MatchModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'home_team_id') String homeTeamId,
      @JsonKey(name: 'event_id') String eventId,
      @JsonKey(name: 'opponent_name') String opponentName,
      String venue,
      @JsonKey(name: 'match_type') String matchType,
      String phase,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      String status,
      @JsonKey(name: 'current_state') String currentState,
      @JsonKey(name: 'home_score') int homeScore,
      @JsonKey(name: 'opponent_score') int opponentScore,
      @JsonKey(name: 'quarter_duration_minutes') int quarterDurationMinutes,
      @JsonKey(name: 'num_periods') int numPeriods,
      @JsonKey(name: 'ot_duration_minutes') int otDurationMinutes,
      @JsonKey(name: 'timer_config_locked') bool timerConfigLocked,
      String notes,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'started_at')
      DateTime? startedAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'finished_at')
      DateTime? finishedAt,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$MatchModelCopyWithImpl<$Res, $Val extends MatchModel>
    implements $MatchModelCopyWith<$Res> {
  _$MatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeamId = null,
    Object? eventId = null,
    Object? opponentName = null,
    Object? venue = null,
    Object? matchType = null,
    Object? phase = null,
    Object? scheduledAt = freezed,
    Object? status = null,
    Object? currentState = null,
    Object? homeScore = null,
    Object? opponentScore = null,
    Object? quarterDurationMinutes = null,
    Object? numPeriods = null,
    Object? otDurationMinutes = null,
    Object? timerConfigLocked = null,
    Object? notes = null,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeamId: null == homeTeamId
          ? _value.homeTeamId
          : homeTeamId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      opponentName: null == opponentName
          ? _value.opponentName
          : opponentName // ignore: cast_nullable_to_non_nullable
              as String,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      matchType: null == matchType
          ? _value.matchType
          : matchType // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currentState: null == currentState
          ? _value.currentState
          : currentState // ignore: cast_nullable_to_non_nullable
              as String,
      homeScore: null == homeScore
          ? _value.homeScore
          : homeScore // ignore: cast_nullable_to_non_nullable
              as int,
      opponentScore: null == opponentScore
          ? _value.opponentScore
          : opponentScore // ignore: cast_nullable_to_non_nullable
              as int,
      quarterDurationMinutes: null == quarterDurationMinutes
          ? _value.quarterDurationMinutes
          : quarterDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      numPeriods: null == numPeriods
          ? _value.numPeriods
          : numPeriods // ignore: cast_nullable_to_non_nullable
              as int,
      otDurationMinutes: null == otDurationMinutes
          ? _value.otDurationMinutes
          : otDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      timerConfigLocked: null == timerConfigLocked
          ? _value.timerConfigLocked
          : timerConfigLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$MatchModelImplCopyWith<$Res>
    implements $MatchModelCopyWith<$Res> {
  factory _$$MatchModelImplCopyWith(
          _$MatchModelImpl value, $Res Function(_$MatchModelImpl) then) =
      __$$MatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'home_team_id') String homeTeamId,
      @JsonKey(name: 'event_id') String eventId,
      @JsonKey(name: 'opponent_name') String opponentName,
      String venue,
      @JsonKey(name: 'match_type') String matchType,
      String phase,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      DateTime? scheduledAt,
      String status,
      @JsonKey(name: 'current_state') String currentState,
      @JsonKey(name: 'home_score') int homeScore,
      @JsonKey(name: 'opponent_score') int opponentScore,
      @JsonKey(name: 'quarter_duration_minutes') int quarterDurationMinutes,
      @JsonKey(name: 'num_periods') int numPeriods,
      @JsonKey(name: 'ot_duration_minutes') int otDurationMinutes,
      @JsonKey(name: 'timer_config_locked') bool timerConfigLocked,
      String notes,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'started_at')
      DateTime? startedAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'finished_at')
      DateTime? finishedAt,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$MatchModelImplCopyWithImpl<$Res>
    extends _$MatchModelCopyWithImpl<$Res, _$MatchModelImpl>
    implements _$$MatchModelImplCopyWith<$Res> {
  __$$MatchModelImplCopyWithImpl(
      _$MatchModelImpl _value, $Res Function(_$MatchModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeamId = null,
    Object? eventId = null,
    Object? opponentName = null,
    Object? venue = null,
    Object? matchType = null,
    Object? phase = null,
    Object? scheduledAt = freezed,
    Object? status = null,
    Object? currentState = null,
    Object? homeScore = null,
    Object? opponentScore = null,
    Object? quarterDurationMinutes = null,
    Object? numPeriods = null,
    Object? otDurationMinutes = null,
    Object? timerConfigLocked = null,
    Object? notes = null,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MatchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeamId: null == homeTeamId
          ? _value.homeTeamId
          : homeTeamId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      opponentName: null == opponentName
          ? _value.opponentName
          : opponentName // ignore: cast_nullable_to_non_nullable
              as String,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      matchType: null == matchType
          ? _value.matchType
          : matchType // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currentState: null == currentState
          ? _value.currentState
          : currentState // ignore: cast_nullable_to_non_nullable
              as String,
      homeScore: null == homeScore
          ? _value.homeScore
          : homeScore // ignore: cast_nullable_to_non_nullable
              as int,
      opponentScore: null == opponentScore
          ? _value.opponentScore
          : opponentScore // ignore: cast_nullable_to_non_nullable
              as int,
      quarterDurationMinutes: null == quarterDurationMinutes
          ? _value.quarterDurationMinutes
          : quarterDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      numPeriods: null == numPeriods
          ? _value.numPeriods
          : numPeriods // ignore: cast_nullable_to_non_nullable
              as int,
      otDurationMinutes: null == otDurationMinutes
          ? _value.otDurationMinutes
          : otDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      timerConfigLocked: null == timerConfigLocked
          ? _value.timerConfigLocked
          : timerConfigLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$MatchModelImpl implements _MatchModel {
  const _$MatchModelImpl(
      {required this.id,
      @JsonKey(name: 'home_team_id') required this.homeTeamId,
      @JsonKey(name: 'event_id') required this.eventId,
      @JsonKey(name: 'opponent_name') required this.opponentName,
      required this.venue,
      @JsonKey(name: 'match_type') required this.matchType,
      required this.phase,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      this.scheduledAt,
      this.status = 'scheduled',
      @JsonKey(name: 'current_state') this.currentState = 'PRE_MATCH',
      @JsonKey(name: 'home_score') this.homeScore = 0,
      @JsonKey(name: 'opponent_score') this.opponentScore = 0,
      @JsonKey(name: 'quarter_duration_minutes')
      this.quarterDurationMinutes = 10,
      @JsonKey(name: 'num_periods') this.numPeriods = 4,
      @JsonKey(name: 'ot_duration_minutes') this.otDurationMinutes = 5,
      @JsonKey(name: 'timer_config_locked') this.timerConfigLocked = false,
      this.notes = '',
      @TimestampDateTimeConverter() @JsonKey(name: 'started_at') this.startedAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'finished_at')
      this.finishedAt,
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt});

  factory _$MatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'home_team_id')
  final String homeTeamId;
  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  @JsonKey(name: 'opponent_name')
  final String opponentName;
  @override
  final String venue;
  @override
  @JsonKey(name: 'match_type')
  final String matchType;
  @override
  final String phase;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'current_state')
  final String currentState;
  @override
  @JsonKey(name: 'home_score')
  final int homeScore;
  @override
  @JsonKey(name: 'opponent_score')
  final int opponentScore;
  @override
  @JsonKey(name: 'quarter_duration_minutes')
  final int quarterDurationMinutes;
  @override
  @JsonKey(name: 'num_periods')
  final int numPeriods;
  @override
  @JsonKey(name: 'ot_duration_minutes')
  final int otDurationMinutes;
  @override
  @JsonKey(name: 'timer_config_locked')
  final bool timerConfigLocked;
  @override
  @JsonKey()
  final String notes;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;
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
    return 'MatchModel(id: $id, homeTeamId: $homeTeamId, eventId: $eventId, opponentName: $opponentName, venue: $venue, matchType: $matchType, phase: $phase, scheduledAt: $scheduledAt, status: $status, currentState: $currentState, homeScore: $homeScore, opponentScore: $opponentScore, quarterDurationMinutes: $quarterDurationMinutes, numPeriods: $numPeriods, otDurationMinutes: $otDurationMinutes, timerConfigLocked: $timerConfigLocked, notes: $notes, startedAt: $startedAt, finishedAt: $finishedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.homeTeamId, homeTeamId) ||
                other.homeTeamId == homeTeamId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.opponentName, opponentName) ||
                other.opponentName == opponentName) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.matchType, matchType) ||
                other.matchType == matchType) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentState, currentState) ||
                other.currentState == currentState) &&
            (identical(other.homeScore, homeScore) ||
                other.homeScore == homeScore) &&
            (identical(other.opponentScore, opponentScore) ||
                other.opponentScore == opponentScore) &&
            (identical(other.quarterDurationMinutes, quarterDurationMinutes) ||
                other.quarterDurationMinutes == quarterDurationMinutes) &&
            (identical(other.numPeriods, numPeriods) ||
                other.numPeriods == numPeriods) &&
            (identical(other.otDurationMinutes, otDurationMinutes) ||
                other.otDurationMinutes == otDurationMinutes) &&
            (identical(other.timerConfigLocked, timerConfigLocked) ||
                other.timerConfigLocked == timerConfigLocked) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        homeTeamId,
        eventId,
        opponentName,
        venue,
        matchType,
        phase,
        scheduledAt,
        status,
        currentState,
        homeScore,
        opponentScore,
        quarterDurationMinutes,
        numPeriods,
        otDurationMinutes,
        timerConfigLocked,
        notes,
        startedAt,
        finishedAt,
        createdBy,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      __$$MatchModelImplCopyWithImpl<_$MatchModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchModelImplToJson(
      this,
    );
  }
}

abstract class _MatchModel implements MatchModel {
  const factory _MatchModel(
      {required final String id,
      @JsonKey(name: 'home_team_id') required final String homeTeamId,
      @JsonKey(name: 'event_id') required final String eventId,
      @JsonKey(name: 'opponent_name') required final String opponentName,
      required final String venue,
      @JsonKey(name: 'match_type') required final String matchType,
      required final String phase,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'scheduled_at')
      final DateTime? scheduledAt,
      final String status,
      @JsonKey(name: 'current_state') final String currentState,
      @JsonKey(name: 'home_score') final int homeScore,
      @JsonKey(name: 'opponent_score') final int opponentScore,
      @JsonKey(name: 'quarter_duration_minutes')
      final int quarterDurationMinutes,
      @JsonKey(name: 'num_periods') final int numPeriods,
      @JsonKey(name: 'ot_duration_minutes') final int otDurationMinutes,
      @JsonKey(name: 'timer_config_locked') final bool timerConfigLocked,
      final String notes,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'started_at')
      final DateTime? startedAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'finished_at')
      final DateTime? finishedAt,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$MatchModelImpl;

  factory _MatchModel.fromJson(Map<String, dynamic> json) =
      _$MatchModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'home_team_id')
  String get homeTeamId;
  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  @JsonKey(name: 'opponent_name')
  String get opponentName;
  @override
  String get venue;
  @override
  @JsonKey(name: 'match_type')
  String get matchType;
  @override
  String get phase;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt;
  @override
  String get status;
  @override
  @JsonKey(name: 'current_state')
  String get currentState;
  @override
  @JsonKey(name: 'home_score')
  int get homeScore;
  @override
  @JsonKey(name: 'opponent_score')
  int get opponentScore;
  @override
  @JsonKey(name: 'quarter_duration_minutes')
  int get quarterDurationMinutes;
  @override
  @JsonKey(name: 'num_periods')
  int get numPeriods;
  @override
  @JsonKey(name: 'ot_duration_minutes')
  int get otDurationMinutes;
  @override
  @JsonKey(name: 'timer_config_locked')
  bool get timerConfigLocked;
  @override
  String get notes;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'finished_at')
  DateTime? get finishedAt;
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

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
