// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchModelImpl _$$MatchModelImplFromJson(Map<String, dynamic> json) =>
    _$MatchModelImpl(
      id: json['id'] as String,
      homeTeamId: json['home_team_id'] as String,
      eventId: json['event_id'] as String,
      opponentName: json['opponent_name'] as String,
      venue: json['venue'] as String,
      matchType: json['match_type'] as String,
      phase: json['phase'] as String,
      scheduledAt:
          const TimestampDateTimeConverter().fromJson(json['scheduled_at']),
      status: json['status'] as String? ?? 'scheduled',
      currentState: json['current_state'] as String? ?? 'PRE_MATCH',
      homeScore: (json['home_score'] as num?)?.toInt() ?? 0,
      opponentScore: (json['opponent_score'] as num?)?.toInt() ?? 0,
      quarterDurationMinutes:
          (json['quarter_duration_minutes'] as num?)?.toInt() ?? 10,
      numPeriods: (json['num_periods'] as num?)?.toInt() ?? 4,
      otDurationMinutes: (json['ot_duration_minutes'] as num?)?.toInt() ?? 5,
      timerConfigLocked: json['timer_config_locked'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      startedAt:
          const TimestampDateTimeConverter().fromJson(json['started_at']),
      finishedAt:
          const TimestampDateTimeConverter().fromJson(json['finished_at']),
      createdBy: json['created_by'] as String,
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
      updatedAt:
          const TimestampDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$MatchModelImplToJson(_$MatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'home_team_id': instance.homeTeamId,
      'event_id': instance.eventId,
      'opponent_name': instance.opponentName,
      'venue': instance.venue,
      'match_type': instance.matchType,
      'phase': instance.phase,
      'scheduled_at':
          const TimestampDateTimeConverter().toJson(instance.scheduledAt),
      'status': instance.status,
      'current_state': instance.currentState,
      'home_score': instance.homeScore,
      'opponent_score': instance.opponentScore,
      'quarter_duration_minutes': instance.quarterDurationMinutes,
      'num_periods': instance.numPeriods,
      'ot_duration_minutes': instance.otDurationMinutes,
      'timer_config_locked': instance.timerConfigLocked,
      'notes': instance.notes,
      'started_at':
          const TimestampDateTimeConverter().toJson(instance.startedAt),
      'finished_at':
          const TimestampDateTimeConverter().toJson(instance.finishedAt),
      'created_by': instance.createdBy,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const TimestampDateTimeConverter().toJson(instance.updatedAt),
    };
