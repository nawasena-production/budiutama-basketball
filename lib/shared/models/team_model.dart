// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
class TeamModel with _$TeamModel {
  const factory TeamModel({
    required String id,
    required String name,
    required String gender,
    @JsonKey(name: 'academic_year') required String academicYear,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
    @TimestampDateTimeConverter()
    @JsonKey(name: 'created_at')
    DateTime? createdAt,
  }) = _TeamModel;

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TeamModel(
      id: doc.id,
      name: data['name'] as String? ?? _nameFromId(doc.id),
      gender: data['gender'] as String? ?? _genderFromId(doc.id),
      academicYear:
          data['academic_year'] as String? ?? _academicYearFromId(doc.id),
      isActive: data['is_active'] as bool? ?? true,
      createdAt:
          const TimestampDateTimeConverter().fromJson(data['created_at']),
    );
  }
}

String _genderFromId(String id) {
  final normalized = id.toLowerCase();
  if (normalized.contains('putri') || normalized.contains('female')) {
    return 'female';
  }
  return 'male';
}

String _nameFromId(String id) {
  final normalized = id.toLowerCase();
  final level = normalized.contains('smp') ? 'SMP' : 'SMA';
  final gender = _genderFromId(id) == 'female' ? 'Putri' : 'Putra';
  return '$level $gender';
}

String _academicYearFromId(String id) {
  final match = RegExp(r'(\d{2})(\d{2})$').firstMatch(id);
  if (match == null) return '2025/2026';
  return '20${match.group(1)}/20${match.group(2)}';
}
