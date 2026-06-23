// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimerStateModel _$TimerStateModelFromJson(Map<String, dynamic> json) {
  return _TimerStateModel.fromJson(json);
}

/// @nodoc
mixin _$TimerStateModel {
  @JsonKey(name: 'is_running')
  bool get isRunning => throw _privateConstructorUsedError;
  @JsonKey(name: 'seconds_at_start')
  double get secondsAtStart => throw _privateConstructorUsedError;
  @FirestoreTimestampConverter()
  @JsonKey(name: 'started_at')
  Timestamp? get startedAt => throw _privateConstructorUsedError;
  int get quarter => throw _privateConstructorUsedError;

  /// Serializes this TimerStateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateModelCopyWith<TimerStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateModelCopyWith<$Res> {
  factory $TimerStateModelCopyWith(
          TimerStateModel value, $Res Function(TimerStateModel) then) =
      _$TimerStateModelCopyWithImpl<$Res, TimerStateModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'is_running') bool isRunning,
      @JsonKey(name: 'seconds_at_start') double secondsAtStart,
      @FirestoreTimestampConverter()
      @JsonKey(name: 'started_at')
      Timestamp? startedAt,
      int quarter});
}

/// @nodoc
class _$TimerStateModelCopyWithImpl<$Res, $Val extends TimerStateModel>
    implements $TimerStateModelCopyWith<$Res> {
  _$TimerStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRunning = null,
    Object? secondsAtStart = null,
    Object? startedAt = freezed,
    Object? quarter = null,
  }) {
    return _then(_value.copyWith(
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      secondsAtStart: null == secondsAtStart
          ? _value.secondsAtStart
          : secondsAtStart // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      quarter: null == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerStateModelImplCopyWith<$Res>
    implements $TimerStateModelCopyWith<$Res> {
  factory _$$TimerStateModelImplCopyWith(_$TimerStateModelImpl value,
          $Res Function(_$TimerStateModelImpl) then) =
      __$$TimerStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'is_running') bool isRunning,
      @JsonKey(name: 'seconds_at_start') double secondsAtStart,
      @FirestoreTimestampConverter()
      @JsonKey(name: 'started_at')
      Timestamp? startedAt,
      int quarter});
}

/// @nodoc
class __$$TimerStateModelImplCopyWithImpl<$Res>
    extends _$TimerStateModelCopyWithImpl<$Res, _$TimerStateModelImpl>
    implements _$$TimerStateModelImplCopyWith<$Res> {
  __$$TimerStateModelImplCopyWithImpl(
      _$TimerStateModelImpl _value, $Res Function(_$TimerStateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRunning = null,
    Object? secondsAtStart = null,
    Object? startedAt = freezed,
    Object? quarter = null,
  }) {
    return _then(_$TimerStateModelImpl(
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      secondsAtStart: null == secondsAtStart
          ? _value.secondsAtStart
          : secondsAtStart // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      quarter: null == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimerStateModelImpl implements _TimerStateModel {
  const _$TimerStateModelImpl(
      {@JsonKey(name: 'is_running') this.isRunning = false,
      @JsonKey(name: 'seconds_at_start') this.secondsAtStart = 600.0,
      @FirestoreTimestampConverter()
      @JsonKey(name: 'started_at')
      this.startedAt,
      this.quarter = 1});

  factory _$TimerStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimerStateModelImplFromJson(json);

  @override
  @JsonKey(name: 'is_running')
  final bool isRunning;
  @override
  @JsonKey(name: 'seconds_at_start')
  final double secondsAtStart;
  @override
  @FirestoreTimestampConverter()
  @JsonKey(name: 'started_at')
  final Timestamp? startedAt;
  @override
  @JsonKey()
  final int quarter;

  @override
  String toString() {
    return 'TimerStateModel(isRunning: $isRunning, secondsAtStart: $secondsAtStart, startedAt: $startedAt, quarter: $quarter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateModelImpl &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.secondsAtStart, secondsAtStart) ||
                other.secondsAtStart == secondsAtStart) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.quarter, quarter) || other.quarter == quarter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isRunning, secondsAtStart, startedAt, quarter);

  /// Create a copy of TimerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateModelImplCopyWith<_$TimerStateModelImpl> get copyWith =>
      __$$TimerStateModelImplCopyWithImpl<_$TimerStateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerStateModelImplToJson(
      this,
    );
  }
}

abstract class _TimerStateModel implements TimerStateModel {
  const factory _TimerStateModel(
      {@JsonKey(name: 'is_running') final bool isRunning,
      @JsonKey(name: 'seconds_at_start') final double secondsAtStart,
      @FirestoreTimestampConverter()
      @JsonKey(name: 'started_at')
      final Timestamp? startedAt,
      final int quarter}) = _$TimerStateModelImpl;

  factory _TimerStateModel.fromJson(Map<String, dynamic> json) =
      _$TimerStateModelImpl.fromJson;

  @override
  @JsonKey(name: 'is_running')
  bool get isRunning;
  @override
  @JsonKey(name: 'seconds_at_start')
  double get secondsAtStart;
  @override
  @FirestoreTimestampConverter()
  @JsonKey(name: 'started_at')
  Timestamp? get startedAt;
  @override
  int get quarter;

  /// Create a copy of TimerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateModelImplCopyWith<_$TimerStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
