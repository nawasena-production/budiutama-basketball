// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'player_model.freezed.dart';
part 'player_model.g.dart';

const kPlayerPositions = ['PG', 'SG', 'SF', 'PF', 'C'];

Object? _readPositions(Map json, String key) {
  if (json['positions'] != null) return json['positions'];
  if (json['position'] != null) return [json['position']];
  return <String>[];
}

@freezed
class PlayerModel with _$PlayerModel {
  const PlayerModel._();

  const factory PlayerModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'team_id') required String teamId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'jersey_number') required int jerseyNumber,
    @JsonKey(name: 'positions', readValue: _readPositions)
    @Default([])
    List<String> positions,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @TimestampDateTimeConverter()
    @JsonKey(name: 'date_of_birth')
    DateTime? dateOfBirth,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_base64') String? photoBase64,
    @Default('active') String status,
    @TimestampDateTimeConverter()
    @JsonKey(name: 'created_at')
    DateTime? createdAt,
    @TimestampDateTimeConverter()
    @JsonKey(name: 'updated_at')
    DateTime? updatedAt,
  }) = _PlayerModel;

  /// Posisi utama — dipakai saat inisialisasi lineup pertandingan.
  String get primaryPosition =>
      positions.isNotEmpty ? positions.first : '';

  /// Label posisi untuk tampilan, mis. "PG / SF".
  String get positionsDisplay => positions.join(' / ');

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlayerModel.fromJson({...data, 'id': doc.id});
  }
}
