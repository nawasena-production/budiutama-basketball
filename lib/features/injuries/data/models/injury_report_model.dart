// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'injury_report_model.freezed.dart';
part 'injury_report_model.g.dart';

@freezed
class InjuryReportModel with _$InjuryReportModel {
  const factory InjuryReportModel({
    required String id,
    @JsonKey(name: 'player_id') required String playerId,
    @JsonKey(name: 'team_id') required String teamId,
    @TimestampDateTimeConverter() @JsonKey(name: 'injury_date') DateTime? injuryDate,
    @JsonKey(name: 'body_part') required String bodyPart,
    required String severity,
    required String description,
    @JsonKey(name: 'estimated_recovery_days') int? estimatedRecoveryDays,
    @Default('active') String status,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_base64') String? photoBase64,
    @TimestampDateTimeConverter() @JsonKey(name: 'cleared_at') DateTime? clearedAt,
    @Default('') String notes,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _InjuryReportModel;

  factory InjuryReportModel.fromJson(Map<String, dynamic> json) =>
      _$InjuryReportModelFromJson(json);

  factory InjuryReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InjuryReportModel.fromJson({...data, 'id': doc.id});
  }
}
