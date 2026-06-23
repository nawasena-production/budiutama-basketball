// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'physical_test_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhysicalTestResultModel _$PhysicalTestResultModelFromJson(
    Map<String, dynamic> json) {
  return _PhysicalTestResultModel.fromJson(json);
}

/// @nodoc
mixin _$PhysicalTestResultModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_id')
  String get playerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'beep_level')
  int? get beepLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'beep_shuttle')
  int? get beepShuttle => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_seconds')
  double? get timeSeconds => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PhysicalTestResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhysicalTestResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhysicalTestResultModelCopyWith<PhysicalTestResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhysicalTestResultModelCopyWith<$Res> {
  factory $PhysicalTestResultModelCopyWith(PhysicalTestResultModel value,
          $Res Function(PhysicalTestResultModel) then) =
      _$PhysicalTestResultModelCopyWithImpl<$Res, PhysicalTestResultModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'beep_level') int? beepLevel,
      @JsonKey(name: 'beep_shuttle') int? beepShuttle,
      @JsonKey(name: 'time_seconds') double? timeSeconds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class _$PhysicalTestResultModelCopyWithImpl<$Res,
        $Val extends PhysicalTestResultModel>
    implements $PhysicalTestResultModelCopyWith<$Res> {
  _$PhysicalTestResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhysicalTestResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? beepLevel = freezed,
    Object? beepShuttle = freezed,
    Object? timeSeconds = freezed,
    Object? createdAt = freezed,
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
      beepLevel: freezed == beepLevel
          ? _value.beepLevel
          : beepLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      beepShuttle: freezed == beepShuttle
          ? _value.beepShuttle
          : beepShuttle // ignore: cast_nullable_to_non_nullable
              as int?,
      timeSeconds: freezed == timeSeconds
          ? _value.timeSeconds
          : timeSeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhysicalTestResultModelImplCopyWith<$Res>
    implements $PhysicalTestResultModelCopyWith<$Res> {
  factory _$$PhysicalTestResultModelImplCopyWith(
          _$PhysicalTestResultModelImpl value,
          $Res Function(_$PhysicalTestResultModelImpl) then) =
      __$$PhysicalTestResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'player_id') String playerId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'beep_level') int? beepLevel,
      @JsonKey(name: 'beep_shuttle') int? beepShuttle,
      @JsonKey(name: 'time_seconds') double? timeSeconds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class __$$PhysicalTestResultModelImplCopyWithImpl<$Res>
    extends _$PhysicalTestResultModelCopyWithImpl<$Res,
        _$PhysicalTestResultModelImpl>
    implements _$$PhysicalTestResultModelImplCopyWith<$Res> {
  __$$PhysicalTestResultModelImplCopyWithImpl(
      _$PhysicalTestResultModelImpl _value,
      $Res Function(_$PhysicalTestResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhysicalTestResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? fullName = null,
    Object? beepLevel = freezed,
    Object? beepShuttle = freezed,
    Object? timeSeconds = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PhysicalTestResultModelImpl(
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
      beepLevel: freezed == beepLevel
          ? _value.beepLevel
          : beepLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      beepShuttle: freezed == beepShuttle
          ? _value.beepShuttle
          : beepShuttle // ignore: cast_nullable_to_non_nullable
              as int?,
      timeSeconds: freezed == timeSeconds
          ? _value.timeSeconds
          : timeSeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhysicalTestResultModelImpl implements _PhysicalTestResultModel {
  const _$PhysicalTestResultModelImpl(
      {required this.id,
      @JsonKey(name: 'player_id') required this.playerId,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'beep_level') this.beepLevel,
      @JsonKey(name: 'beep_shuttle') this.beepShuttle,
      @JsonKey(name: 'time_seconds') this.timeSeconds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      this.createdAt});

  factory _$PhysicalTestResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhysicalTestResultModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'player_id')
  final String playerId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'beep_level')
  final int? beepLevel;
  @override
  @JsonKey(name: 'beep_shuttle')
  final int? beepShuttle;
  @override
  @JsonKey(name: 'time_seconds')
  final double? timeSeconds;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PhysicalTestResultModel(id: $id, playerId: $playerId, fullName: $fullName, beepLevel: $beepLevel, beepShuttle: $beepShuttle, timeSeconds: $timeSeconds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhysicalTestResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.beepLevel, beepLevel) ||
                other.beepLevel == beepLevel) &&
            (identical(other.beepShuttle, beepShuttle) ||
                other.beepShuttle == beepShuttle) &&
            (identical(other.timeSeconds, timeSeconds) ||
                other.timeSeconds == timeSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, playerId, fullName,
      beepLevel, beepShuttle, timeSeconds, createdAt);

  /// Create a copy of PhysicalTestResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhysicalTestResultModelImplCopyWith<_$PhysicalTestResultModelImpl>
      get copyWith => __$$PhysicalTestResultModelImplCopyWithImpl<
          _$PhysicalTestResultModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhysicalTestResultModelImplToJson(
      this,
    );
  }
}

abstract class _PhysicalTestResultModel implements PhysicalTestResultModel {
  const factory _PhysicalTestResultModel(
      {required final String id,
      @JsonKey(name: 'player_id') required final String playerId,
      @JsonKey(name: 'full_name') required final String fullName,
      @JsonKey(name: 'beep_level') final int? beepLevel,
      @JsonKey(name: 'beep_shuttle') final int? beepShuttle,
      @JsonKey(name: 'time_seconds') final double? timeSeconds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$PhysicalTestResultModelImpl;

  factory _PhysicalTestResultModel.fromJson(Map<String, dynamic> json) =
      _$PhysicalTestResultModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'player_id')
  String get playerId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'beep_level')
  int? get beepLevel;
  @override
  @JsonKey(name: 'beep_shuttle')
  int? get beepShuttle;
  @override
  @JsonKey(name: 'time_seconds')
  double? get timeSeconds;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of PhysicalTestResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhysicalTestResultModelImplCopyWith<_$PhysicalTestResultModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
