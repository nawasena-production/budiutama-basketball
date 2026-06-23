// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_test_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhysicalTestResultModelImpl _$$PhysicalTestResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PhysicalTestResultModelImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      fullName: json['full_name'] as String,
      beepLevel: (json['beep_level'] as num?)?.toInt(),
      beepShuttle: (json['beep_shuttle'] as num?)?.toInt(),
      timeSeconds: (json['time_seconds'] as num?)?.toDouble(),
      createdAt:
          const TimestampDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$PhysicalTestResultModelImplToJson(
        _$PhysicalTestResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'full_name': instance.fullName,
      'beep_level': instance.beepLevel,
      'beep_shuttle': instance.beepShuttle,
      'time_seconds': instance.timeSeconds,
      'created_at':
          const TimestampDateTimeConverter().toJson(instance.createdAt),
    };
