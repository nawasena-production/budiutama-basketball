// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineupModelImpl _$$LineupModelImplFromJson(Map<String, dynamic> json) =>
    _$LineupModelImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      fullName: json['full_name'] as String,
      jerseyNumber: (json['jersey_number'] as num).toInt(),
      position: json['position'] as String,
      isStarter: json['is_starter'] as bool? ?? false,
      isOnCourt: json['is_on_court'] as bool? ?? false,
      enteredAtClock: (json['entered_at_clock'] as num?)?.toDouble(),
      enteredAtQuarter: (json['entered_at_quarter'] as num?)?.toInt(),
      totalSecondsPlayed: (json['total_seconds_played'] as num?)?.toInt() ?? 0,
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$LineupModelImplToJson(_$LineupModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'full_name': instance.fullName,
      'jersey_number': instance.jerseyNumber,
      'position': instance.position,
      'is_starter': instance.isStarter,
      'is_on_court': instance.isOnCourt,
      'entered_at_clock': instance.enteredAtClock,
      'entered_at_quarter': instance.enteredAtQuarter,
      'total_seconds_played': instance.totalSecondsPlayed,
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
