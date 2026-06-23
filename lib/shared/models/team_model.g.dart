// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamModelImpl _$$TeamModelImplFromJson(Map<String, dynamic> json) =>
    _$TeamModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      academicYear: json['academic_year'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$TeamModelImplToJson(_$TeamModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gender': instance.gender,
      'academic_year': instance.academicYear,
      'is_active': instance.isActive,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
    };
