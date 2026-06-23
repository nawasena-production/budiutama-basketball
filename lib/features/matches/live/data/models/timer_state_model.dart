// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'timer_state_model.freezed.dart';
part 'timer_state_model.g.dart';

@freezed
class TimerStateModel with _$TimerStateModel {
  const factory TimerStateModel({
    @Default(false) @JsonKey(name: 'is_running') bool isRunning,
    @Default(600.0) @JsonKey(name: 'seconds_at_start') double secondsAtStart,
    @FirestoreTimestampConverter() @JsonKey(name: 'started_at') Timestamp? startedAt,
    @Default(1) int quarter,
  }) = _TimerStateModel;

  factory TimerStateModel.fromJson(Map<String, dynamic> json) =>
      _$TimerStateModelFromJson(json);

  factory TimerStateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TimerStateModel.fromJson(data);
  }
}
