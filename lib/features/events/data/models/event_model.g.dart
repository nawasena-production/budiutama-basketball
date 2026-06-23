// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventModelImpl _$$EventModelImplFromJson(Map<String, dynamic> json) =>
    _$EventModelImpl(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      name: json['name'] as String,
      organizer: json['organizer'] as String,
      eventType: json['event_type'] as String,
      location: json['location'] as String,
      startDate:
          const TimestampDateTimeConverter().fromJson(json['start_date']),
      endDate: const TimestampDateTimeConverter().fromJson(json['end_date']),
      academicYear: json['academic_year'] as String,
      status: json['status'] as String? ?? 'upcoming',
      notes: json['notes'] as String? ?? '',
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$EventModelImplToJson(_$EventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'team_id': instance.teamId,
      'name': instance.name,
      'organizer': instance.organizer,
      'event_type': instance.eventType,
      'location': instance.location,
      'start_date':
          const TimestampDateTimeConverter().toJson(instance.startDate),
      'end_date': const TimestampDateTimeConverter().toJson(instance.endDate),
      'academic_year': instance.academicYear,
      'status': instance.status,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
