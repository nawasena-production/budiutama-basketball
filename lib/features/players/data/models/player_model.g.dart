// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerModelImpl _$$PlayerModelImplFromJson(Map<String, dynamic> json) =>
    _$PlayerModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      teamId: json['team_id'] as String,
      fullName: json['full_name'] as String,
      jerseyNumber: (json['jersey_number'] as num).toInt(),
      positions: (_readPositions(json, 'positions') as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      dateOfBirth:
          const TimestampDateTimeConverter().fromJson(json['date_of_birth']),
      photoUrl: json['photo_url'] as String?,
      photoBase64: json['photo_base64'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$PlayerModelImplToJson(_$PlayerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'full_name': instance.fullName,
      'jersey_number': instance.jerseyNumber,
      'positions': instance.positions,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'date_of_birth':
          const TimestampDateTimeConverter().toJson(instance.dateOfBirth),
      'photo_url': instance.photoUrl,
      'photo_base64': instance.photoBase64,
      'status': instance.status,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
