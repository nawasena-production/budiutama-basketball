// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchEventModel _$MatchEventModelFromJson(Map<String, dynamic> json) {
  return _MatchEventModel.fromJson(json);
}

/// @nodoc
mixin _$MatchEventModel {
  String get id => throw _privateConstructorUsedError;
  int get quarter => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_remaining')
  double get timeRemaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_id')
  String? get playerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'action_type')
  String get actionType => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  String? get zone => throw _privateConstructorUsedError;
  @JsonKey(name: 'shot_x')
  double? get shotX => throw _privateConstructorUsedError;
  @JsonKey(name: 'shot_y')
  double? get shotY => throw _privateConstructorUsedError;
  @JsonKey(name: 'shot_distance_ft')
  int? get shotDistanceFt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_opponent')
  bool get isOpponent => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_undone')
  bool get isUndone => throw _privateConstructorUsedError;
  @JsonKey(name: 'undo_ref_id')
  String? get undoRefId =>
      throw _privateConstructorUsedError; // ── BARU (Step 16) — konteks tambahan khusus action_type == 'SUBSTITUTION' ──
// Diisi null untuk seluruh action_type lainnya. Disimpan langsung di
// event (bukan dihitung ulang dari lineup) supaya Event Timeline bisa
// menampilkan "#7 OUT → #11 IN" tanpa query tambahan ke collection lain
// (lihat SDD Section 8.1 — prinsip immutability & self-contained event log).
  @JsonKey(name: 'sub_out_player_id')
  String? get subOutPlayerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_out_jersey')
  int? get subOutJersey => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_in_jersey')
  int? get subInJersey => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MatchEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchEventModelCopyWith<MatchEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchEventModelCopyWith<$Res> {
  factory $MatchEventModelCopyWith(
          MatchEventModel value, $Res Function(MatchEventModel) then) =
      _$MatchEventModelCopyWithImpl<$Res, MatchEventModel>;
  @useResult
  $Res call(
      {String id,
      int quarter,
      @JsonKey(name: 'time_remaining') double timeRemaining,
      @JsonKey(name: 'player_id') String? playerId,
      @JsonKey(name: 'action_type') String actionType,
      int value,
      String? zone,
      @JsonKey(name: 'shot_x') double? shotX,
      @JsonKey(name: 'shot_y') double? shotY,
      @JsonKey(name: 'shot_distance_ft') int? shotDistanceFt,
      @JsonKey(name: 'is_opponent') bool isOpponent,
      @JsonKey(name: 'is_undone') bool isUndone,
      @JsonKey(name: 'undo_ref_id') String? undoRefId,
      @JsonKey(name: 'sub_out_player_id') String? subOutPlayerId,
      @JsonKey(name: 'sub_out_jersey') int? subOutJersey,
      @JsonKey(name: 'sub_in_jersey') int? subInJersey,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class _$MatchEventModelCopyWithImpl<$Res, $Val extends MatchEventModel>
    implements $MatchEventModelCopyWith<$Res> {
  _$MatchEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quarter = null,
    Object? timeRemaining = null,
    Object? playerId = freezed,
    Object? actionType = null,
    Object? value = null,
    Object? zone = freezed,
    Object? shotX = freezed,
    Object? shotY = freezed,
    Object? shotDistanceFt = freezed,
    Object? isOpponent = null,
    Object? isUndone = null,
    Object? undoRefId = freezed,
    Object? subOutPlayerId = freezed,
    Object? subOutJersey = freezed,
    Object? subInJersey = freezed,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quarter: null == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as int,
      timeRemaining: null == timeRemaining
          ? _value.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as double,
      playerId: freezed == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      zone: freezed == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String?,
      shotX: freezed == shotX
          ? _value.shotX
          : shotX // ignore: cast_nullable_to_non_nullable
              as double?,
      shotY: freezed == shotY
          ? _value.shotY
          : shotY // ignore: cast_nullable_to_non_nullable
              as double?,
      shotDistanceFt: freezed == shotDistanceFt
          ? _value.shotDistanceFt
          : shotDistanceFt // ignore: cast_nullable_to_non_nullable
              as int?,
      isOpponent: null == isOpponent
          ? _value.isOpponent
          : isOpponent // ignore: cast_nullable_to_non_nullable
              as bool,
      isUndone: null == isUndone
          ? _value.isUndone
          : isUndone // ignore: cast_nullable_to_non_nullable
              as bool,
      undoRefId: freezed == undoRefId
          ? _value.undoRefId
          : undoRefId // ignore: cast_nullable_to_non_nullable
              as String?,
      subOutPlayerId: freezed == subOutPlayerId
          ? _value.subOutPlayerId
          : subOutPlayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subOutJersey: freezed == subOutJersey
          ? _value.subOutJersey
          : subOutJersey // ignore: cast_nullable_to_non_nullable
              as int?,
      subInJersey: freezed == subInJersey
          ? _value.subInJersey
          : subInJersey // ignore: cast_nullable_to_non_nullable
              as int?,
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
abstract class _$$MatchEventModelImplCopyWith<$Res>
    implements $MatchEventModelCopyWith<$Res> {
  factory _$$MatchEventModelImplCopyWith(_$MatchEventModelImpl value,
          $Res Function(_$MatchEventModelImpl) then) =
      __$$MatchEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int quarter,
      @JsonKey(name: 'time_remaining') double timeRemaining,
      @JsonKey(name: 'player_id') String? playerId,
      @JsonKey(name: 'action_type') String actionType,
      int value,
      String? zone,
      @JsonKey(name: 'shot_x') double? shotX,
      @JsonKey(name: 'shot_y') double? shotY,
      @JsonKey(name: 'shot_distance_ft') int? shotDistanceFt,
      @JsonKey(name: 'is_opponent') bool isOpponent,
      @JsonKey(name: 'is_undone') bool isUndone,
      @JsonKey(name: 'undo_ref_id') String? undoRefId,
      @JsonKey(name: 'sub_out_player_id') String? subOutPlayerId,
      @JsonKey(name: 'sub_out_jersey') int? subOutJersey,
      @JsonKey(name: 'sub_in_jersey') int? subInJersey,
      @JsonKey(name: 'created_by') String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class __$$MatchEventModelImplCopyWithImpl<$Res>
    extends _$MatchEventModelCopyWithImpl<$Res, _$MatchEventModelImpl>
    implements _$$MatchEventModelImplCopyWith<$Res> {
  __$$MatchEventModelImplCopyWithImpl(
      _$MatchEventModelImpl _value, $Res Function(_$MatchEventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quarter = null,
    Object? timeRemaining = null,
    Object? playerId = freezed,
    Object? actionType = null,
    Object? value = null,
    Object? zone = freezed,
    Object? shotX = freezed,
    Object? shotY = freezed,
    Object? shotDistanceFt = freezed,
    Object? isOpponent = null,
    Object? isUndone = null,
    Object? undoRefId = freezed,
    Object? subOutPlayerId = freezed,
    Object? subOutJersey = freezed,
    Object? subInJersey = freezed,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$MatchEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quarter: null == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as int,
      timeRemaining: null == timeRemaining
          ? _value.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as double,
      playerId: freezed == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      zone: freezed == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String?,
      shotX: freezed == shotX
          ? _value.shotX
          : shotX // ignore: cast_nullable_to_non_nullable
              as double?,
      shotY: freezed == shotY
          ? _value.shotY
          : shotY // ignore: cast_nullable_to_non_nullable
              as double?,
      shotDistanceFt: freezed == shotDistanceFt
          ? _value.shotDistanceFt
          : shotDistanceFt // ignore: cast_nullable_to_non_nullable
              as int?,
      isOpponent: null == isOpponent
          ? _value.isOpponent
          : isOpponent // ignore: cast_nullable_to_non_nullable
              as bool,
      isUndone: null == isUndone
          ? _value.isUndone
          : isUndone // ignore: cast_nullable_to_non_nullable
              as bool,
      undoRefId: freezed == undoRefId
          ? _value.undoRefId
          : undoRefId // ignore: cast_nullable_to_non_nullable
              as String?,
      subOutPlayerId: freezed == subOutPlayerId
          ? _value.subOutPlayerId
          : subOutPlayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subOutJersey: freezed == subOutJersey
          ? _value.subOutJersey
          : subOutJersey // ignore: cast_nullable_to_non_nullable
              as int?,
      subInJersey: freezed == subInJersey
          ? _value.subInJersey
          : subInJersey // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _$MatchEventModelImpl implements _MatchEventModel {
  const _$MatchEventModelImpl(
      {required this.id,
      required this.quarter,
      @JsonKey(name: 'time_remaining') required this.timeRemaining,
      @JsonKey(name: 'player_id') this.playerId,
      @JsonKey(name: 'action_type') required this.actionType,
      this.value = 0,
      this.zone,
      @JsonKey(name: 'shot_x') this.shotX,
      @JsonKey(name: 'shot_y') this.shotY,
      @JsonKey(name: 'shot_distance_ft') this.shotDistanceFt,
      @JsonKey(name: 'is_opponent') this.isOpponent = false,
      @JsonKey(name: 'is_undone') this.isUndone = false,
      @JsonKey(name: 'undo_ref_id') this.undoRefId,
      @JsonKey(name: 'sub_out_player_id') this.subOutPlayerId,
      @JsonKey(name: 'sub_out_jersey') this.subOutJersey,
      @JsonKey(name: 'sub_in_jersey') this.subInJersey,
      @JsonKey(name: 'created_by') required this.createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      this.createdAt});

  factory _$MatchEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final int quarter;
  @override
  @JsonKey(name: 'time_remaining')
  final double timeRemaining;
  @override
  @JsonKey(name: 'player_id')
  final String? playerId;
  @override
  @JsonKey(name: 'action_type')
  final String actionType;
  @override
  @JsonKey()
  final int value;
  @override
  final String? zone;
  @override
  @JsonKey(name: 'shot_x')
  final double? shotX;
  @override
  @JsonKey(name: 'shot_y')
  final double? shotY;
  @override
  @JsonKey(name: 'shot_distance_ft')
  final int? shotDistanceFt;
  @override
  @JsonKey(name: 'is_opponent')
  final bool isOpponent;
  @override
  @JsonKey(name: 'is_undone')
  final bool isUndone;
  @override
  @JsonKey(name: 'undo_ref_id')
  final String? undoRefId;
// ── BARU (Step 16) — konteks tambahan khusus action_type == 'SUBSTITUTION' ──
// Diisi null untuk seluruh action_type lainnya. Disimpan langsung di
// event (bukan dihitung ulang dari lineup) supaya Event Timeline bisa
// menampilkan "#7 OUT → #11 IN" tanpa query tambahan ke collection lain
// (lihat SDD Section 8.1 — prinsip immutability & self-contained event log).
  @override
  @JsonKey(name: 'sub_out_player_id')
  final String? subOutPlayerId;
  @override
  @JsonKey(name: 'sub_out_jersey')
  final int? subOutJersey;
  @override
  @JsonKey(name: 'sub_in_jersey')
  final int? subInJersey;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MatchEventModel(id: $id, quarter: $quarter, timeRemaining: $timeRemaining, playerId: $playerId, actionType: $actionType, value: $value, zone: $zone, shotX: $shotX, shotY: $shotY, shotDistanceFt: $shotDistanceFt, isOpponent: $isOpponent, isUndone: $isUndone, undoRefId: $undoRefId, subOutPlayerId: $subOutPlayerId, subOutJersey: $subOutJersey, subInJersey: $subInJersey, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.quarter, quarter) || other.quarter == quarter) &&
            (identical(other.timeRemaining, timeRemaining) ||
                other.timeRemaining == timeRemaining) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.shotX, shotX) || other.shotX == shotX) &&
            (identical(other.shotY, shotY) || other.shotY == shotY) &&
            (identical(other.shotDistanceFt, shotDistanceFt) ||
                other.shotDistanceFt == shotDistanceFt) &&
            (identical(other.isOpponent, isOpponent) ||
                other.isOpponent == isOpponent) &&
            (identical(other.isUndone, isUndone) ||
                other.isUndone == isUndone) &&
            (identical(other.undoRefId, undoRefId) ||
                other.undoRefId == undoRefId) &&
            (identical(other.subOutPlayerId, subOutPlayerId) ||
                other.subOutPlayerId == subOutPlayerId) &&
            (identical(other.subOutJersey, subOutJersey) ||
                other.subOutJersey == subOutJersey) &&
            (identical(other.subInJersey, subInJersey) ||
                other.subInJersey == subInJersey) &&
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
      quarter,
      timeRemaining,
      playerId,
      actionType,
      value,
      zone,
      shotX,
      shotY,
      shotDistanceFt,
      isOpponent,
      isUndone,
      undoRefId,
      subOutPlayerId,
      subOutJersey,
      subInJersey,
      createdBy,
      createdAt);

  /// Create a copy of MatchEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchEventModelImplCopyWith<_$MatchEventModelImpl> get copyWith =>
      __$$MatchEventModelImplCopyWithImpl<_$MatchEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchEventModelImplToJson(
      this,
    );
  }
}

abstract class _MatchEventModel implements MatchEventModel {
  const factory _MatchEventModel(
      {required final String id,
      required final int quarter,
      @JsonKey(name: 'time_remaining') required final double timeRemaining,
      @JsonKey(name: 'player_id') final String? playerId,
      @JsonKey(name: 'action_type') required final String actionType,
      final int value,
      final String? zone,
      @JsonKey(name: 'shot_x') final double? shotX,
      @JsonKey(name: 'shot_y') final double? shotY,
      @JsonKey(name: 'shot_distance_ft') final int? shotDistanceFt,
      @JsonKey(name: 'is_opponent') final bool isOpponent,
      @JsonKey(name: 'is_undone') final bool isUndone,
      @JsonKey(name: 'undo_ref_id') final String? undoRefId,
      @JsonKey(name: 'sub_out_player_id') final String? subOutPlayerId,
      @JsonKey(name: 'sub_out_jersey') final int? subOutJersey,
      @JsonKey(name: 'sub_in_jersey') final int? subInJersey,
      @JsonKey(name: 'created_by') required final String createdBy,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$MatchEventModelImpl;

  factory _MatchEventModel.fromJson(Map<String, dynamic> json) =
      _$MatchEventModelImpl.fromJson;

  @override
  String get id;
  @override
  int get quarter;
  @override
  @JsonKey(name: 'time_remaining')
  double get timeRemaining;
  @override
  @JsonKey(name: 'player_id')
  String? get playerId;
  @override
  @JsonKey(name: 'action_type')
  String get actionType;
  @override
  int get value;
  @override
  String? get zone;
  @override
  @JsonKey(name: 'shot_x')
  double? get shotX;
  @override
  @JsonKey(name: 'shot_y')
  double? get shotY;
  @override
  @JsonKey(name: 'shot_distance_ft')
  int? get shotDistanceFt;
  @override
  @JsonKey(name: 'is_opponent')
  bool get isOpponent;
  @override
  @JsonKey(name: 'is_undone')
  bool get isUndone;
  @override
  @JsonKey(name: 'undo_ref_id')
  String?
      get undoRefId; // ── BARU (Step 16) — konteks tambahan khusus action_type == 'SUBSTITUTION' ──
// Diisi null untuk seluruh action_type lainnya. Disimpan langsung di
// event (bukan dihitung ulang dari lineup) supaya Event Timeline bisa
// menampilkan "#7 OUT → #11 IN" tanpa query tambahan ke collection lain
// (lihat SDD Section 8.1 — prinsip immutability & self-contained event log).
  @override
  @JsonKey(name: 'sub_out_player_id')
  String? get subOutPlayerId;
  @override
  @JsonKey(name: 'sub_out_jersey')
  int? get subOutJersey;
  @override
  @JsonKey(name: 'sub_in_jersey')
  int? get subInJersey;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of MatchEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchEventModelImplCopyWith<_$MatchEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
