// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerStatsModelImpl _$$PlayerStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlayerStatsModelImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      fullName: json['full_name'] as String,
      jerseyNumber: (json['jersey_number'] as num).toInt(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      ftMade: (json['ft_made'] as num?)?.toInt() ?? 0,
      ftAttempted: (json['ft_attempted'] as num?)?.toInt() ?? 0,
      fg2Made: (json['fg2_made'] as num?)?.toInt() ?? 0,
      fg2Attempted: (json['fg2_attempted'] as num?)?.toInt() ?? 0,
      fg3Made: (json['fg3_made'] as num?)?.toInt() ?? 0,
      fg3Attempted: (json['fg3_attempted'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      offensiveRebounds: (json['offensive_rebounds'] as num?)?.toInt() ?? 0,
      defensiveRebounds: (json['defensive_rebounds'] as num?)?.toInt() ?? 0,
      steals: (json['steals'] as num?)?.toInt() ?? 0,
      turnovers: (json['turnovers'] as num?)?.toInt() ?? 0,
      blocks: (json['blocks'] as num?)?.toInt() ?? 0,
      fouls: (json['fouls'] as num?)?.toInt() ?? 0,
      shotZones: json['shot_zones'] as Map<String, dynamic>? ?? const {},
      totalSecondsPlayed: (json['total_seconds_played'] as num?)?.toInt() ?? 0,
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$PlayerStatsModelImplToJson(
        _$PlayerStatsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'full_name': instance.fullName,
      'jersey_number': instance.jerseyNumber,
      'points': instance.points,
      'ft_made': instance.ftMade,
      'ft_attempted': instance.ftAttempted,
      'fg2_made': instance.fg2Made,
      'fg2_attempted': instance.fg2Attempted,
      'fg3_made': instance.fg3Made,
      'fg3_attempted': instance.fg3Attempted,
      'assists': instance.assists,
      'offensive_rebounds': instance.offensiveRebounds,
      'defensive_rebounds': instance.defensiveRebounds,
      'steals': instance.steals,
      'turnovers': instance.turnovers,
      'blocks': instance.blocks,
      'fouls': instance.fouls,
      'shot_zones': instance.shotZones,
      'total_seconds_played': instance.totalSecondsPlayed,
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
