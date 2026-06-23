// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      uid: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      teamId: json['team_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      trustedDeviceIds: (json['trusted_device_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'email': instance.email,
      'full_name': instance.fullName,
      'role': instance.role,
      'team_id': instance.teamId,
      'is_active': instance.isActive,
      'trusted_device_ids': instance.trustedDeviceIds,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
