// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'training_session_model.freezed.dart';
part 'training_session_model.g.dart';

@freezed
class TrainingSessionModel with _$TrainingSessionModel {
  const factory TrainingSessionModel({
    required String id,
    @JsonKey(name: 'team_id') required String teamId,
    required String title,
    @JsonKey(name: 'session_type') required String sessionType,
    @TimestampDateTimeConverter() @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    required String location,
    required String description,
    @Default(false) @JsonKey(name: 'is_cancelled') bool isCancelled,
    @Default('') String notes,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TrainingSessionModel;

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionModelFromJson(json);

  factory TrainingSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TrainingSessionModel.fromJson({...data, 'id': doc.id});
  }
}
