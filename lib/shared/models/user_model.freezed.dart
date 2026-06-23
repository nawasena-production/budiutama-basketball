// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // BARU (Step 12) — opsional agar tetap backward-compatible dengan
// dokumen users/ lama yang belum memiliki field ini.
  @JsonKey(name: 'team_id')
  String? get teamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'trusted_device_ids')
  List<String> get trustedDeviceIds => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String uid,
      String email,
      @JsonKey(name: 'full_name') String fullName,
      String role,
      @JsonKey(name: 'team_id') String? teamId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'trusted_device_ids') List<String> trustedDeviceIds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uid = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? teamId = freezed,
    Object? isActive = null,
    Object? trustedDeviceIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: freezed == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      trustedDeviceIds: null == trustedDeviceIds
          ? _value.trustedDeviceIds
          : trustedDeviceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String uid,
      String email,
      @JsonKey(name: 'full_name') String fullName,
      String role,
      @JsonKey(name: 'team_id') String? teamId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'trusted_device_ids') List<String> trustedDeviceIds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      DateTime? updatedAt});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uid = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = null,
    Object? teamId = freezed,
    Object? isActive = null,
    Object? trustedDeviceIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      teamId: freezed == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      trustedDeviceIds: null == trustedDeviceIds
          ? _value._trustedDeviceIds
          : trustedDeviceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.uid,
      required this.email,
      @JsonKey(name: 'full_name') required this.fullName,
      required this.role,
      @JsonKey(name: 'team_id') this.teamId,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'trusted_device_ids')
      final List<String> trustedDeviceIds = const [],
      @TimestampDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      this.updatedAt})
      : _trustedDeviceIds = trustedDeviceIds;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String uid;
  @override
  final String email;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String role;
// BARU (Step 12) — opsional agar tetap backward-compatible dengan
// dokumen users/ lama yang belum memiliki field ini.
  @override
  @JsonKey(name: 'team_id')
  final String? teamId;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<String> _trustedDeviceIds;
  @override
  @JsonKey(name: 'trusted_device_ids')
  List<String> get trustedDeviceIds {
    if (_trustedDeviceIds is EqualUnmodifiableListView)
      return _trustedDeviceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trustedDeviceIds);
  }

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
    return 'UserModel(id: $id, uid: $uid, email: $email, fullName: $fullName, role: $role, teamId: $teamId, isActive: $isActive, trustedDeviceIds: $trustedDeviceIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._trustedDeviceIds, _trustedDeviceIds) &&
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
      uid,
      email,
      fullName,
      role,
      teamId,
      isActive,
      const DeepCollectionEquality().hash(_trustedDeviceIds),
      createdAt,
      updatedAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final String id,
      required final String uid,
      required final String email,
      @JsonKey(name: 'full_name') required final String fullName,
      required final String role,
      @JsonKey(name: 'team_id') final String? teamId,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'trusted_device_ids') final List<String> trustedDeviceIds,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get uid;
  @override
  String get email;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String
      get role; // BARU (Step 12) — opsional agar tetap backward-compatible dengan
// dokumen users/ lama yang belum memiliki field ini.
  @override
  @JsonKey(name: 'team_id')
  String? get teamId;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'trusted_device_ids')
  List<String> get trustedDeviceIds;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
