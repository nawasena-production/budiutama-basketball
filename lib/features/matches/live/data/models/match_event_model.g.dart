// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchEventModelImpl _$$MatchEventModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchEventModelImpl(
      id: json['id'] as String,
      quarter: (json['quarter'] as num).toInt(),
      timeRemaining: (json['time_remaining'] as num).toDouble(),
      playerId: json['player_id'] as String?,
      actionType: json['action_type'] as String,
      value: (json['value'] as num?)?.toInt() ?? 0,
      zone: json['zone'] as String?,
      shotX: (json['shot_x'] as num?)?.toDouble(),
      shotY: (json['shot_y'] as num?)?.toDouble(),
      shotDistanceFt: (json['shot_distance_ft'] as num?)?.toInt(),
      isOpponent: json['is_opponent'] as bool? ?? false,
      isUndone: json['is_undone'] as bool? ?? false,
      undoRefId: json['undo_ref_id'] as String?,
      subOutPlayerId: json['sub_out_player_id'] as String?,
      subOutJersey: (json['sub_out_jersey'] as num?)?.toInt(),
      subInJersey: (json['sub_in_jersey'] as num?)?.toInt(),
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$MatchEventModelImplToJson(
        _$MatchEventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quarter': instance.quarter,
      'time_remaining': instance.timeRemaining,
      'player_id': instance.playerId,
      'action_type': instance.actionType,
      'value': instance.value,
      'zone': instance.zone,
      'shot_x': instance.shotX,
      'shot_y': instance.shotY,
      'shot_distance_ft': instance.shotDistanceFt,
      'is_opponent': instance.isOpponent,
      'is_undone': instance.isUndone,
      'undo_ref_id': instance.undoRefId,
      'sub_out_player_id': instance.subOutPlayerId,
      'sub_out_jersey': instance.subOutJersey,
      'sub_in_jersey': instance.subInJersey,
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
    };
