// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingSessionModelImpl _$$TrainingSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingSessionModelImpl(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      title: json['title'] as String,
      sessionType: json['session_type'] as String,
      scheduledAt:
          const TimestampDateTimeConverter().fromJson(json['scheduled_at']),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      location: json['location'] as String,
      description: json['description'] as String,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$TrainingSessionModelImplToJson(
        _$TrainingSessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'title': instance.title,
      'session_type': instance.sessionType,
      'scheduled_at':
          const TimestampDateTimeConverter().toJson(instance.scheduledAt),
      'duration_minutes': instance.durationMinutes,
      'location': instance.location,
      'description': instance.description,
      'is_cancelled': instance.isCancelled,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
