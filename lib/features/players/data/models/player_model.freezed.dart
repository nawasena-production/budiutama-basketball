// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) {
  return _PlayerModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_id')
  String get teamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'positions', readValue: _readPositions)
  List<String> get positions => throw _privateConstructorUsedError;
  @JsonKey(name: 'height_cm')
  double? get heightCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg')
  double? get weightKg => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_base64')
  String? get photoBase64 => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerModelCopyWith<PlayerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerModelCopyWith<$Res> {
  factory $PlayerModelCopyWith(
          PlayerModel value, $Res Function(PlayerModel) then) =
      _$PlayerModelCopyWithImpl<$Res, PlayerModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'team_id') String teamId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      @JsonKey(name: 'positions', readValue: _readPositions)
      List<String> positions,
      @JsonKey(name: 'height_cm') double? heightCm,
      @JsonKey(name: 'weight_kg') double? weightKg,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'date_of_birth')
      DateTime? dateOfBirth,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      String status,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$PlayerModelCopyWithImpl<$Res, $Val extends PlayerModel>
    implements $PlayerModelCopyWith<$Res> {
  _$PlayerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? teamId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? positions = null,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? dateOfBirth = freezed,
    Object? photoUrl = freezed,
    Object? photoBase64 = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      positions: null == positions
          ? _value.positions
          : positions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PlayerModelImplCopyWith<$Res>
    implements $PlayerModelCopyWith<$Res> {
  factory _$$PlayerModelImplCopyWith(
          _$PlayerModelImpl value, $Res Function(_$PlayerModelImpl) then) =
      __$$PlayerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'team_id') String teamId,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'jersey_number') int jerseyNumber,
      @JsonKey(name: 'positions', readValue: _readPositions)
      List<String> positions,
      @JsonKey(name: 'height_cm') double? heightCm,
      @JsonKey(name: 'weight_kg') double? weightKg,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'date_of_birth')
      DateTime? dateOfBirth,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      String status,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlayerModelImplCopyWithImpl<$Res>
    extends _$PlayerModelCopyWithImpl<$Res, _$PlayerModelImpl>
    implements _$$PlayerModelImplCopyWith<$Res> {
  __$$PlayerModelImplCopyWithImpl(
      _$PlayerModelImpl _value, $Res Function(_$PlayerModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? teamId = null,
    Object? fullName = null,
    Object? jerseyNumber = null,
    Object? positions = null,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? dateOfBirth = freezed,
    Object? photoUrl = freezed,
    Object? photoBase64 = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlayerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      teamId: null == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      jerseyNumber: null == jerseyNumber
          ? _value.jerseyNumber
          : jerseyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      positions: null == positions
          ? _value._positions
          : positions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
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
class _$PlayerModelImpl extends _PlayerModel {
  const _$PlayerModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'team_id') required this.teamId,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'jersey_number') required this.jerseyNumber,
      @JsonKey(name: 'positions', readValue: _readPositions)
      final List<String> positions = const [],
      @JsonKey(name: 'height_cm') this.heightCm,
      @JsonKey(name: 'weight_kg') this.weightKg,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'date_of_birth')
      this.dateOfBirth,
      @JsonKey(name: 'photo_url') this.photoUrl,
      @JsonKey(name: 'photo_base64') this.photoBase64,
      this.status = 'active',
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt})
      : _positions = positions,
        super._();

  factory _$PlayerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'team_id')
  final String teamId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'jersey_number')
  final int jerseyNumber;
  final List<String> _positions;
  @override
  @JsonKey(name: 'positions', readValue: _readPositions)
  List<String> get positions {
    if (_positions is EqualUnmodifiableListView) return _positions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_positions);
  }

  @override
  @JsonKey(name: 'height_cm')
  final double? heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  final double? weightKg;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  @JsonKey(name: 'photo_base64')
  final String? photoBase64;
  @override
  @JsonKey()
  final String status;
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
    return 'PlayerModel(id: $id, userId: $userId, teamId: $teamId, fullName: $fullName, jerseyNumber: $jerseyNumber, positions: $positions, heightCm: $heightCm, weightKg: $weightKg, dateOfBirth: $dateOfBirth, photoUrl: $photoUrl, photoBase64: $photoBase64, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.jerseyNumber, jerseyNumber) ||
                other.jerseyNumber == jerseyNumber) &&
            const DeepCollectionEquality()
                .equals(other._positions, _positions) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.status, status) || other.status == status) &&
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
      userId,
      teamId,
      fullName,
      jerseyNumber,
      const DeepCollectionEquality().hash(_positions),
      heightCm,
      weightKg,
      dateOfBirth,
      photoUrl,
      photoBase64,
      status,
      createdAt,
      updatedAt);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      __$$PlayerModelImplCopyWithImpl<_$PlayerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerModelImplToJson(
      this,
    );
  }
}

abstract class _PlayerModel extends PlayerModel {
  const factory _PlayerModel(
      {required final String id,
      @JsonKey(name: 'user_id') final String? userId,
      @JsonKey(name: 'team_id') required final String teamId,
      @JsonKey(name: 'full_name') required final String fullName,
      @JsonKey(name: 'jersey_number') required final int jerseyNumber,
      @JsonKey(name: 'positions', readValue: _readPositions)
      final List<String> positions,
      @JsonKey(name: 'height_cm') final double? heightCm,
      @JsonKey(name: 'weight_kg') final double? weightKg,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'date_of_birth')
      final DateTime? dateOfBirth,
      @JsonKey(name: 'photo_url') final String? photoUrl,
      @JsonKey(name: 'photo_base64') final String? photoBase64,
      final String status,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$PlayerModelImpl;
  const _PlayerModel._() : super._();

  factory _PlayerModel.fromJson(Map<String, dynamic> json) =
      _$PlayerModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'team_id')
  String get teamId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'jersey_number')
  int get jerseyNumber;
  @override
  @JsonKey(name: 'positions', readValue: _readPositions)
  List<String> get positions;
  @override
  @JsonKey(name: 'height_cm')
  double? get heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  double? get weightKg;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  @JsonKey(name: 'photo_base64')
  String? get photoBase64;
  @override
  String get status;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
