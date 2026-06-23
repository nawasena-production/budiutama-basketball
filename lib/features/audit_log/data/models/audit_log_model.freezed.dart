// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) {
  return _AuditLogModel.fromJson(json);
}

/// @nodoc
mixin _$AuditLogModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'action_type')
  String get actionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'entity_type')
  String get entityType => throw _privateConstructorUsedError;
  @JsonKey(name: 'entity_id')
  String? get entityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'old_value')
  Map<String, dynamic>? get oldValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_value')
  Map<String, dynamic>? get newValue => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AuditLogModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogModelCopyWith<AuditLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogModelCopyWith<$Res> {
  factory $AuditLogModelCopyWith(
          AuditLogModel value, $Res Function(AuditLogModel) then) =
      _$AuditLogModelCopyWithImpl<$Res, AuditLogModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String? role,
      @JsonKey(name: 'action_type') String actionType,
      @JsonKey(name: 'entity_type') String entityType,
      @JsonKey(name: 'entity_id') String? entityId,
      @JsonKey(name: 'old_value') Map<String, dynamic>? oldValue,
      @JsonKey(name: 'new_value') Map<String, dynamic>? newValue,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class _$AuditLogModelCopyWithImpl<$Res, $Val extends AuditLogModel>
    implements $AuditLogModelCopyWith<$Res> {
  _$AuditLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? role = freezed,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = freezed,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: freezed == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String?,
      oldValue: freezed == oldValue
          ? _value.oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _value.newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditLogModelImplCopyWith<$Res>
    implements $AuditLogModelCopyWith<$Res> {
  factory _$$AuditLogModelImplCopyWith(
          _$AuditLogModelImpl value, $Res Function(_$AuditLogModelImpl) then) =
      __$$AuditLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String? role,
      @JsonKey(name: 'action_type') String actionType,
      @JsonKey(name: 'entity_type') String entityType,
      @JsonKey(name: 'entity_id') String? entityId,
      @JsonKey(name: 'old_value') Map<String, dynamic>? oldValue,
      @JsonKey(name: 'new_value') Map<String, dynamic>? newValue,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      DateTime? createdAt});
}

/// @nodoc
class __$$AuditLogModelImplCopyWithImpl<$Res>
    extends _$AuditLogModelCopyWithImpl<$Res, _$AuditLogModelImpl>
    implements _$$AuditLogModelImplCopyWith<$Res> {
  __$$AuditLogModelImplCopyWithImpl(
      _$AuditLogModelImpl _value, $Res Function(_$AuditLogModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? role = freezed,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = freezed,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$AuditLogModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: freezed == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String?,
      oldValue: freezed == oldValue
          ? _value._oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      newValue: freezed == newValue
          ? _value._newValue
          : newValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogModelImpl implements _AuditLogModel {
  const _$AuditLogModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      this.role,
      @JsonKey(name: 'action_type') required this.actionType,
      @JsonKey(name: 'entity_type') required this.entityType,
      @JsonKey(name: 'entity_id') this.entityId,
      @JsonKey(name: 'old_value') final Map<String, dynamic>? oldValue,
      @JsonKey(name: 'new_value') final Map<String, dynamic>? newValue,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      this.createdAt})
      : _oldValue = oldValue,
        _newValue = newValue;

  factory _$AuditLogModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String? role;
  @override
  @JsonKey(name: 'action_type')
  final String actionType;
  @override
  @JsonKey(name: 'entity_type')
  final String entityType;
  @override
  @JsonKey(name: 'entity_id')
  final String? entityId;
  final Map<String, dynamic>? _oldValue;
  @override
  @JsonKey(name: 'old_value')
  Map<String, dynamic>? get oldValue {
    final value = _oldValue;
    if (value == null) return null;
    if (_oldValue is EqualUnmodifiableMapView) return _oldValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValue;
  @override
  @JsonKey(name: 'new_value')
  Map<String, dynamic>? get newValue {
    final value = _newValue;
    if (value == null) return null;
    if (_newValue is EqualUnmodifiableMapView) return _newValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AuditLogModel(id: $id, userId: $userId, role: $role, actionType: $actionType, entityType: $entityType, entityId: $entityId, oldValue: $oldValue, newValue: $newValue, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._oldValue, _oldValue) &&
            const DeepCollectionEquality().equals(other._newValue, _newValue) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      role,
      actionType,
      entityType,
      entityId,
      const DeepCollectionEquality().hash(_oldValue),
      const DeepCollectionEquality().hash(_newValue),
      createdAt);

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogModelImplCopyWith<_$AuditLogModelImpl> get copyWith =>
      __$$AuditLogModelImplCopyWithImpl<_$AuditLogModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogModelImplToJson(
      this,
    );
  }
}

abstract class _AuditLogModel implements AuditLogModel {
  const factory _AuditLogModel(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      final String? role,
      @JsonKey(name: 'action_type') required final String actionType,
      @JsonKey(name: 'entity_type') required final String entityType,
      @JsonKey(name: 'entity_id') final String? entityId,
      @JsonKey(name: 'old_value') final Map<String, dynamic>? oldValue,
      @JsonKey(name: 'new_value') final Map<String, dynamic>? newValue,
      @TimestampDateTimeConverter()
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$AuditLogModelImpl;

  factory _AuditLogModel.fromJson(Map<String, dynamic> json) =
      _$AuditLogModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String? get role;
  @override
  @JsonKey(name: 'action_type')
  String get actionType;
  @override
  @JsonKey(name: 'entity_type')
  String get entityType;
  @override
  @JsonKey(name: 'entity_id')
  String? get entityId;
  @override
  @JsonKey(name: 'old_value')
  Map<String, dynamic>? get oldValue;
  @override
  @JsonKey(name: 'new_value')
  Map<String, dynamic>? get newValue;
  @override
  @TimestampDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of AuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogModelImplCopyWith<_$AuditLogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
