// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    @JsonKey(name: 'team_id') required String teamId,
    required String name,
    required String organizer,
    @JsonKey(name: 'event_type') required String eventType,
    required String location,
    @TimestampDateTimeConverter() @JsonKey(name: 'start_date') DateTime? startDate,
    @TimestampDateTimeConverter() @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'academic_year') required String academicYear,
    @Default([]) @JsonKey(name: 'player_ids') List<String> playerIds,
    @Default('upcoming') String status,
    @Default('') String notes,
    @JsonKey(name: 'created_by') required String createdBy,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EventModel.fromJson({...data, 'id': doc.id});
  }
}
