// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'physical_test_session_model.freezed.dart';
part 'physical_test_session_model.g.dart';

@freezed
class PhysicalTestSessionModel with _$PhysicalTestSessionModel {
  const factory PhysicalTestSessionModel({
    required String id,
    @JsonKey(name: 'team_id') required String teamId,
    @JsonKey(name: 'test_type') required String testType,
    @TimestampDateTimeConverter() @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @JsonKey(name: 'academic_year') required String academicYear,
    required int semester,
    @Default('') String notes,
    @Default(false) @JsonKey(name: 'is_stopped_early') bool isStoppedEarly,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PhysicalTestSessionModel;

  factory PhysicalTestSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PhysicalTestSessionModelFromJson(json);

  factory PhysicalTestSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PhysicalTestSessionModel.fromJson({...data, 'id': doc.id});
  }
}
