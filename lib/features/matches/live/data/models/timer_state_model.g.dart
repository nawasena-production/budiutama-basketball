// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerStateModelImpl _$$TimerStateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TimerStateModelImpl(
      isRunning: json['is_running'] as bool? ?? false,
      secondsAtStart: (json['seconds_at_start'] as num?)?.toDouble() ?? 600.0,
      startedAt:
          const FirestoreTimestampConverter().fromJson(json['started_at']),
      quarter: (json['quarter'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$TimerStateModelImplToJson(
        _$TimerStateModelImpl instance) =>
    <String, dynamic>{
      'is_running': instance.isRunning,
      'seconds_at_start': instance.secondsAtStart,
      'started_at':
          const FirestoreTimestampConverter().toJson(instance.startedAt),
      'quarter': instance.quarter,
    };
