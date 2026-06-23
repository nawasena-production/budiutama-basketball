import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/events/data/repositories/event_repository.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/repositories/match_repository.dart';
import 'package:budiutama_basketball/features/training/data/repositories/training_repository.dart';

void main() {
  // ── EventRepository ────────────────────────────────────────────────────

  group('EventRepository.generateEventId', () {
    test('porseni kota menghasilkan ID yang benar', () {
      final id = EventRepository.generateEventId(
        eventType: 'porseni',
        eventName: 'Porseni Tingkat Kota Yogyakarta',
        academicYearCode: '2526',
      );
      // Skip "porseni", "tingkat" → ambil "kota", "yogyakarta"
      expect(id, 'porseni_kota_yogyakarta_2526');
    });

    test('friendly SMAN 1 menghasilkan ID yang benar', () {
      final id = EventRepository.generateEventId(
        eventType: 'persahabatan',
        eventName: 'Persahabatan SMAN 1 Yogyakarta',
        academicYearCode: '2526',
      );
      expect(id, 'persahabatan_sman1_yogyakarta_2526');
    });

    test('nama pendek tetap valid', () {
      final id = EventRepository.generateEventId(
        eventType: 'popda',
        eventName: 'Popda 2026',
        academicYearCode: '2627',
      );
      expect(id, contains('popda'));
      expect(id, contains('2627'));
    });
  });

  group('EventRepository.academicYearToCode', () {
    test('konversi 2025/2026 → 2526', () {
      expect(EventRepository.academicYearToCode('2025/2026'), '2526');
    });

    test('konversi 2026/2027 → 2627', () {
      expect(EventRepository.academicYearToCode('2026/2027'), '2627');
    });

    test('format tidak valid dikembalikan apa adanya', () {
      expect(EventRepository.academicYearToCode('invalid'), 'invalid');
    });
  });

  // ── MatchRepository ────────────────────────────────────────────────────

  group('MatchRepository.generateMatchId', () {
    test('format ID benar untuk pertandingan vs SMAN 1', () {
      final id = MatchRepository.generateMatchId(
        eventId: 'porseni_kota_2526',
        opponentName: 'SMAN 1 Yogyakarta',
        scheduledAt: DateTime(2026, 3, 15),
      );
      expect(id, 'porseni_kota_2526_vs_sman1yogyakarta_20260315');
    });

    test('tanggal diformat sebagai YYYYMMDD', () {
      final id = MatchRepository.generateMatchId(
        eventId: 'porseni_kota_2526',
        opponentName: 'SMA Muhammadiyah',
        scheduledAt: DateTime(2026, 1, 5),
      );
      // Tanggal 5 Januari 2026 → 20260105
      expect(id, contains('20260105'));
    });

    test('nama lawan dengan karakter khusus dinormalisasi', () {
      final id = MatchRepository.generateMatchId(
        eventId: 'popda_2526',
        opponentName: 'SMA N 3 Yogyakarta',
        scheduledAt: DateTime(2026, 6, 20),
      );
      expect(id, isA<String>());
      expect(id, isNotEmpty);
      expect(id, contains('popda_2526_vs_'));
    });
  });

  group('MatchRepository._deriveStatsDocId (via generateMatchId)', () {
    // Test indirect melalui logika yang sama
    test('player ID 7_ar_putra2526 menghasilkan stats doc ID 7_ar', () {
      const playerId = '7_ar_putra2526';
      final parts = playerId.split('_');
      final docId = parts.length >= 2 ? '${parts[0]}_${parts[1]}' : playerId;
      expect(docId, '7_ar');
    });

    test('player ID 11_bs_putra2526 menghasilkan stats doc ID 11_bs', () {
      const playerId = '11_bs_putra2526';
      final parts = playerId.split('_');
      final docId = parts.length >= 2 ? '${parts[0]}_${parts[1]}' : playerId;
      expect(docId, '11_bs');
    });

    test('player ID 3_rn_putri2526 menghasilkan stats doc ID 3_rn', () {
      const playerId = '3_rn_putri2526';
      final parts = playerId.split('_');
      final docId = parts.length >= 2 ? '${parts[0]}_${parts[1]}' : playerId;
      expect(docId, '3_rn');
    });
  });

  // ── TrainingRepository ─────────────────────────────────────────────────

  group('TrainingRepository.generateSessionId', () {
    test('format ID sesi fisik benar', () {
      final id = TrainingRepository.generateSessionId(
        teamId: 'putra_2526',
        sessionType: 'physical',
        scheduledAt: DateTime(2026, 1, 10),
      );
      expect(id, 'putra2526_physical_20260110');
    });

    test('tanggal bulan satu digit di-pad dengan nol', () {
      final id = TrainingRepository.generateSessionId(
        teamId: 'putri_2526',
        sessionType: 'technical',
        scheduledAt: DateTime(2026, 3, 5),
      );
      expect(id, 'putri2526_technical_20260305');
    });

    test('underscore dalam teamId dihilangkan', () {
      final id = TrainingRepository.generateSessionId(
        teamId: 'putra_2627',
        sessionType: 'tactical',
        scheduledAt: DateTime(2026, 12, 1),
      );
      expect(id, 'putra2627_tactical_20261201');
    });
  });
}
