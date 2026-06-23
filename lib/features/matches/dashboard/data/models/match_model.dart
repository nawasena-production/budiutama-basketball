// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    @JsonKey(name: 'home_team_id') required String homeTeamId,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'opponent_name') required String opponentName,
    required String venue,
    @JsonKey(name: 'match_type') required String matchType,
    required String phase,
    @TimestampDateTimeConverter() @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @Default('scheduled') String status,
    @Default('PRE_MATCH') @JsonKey(name: 'current_state') String currentState,
    @Default(0) @JsonKey(name: 'home_score') int homeScore,
    @Default(0) @JsonKey(name: 'opponent_score') int opponentScore,
    @Default(10) @JsonKey(name: 'quarter_duration_minutes') int quarterDurationMinutes,
    @Default(4) @JsonKey(name: 'num_periods') int numPeriods,
    @Default(5) @JsonKey(name: 'ot_duration_minutes') int otDurationMinutes,
    @Default(false) @JsonKey(name: 'timer_config_locked') bool timerConfigLocked,
    @Default('') String notes,
    @TimestampDateTimeConverter() @JsonKey(name: 'started_at') DateTime? startedAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'finished_at') DateTime? finishedAt,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchModel.fromJson({...data, 'id': doc.id});
  }
}
