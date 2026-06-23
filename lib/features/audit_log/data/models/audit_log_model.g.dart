// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogModelImpl _$$AuditLogModelImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String?,
      actionType: json['action_type'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$AuditLogModelImplToJson(_$AuditLogModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'role': instance.role,
      'action_type': instance.actionType,
      'entity_type': instance.entityType,
      'entity_id': instance.entityId,
      'old_value': instance.oldValue,
      'new_value': instance.newValue,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
    };
