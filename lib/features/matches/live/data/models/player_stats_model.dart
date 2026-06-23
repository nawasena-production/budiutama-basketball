// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'player_stats_model.freezed.dart';
part 'player_stats_model.g.dart';

@freezed
class PlayerStatsModel with _$PlayerStatsModel {
  const factory PlayerStatsModel({
    required String id,
    @JsonKey(name: 'player_id') required String playerId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'jersey_number') required int jerseyNumber,
    @Default(0) int points,
    @Default(0) @JsonKey(name: 'ft_made') int ftMade,
    @Default(0) @JsonKey(name: 'ft_attempted') int ftAttempted,
    @Default(0) @JsonKey(name: 'fg2_made') int fg2Made,
    @Default(0) @JsonKey(name: 'fg2_attempted') int fg2Attempted,
    @Default(0) @JsonKey(name: 'fg3_made') int fg3Made,
    @Default(0) @JsonKey(name: 'fg3_attempted') int fg3Attempted,
    @Default(0) int assists,
    @Default(0) @JsonKey(name: 'offensive_rebounds') int offensiveRebounds,
    @Default(0) @JsonKey(name: 'defensive_rebounds') int defensiveRebounds,
    @Default(0) int steals,
    @Default(0) int turnovers,
    @Default(0) int blocks,
    @Default(0) int fouls,
    @Default({}) @JsonKey(name: 'shot_zones') Map<String, dynamic> shotZones,
    @Default(0) @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PlayerStatsModel;

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsModelFromJson(json);

  factory PlayerStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlayerStatsModel.fromJson({...data, 'id': doc.id});
  }
}
