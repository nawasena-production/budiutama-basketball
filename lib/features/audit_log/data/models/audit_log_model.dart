// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:budiutama_basketball/core/utils/timestamp_converter.dart';

part 'audit_log_model.freezed.dart';
part 'audit_log_model.g.dart';

/// Representasi typed satu dokumen `audit_logs` (SDD Section 3.2,
/// FR-AUD-01). Dokumen ini HANYA ditulis oleh Cloud Functions Admin SDK
/// (`onMatchEventCreated`, dan trigger CRUD lain yang akan ditambahkan
/// di Fase berikutnya) — client Flutter murni *read-only* terhadap
/// collection ini, sesuai Security Rules `allow write: if false`.
@freezed
class AuditLogModel with _$AuditLogModel {
  const factory AuditLogModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    String? role,
    @JsonKey(name: 'action_type') required String actionType,
    @JsonKey(name: 'entity_type') required String entityType,
    @JsonKey(name: 'entity_id') String? entityId,
    @JsonKey(name: 'old_value') Map<String, dynamic>? oldValue,
    @JsonKey(name: 'new_value') Map<String, dynamic>? newValue,
    @TimestampDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AuditLogModel;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuditLogModel.fromJson({...data, 'id': doc.id});
  }
}
