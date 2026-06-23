// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'lineup_model.freezed.dart';
part 'lineup_model.g.dart';

@freezed
class LineupModel with _$LineupModel {
  const factory LineupModel({
    required String id,
    @JsonKey(name: 'player_id') required String playerId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'jersey_number') required int jerseyNumber,
    required String position,
    @Default(false) @JsonKey(name: 'is_starter') bool isStarter,
    @Default(false) @JsonKey(name: 'is_on_court') bool isOnCourt,
    @JsonKey(name: 'entered_at_clock') double? enteredAtClock,
    @JsonKey(name: 'entered_at_quarter') int? enteredAtQuarter,
    @Default(0) @JsonKey(name: 'total_seconds_played') int totalSecondsPlayed,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LineupModel;

  factory LineupModel.fromJson(Map<String, dynamic> json) =>
      _$LineupModelFromJson(json);

  factory LineupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LineupModel.fromJson({...data, 'id': doc.id});
  }
}
