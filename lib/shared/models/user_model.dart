// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String uid,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required String role,
    // BARU (Step 12) — opsional agar tetap backward-compatible dengan
    // dokumen users/ lama yang belum memiliki field ini.
    @JsonKey(name: 'team_id') String? teamId,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
    @Default([])
    @JsonKey(name: 'trusted_device_ids')
    List<String> trustedDeviceIds,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @TimestampDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromJson({...data, 'id': doc.id});
  }
}
