import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampDateTimeConverter
    implements JsonConverter<DateTime?, Object?> {
  const TimestampDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}

class FirestoreTimestampConverter
    implements JsonConverter<Timestamp?, Object?> {
  const FirestoreTimestampConverter();

  @override
  Timestamp? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json;
    if (json is DateTime) return Timestamp.fromDate(json);
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      return parsed == null ? null : Timestamp.fromDate(parsed);
    }
    return null;
  }

  @override
  Object? toJson(Timestamp? object) => object;
}
