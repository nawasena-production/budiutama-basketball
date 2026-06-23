// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'physical_test_result_model.freezed.dart';
part 'physical_test_result_model.g.dart';

@freezed
class PhysicalTestResultModel with _$PhysicalTestResultModel {
  const factory PhysicalTestResultModel({
    required String id,
    @JsonKey(name: 'player_id') required String playerId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'beep_level') int? beepLevel,
    @JsonKey(name: 'beep_shuttle') int? beepShuttle,
    @JsonKey(name: 'time_seconds') double? timeSeconds,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PhysicalTestResultModel;

  factory PhysicalTestResultModel.fromJson(Map<String, dynamic> json) =>
      _$PhysicalTestResultModelFromJson(json);

  factory PhysicalTestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PhysicalTestResultModel.fromJson({...data, 'id': doc.id});
  }
}
