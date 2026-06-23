// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injury_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InjuryReportModelImpl _$$InjuryReportModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InjuryReportModelImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      teamId: json['team_id'] as String,
      injuryDate:
          const TimestampDateTimeConverter().fromJson(json['injury_date']),
      bodyPart: json['body_part'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      estimatedRecoveryDays: (json['estimated_recovery_days'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'active',
      photoUrl: json['photo_url'] as String?,
      photoBase64: json['photo_base64'] as String?,
      clearedAt:
          const TimestampDateTimeConverter().fromJson(json['cleared_at']),
      notes: json['notes'] as String? ?? '',
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$InjuryReportModelImplToJson(
        _$InjuryReportModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'team_id': instance.teamId,
      'injury_date':
          const TimestampDateTimeConverter().toJson(instance.injuryDate),
      'body_part': instance.bodyPart,
      'severity': instance.severity,
      'description': instance.description,
      'estimated_recovery_days': instance.estimatedRecoveryDays,
      'status': instance.status,
      'photo_url': instance.photoUrl,
      'photo_base64': instance.photoBase64,
      'cleared_at':
          const TimestampDateTimeConverter().toJson(instance.clearedAt),
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
