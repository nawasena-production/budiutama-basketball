// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'match_event_model.freezed.dart';
part 'match_event_model.g.dart';

// Valid action_type:
// 1PT_MADE, 2PT_MADE, 3PT_MADE, MISS_1PT, MISS_2PT, MISS_3PT,
// ASSIST, REBOUND_OFF, REBOUND_DEF, STEAL, TURNOVER, BLOCK, FOUL,
// TIMEOUT, STATE_TRANSITION, SUBSTITUTION, TIMER_START, TIMER_PAUSE,
// TIMER_RESUME, UNDO.
@freezed
class MatchEventModel with _$MatchEventModel {
  const factory MatchEventModel({
    required String id,
    required int quarter,
    @JsonKey(name: 'time_remaining') required double timeRemaining,
    @JsonKey(name: 'player_id') String? playerId,
    @JsonKey(name: 'action_type') required String actionType,
    @Default(0) int value,
    String? zone,
    @JsonKey(name: 'shot_x') double? shotX,
    @JsonKey(name: 'shot_y') double? shotY,
    @JsonKey(name: 'shot_distance_ft') int? shotDistanceFt,
    @Default(false) @JsonKey(name: 'is_opponent') bool isOpponent,
    @Default(false) @JsonKey(name: 'is_undone') bool isUndone,
    @JsonKey(name: 'undo_ref_id') String? undoRefId,
    // ── BARU (Step 16) — konteks tambahan khusus action_type == 'SUBSTITUTION' ──
    // Diisi null untuk seluruh action_type lainnya. Disimpan langsung di
    // event (bukan dihitung ulang dari lineup) supaya Event Timeline bisa
    // menampilkan "#7 OUT → #11 IN" tanpa query tambahan ke collection lain
    // (lihat SDD Section 8.1 — prinsip immutability & self-contained event log).
    @JsonKey(name: 'sub_out_player_id') String? subOutPlayerId,
    @JsonKey(name: 'sub_out_jersey') int? subOutJersey,
    @JsonKey(name: 'sub_in_jersey') int? subInJersey,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MatchEventModel;

  factory MatchEventModel.fromJson(Map<String, dynamic> json) =>
      _$MatchEventModelFromJson(json);

  factory MatchEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchEventModel.fromJson({...data, 'id': doc.id});
  }
}
