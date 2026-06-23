// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lineup_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineupModel _$LineupModelFromJson(Map<String, dynamic> json) {
  return _LineupModel.fromJson(json);
}

/// @nodoc
mixin _$LineupModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_id')
  String get playerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_starter')
  bool get isStarter => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_on_court')
  bool get isOnCourt => throw _privateConstructorUsedError;
  @JsonKey(name: 'entered_at_clock')
  double? get enteredAtClock => throw _privateConstructorUsedError;
  @JsonKey(name: 'entered_at_quarter')
  int? get enteredAtQuarter => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_seconds_played')
  int get totalSecondsPlayed => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LineupModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineupModelCopyWith<LineupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineupModelCopyWith<$Res> {
  factory $LineupModelCopyWith(
          LineupModel value, $Res Function(LineupModel) then) =
      _$LineupModelCopyWithImpl<$Res, LineupModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      String position,
      @JsonKey(name: 'is_starter') bool isStarter,
      @JsonKey(name: 'is_on_court') bool isOnCourt,
      @JsonKey(name: 'entered_at_clock') double? enteredAtClock,
      @JsonKey(name: 'entered_at_quarter') int? enteredAtQuarter,
      @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$LineupModelCopyWithImpl<$Res, $Val extends LineupModel>
    implements $LineupModelCopyWith<$Res> {
  _$LineupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? position = null,
    Object? isStarter = null,
    Object? isOnCourt = null,
    Object? enteredAtClock = freezed,
    Object? enteredAtQuarter = freezed,
    Object? totalSecondsPlayed = null,
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
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      isStarter: null == isStarter
          ? _value.isStarter
          : isStarter // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnCourt: null == isOnCourt
          ? _value.isOnCourt
          : isOnCourt // ignore: cast_nullable_to_non_nullable
              as bool,
      enteredAtClock: freezed == enteredAtClock
          ? _value.enteredAtClock
          : enteredAtClock // ignore: cast_nullable_to_non_nullable
              as double?,
      enteredAtQuarter: freezed == enteredAtQuarter
          ? _value.enteredAtQuarter
          : enteredAtQuarter // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSecondsPlayed: null == totalSecondsPlayed
          ? _value.totalSecondsPlayed
          : totalSecondsPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LineupModelImplCopyWith<$Res>
    implements $LineupModelCopyWith<$Res> {
  factory _$$LineupModelImplCopyWith(
          _$LineupModelImpl value, $Res Function(_$LineupModelImpl) then) =
      __$$LineupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      String position,
      @JsonKey(name: 'is_starter') bool isStarter,
      @JsonKey(name: 'is_on_court') bool isOnCourt,
      @JsonKey(name: 'entered_at_clock') double? enteredAtClock,
      @JsonKey(name: 'entered_at_quarter') int? enteredAtQuarter,
      @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$LineupModelImplCopyWithImpl<$Res>
    extends _$LineupModelCopyWithImpl<$Res, _$LineupModelImpl>
    implements _$$LineupModelImplCopyWith<$Res> {
  __$$LineupModelImplCopyWithImpl(
      _$LineupModelImpl _value, $Res Function(_$LineupModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? position = null,
    Object? isStarter = null,
    Object? isOnCourt = null,
    Object? enteredAtClock = freezed,
    Object? enteredAtQuarter = freezed,
    Object? totalSecondsPlayed = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LineupModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      isStarter: null == isStarter
          ? _value.isStarter
          : isStarter // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnCourt: null == isOnCourt
          ? _value.isOnCourt
          : isOnCourt // ignore: cast_nullable_to_non_nullable
              as bool,
      enteredAtClock: freezed == enteredAtClock
          ? _value.enteredAtClock
          : enteredAtClock // ignore: cast_nullable_to_non_nullable
              as double?,
      enteredAtQuarter: freezed == enteredAtQuarter
          ? _value.enteredAtQuarter
          : enteredAtQuarter // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSecondsPlayed: null == totalSecondsPlayed
          ? _value.totalSecondsPlayed
          : totalSecondsPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LineupModelImpl implements _LineupModel {
  const _$LineupModelImpl(
      {required this.id,
      @JsonKey(name: 'player_id') required this.playerId,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'jersey_number') required this.jerseyNumber,
      required this.position,
      @JsonKey(name: 'is_starter') this.isStarter = false,
      @JsonKey(name: 'is_on_court') this.isOnCourt = false,
      @JsonKey(name: 'entered_at_clock') this.enteredAtClock,
      @JsonKey(name: 'entered_at_quarter') this.enteredAtQuarter,
      @JsonKey(name: 'total_seconds_played') this.totalSecondsPlayed = 0,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt});

  factory _$LineupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineupModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'player_id')
  final String playerId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'jersey_number')
  final int jerseyNumber;
  @override
  final String position;
  @override
  @JsonKey(name: 'is_starter')
  final bool isStarter;
  @override
  @JsonKey(name: 'is_on_court')
  final bool isOnCourt;
  @override
  @JsonKey(name: 'entered_at_clock')
  final double? enteredAtClock;
  @override
  @JsonKey(name: 'entered_at_quarter')
  final int? enteredAtQuarter;
  @override
  @JsonKey(name: 'total_seconds_played')
  final int totalSecondsPlayed;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LineupModel(id: $id, playerId: $playerId, fullName: $fullName, jerseyNumber: $jerseyNumber, position: $position, isStarter: $isStarter, isOnCourt: $isOnCourt, enteredAtClock: $enteredAtClock, enteredAtQuarter: $enteredAtQuarter, totalSecondsPlayed: $totalSecondsPlayed, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineupModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.jerseyNumber, jerseyNumber) ||
                other.jerseyNumber == jerseyNumber) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isStarter, isStarter) ||
                other.isStarter == isStarter) &&
            (identical(other.isOnCourt, isOnCourt) ||
                other.isOnCourt == isOnCourt) &&
            (identical(other.enteredAtClock, enteredAtClock) ||
                other.enteredAtClock == enteredAtClock) &&
            (identical(other.enteredAtQuarter, enteredAtQuarter) ||
                other.enteredAtQuarter == enteredAtQuarter) &&
            (identical(other.totalSecondsPlayed, totalSecondsPlayed) ||
                other.totalSecondsPlayed == totalSecondsPlayed) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      playerId,
      fullName,
      jerseyNumber,
      position,
      isStarter,
      isOnCourt,
      enteredAtClock,
      enteredAtQuarter,
      totalSecondsPlayed,
      updatedAt);

  /// Create a copy of LineupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineupModelImplCopyWith<_$LineupModelImpl> get copyWith =>
      __$$LineupModelImplCopyWithImpl<_$LineupModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineupModelImplToJson(
      this,
    );
  }
}

abstract class _LineupModel implements LineupModel {
  const factory _LineupModel(
      {required final String id,
      @JsonKey(name: 'player_id') required final String playerId,
      @JsonKey(name: 'full_name') required final String fullName,
      @JsonKey(name: 'jersey_number') required final int jerseyNumber,
      required final String position,
      @JsonKey(name: 'is_starter') final bool isStarter,
      @JsonKey(name: 'is_on_court') final bool isOnCourt,
      @JsonKey(name: 'entered_at_clock') final double? enteredAtClock,
      @JsonKey(name: 'entered_at_quarter') final int? enteredAtQuarter,
      @JsonKey(name: 'total_seconds_played') final int totalSecondsPlayed,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$LineupModelImpl;

  factory _LineupModel.fromJson(Map<String, dynamic> json) =
      _$LineupModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'player_id')
  String get playerId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber;
  @override
  String get position;
  @override
  @JsonKey(name: 'is_starter')
  bool get isStarter;
  @override
  @JsonKey(name: 'is_on_court')
  bool get isOnCourt;
  @override
  @JsonKey(name: 'entered_at_clock')
  double? get enteredAtClock;
  @override
  @JsonKey(name: 'entered_at_quarter')
  int? get enteredAtQuarter;
  @override
  @JsonKey(name: 'total_seconds_played')
  int get totalSecondsPlayed;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of LineupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineupModelImplCopyWith<_$LineupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
