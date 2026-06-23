import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

class PlayerRepository {
  PlayerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Real-time stream semua pemain dalam satu tim.
  /// Update otomatis via Firestore listener setiap ada perubahan data.
  Stream<List<PlayerModel>> watchByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.players)
        .where('team_id', isEqualTo: teamId)
        .orderBy('jersey_number')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PlayerModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Real-time stream pemain berdasarkan status.
  Stream<List<PlayerModel>> watchByStatus(String teamId, String status) {
    return _db
        .collection(FirestorePaths.players)
        .where('team_id', isEqualTo: teamId)
        .where('status', isEqualTo: status)
        .orderBy('jersey_number')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PlayerModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ── READS ──────────────────────────────────────────────────────────────

  Future<PlayerModel?> getById(String playerId) async {
    final doc =
        await _db.collection(FirestorePaths.players).doc(playerId).get();
    if (!doc.exists) return null;
    return PlayerModel.fromFirestore(doc);
  }

  /// Cek apakah nomor jersey sudah dipakai dalam satu tim.
  Future<bool> isJerseyNumberTaken(String teamId, int jerseyNumber,
      {String? excludePlayerId}) async {
    final query = await _db
        .collection(FirestorePaths.players)
        .where('team_id', isEqualTo: teamId)
        .where('jersey_number', isEqualTo: jerseyNumber)
        .get();

    if (query.docs.isEmpty) return false;
    // Saat edit: exclude dokumen pemain yang sedang diedit
    if (excludePlayerId != null) {
      return query.docs.any((doc) => doc.id != excludePlayerId);
    }
    return true;
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat pemain baru.
  /// Document ID format: {jersey}_{inisial}_{teamId}
  /// Contoh: 7_ar_putra2526
  Future<void> create({
    required String playerId,
    required PlayerModel player,
  }) async {
    try {
      // Validasi jersey tidak duplikat
      final taken = await isJerseyNumberTaken(
        player.teamId,
        player.jerseyNumber,
      );
      if (taken) {
        throw const FirestoreException(
          'Nomor jersey sudah digunakan oleh pemain lain di tim ini.',
        );
      }

      final data = player.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp()
        ..['updated_at'] = FieldValue.serverTimestamp();

      await _db.collection(FirestorePaths.players).doc(playerId).set(data);
    } on FirestoreException {
      rethrow;
    } catch (e) {
      throw FirestoreException('Gagal menambahkan pemain: $e');
    }
  }

  /// Update field tertentu saja (partial update).
  Future<void> update(String playerId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _db.collection(FirestorePaths.players).doc(playerId).update(data);
    } catch (e) {
      throw FirestoreException('Gagal memperbarui data pemain: $e');
    }
  }

  /// Update foto pemain (base64 untuk free plan).
  Future<void> updatePhoto(String playerId, String base64Photo) async {
    await update(playerId, {'photo_base64': base64Photo});
  }

  /// Soft delete — ubah status menjadi inactive.
  /// Data pemain tidak pernah dihapus permanen dari Firestore.
  Future<void> deactivate(String playerId) async {
    await update(playerId, {'status': 'inactive'});
  }

  /// Update status pemain: active | injured | inactive
  Future<void> updateStatus(String playerId, String status) async {
    await update(playerId, {'status': status});
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate document ID sesuai konvensi:
  /// {jersey}_{inisialNama}_{teamId}
  /// Contoh: fullName="Ahmad Rizki", jersey=7, teamId="putra_2526"
  ///   → "7_ar_putra2526"
  static String generatePlayerId({
    required int jerseyNumber,
    required String fullName,
    required String teamId,
  }) {
    // Ambil inisial dari setiap kata nama (max 2 kata pertama)
    final words = fullName.trim().split(RegExp(r'\s+')).take(2);
    final initials =
        words.map((w) => w.isNotEmpty ? w[0].toLowerCase() : '').join();
    final teamShort = teamId.replaceAll('_', '');
    return '${jerseyNumber}_${initials}_$teamShort';
  }
}
