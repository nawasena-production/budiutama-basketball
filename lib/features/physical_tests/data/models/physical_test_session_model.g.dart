// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_test_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhysicalTestSessionModelImpl _$$PhysicalTestSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PhysicalTestSessionModelImpl(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      testType: json['test_type'] as String,
      scheduledAt:
          const TimestampDateTimeConverter().fromJson(json['scheduled_at']),
      academicYear: json['academic_year'] as String,
      semester: (json['semester'] as num).toInt(),
      notes: json['notes'] as String? ?? '',
      isStoppedEarly: json['is_stopped_early'] as bool? ?? false,
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$PhysicalTestSessionModelImplToJson(
        _$PhysicalTestSessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'test_type': instance.testType,
      'scheduled_at':
          const TimestampDateTimeConverter().toJson(instance.scheduledAt),
      'academic_year': instance.academicYear,
      'semester': instance.semester,
      'notes': instance.notes,
      'is_stopped_early': instance.isStoppedEarly,
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
    };
