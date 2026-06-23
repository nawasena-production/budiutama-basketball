import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/core/utils/zone_classifier.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/match_action_provider.dart';

void main() {
  group('classifyZone', () {
    test('tengah bawah dekat ring (0.5, 0.1) = PAINT', () {
      expect(classifyZone(0.5, 0.1), 'PAINT');
    });

    test('pojok kiri-bawah paint (0.4, 0.2) = PAINT', () {
      expect(classifyZone(0.4, 0.2), 'PAINT');
    });

    test('top of key (0.5, 0.8) = CENTER_3', () {
      expect(classifyZone(0.5, 0.8), 'CENTER_3');
    });

    test('corner kiri dekat baseline (0.05, 0.05) = CORNER_LEFT', () {
      expect(classifyZone(0.05, 0.05), 'CORNER_LEFT');
    });

    test('corner kanan dekat baseline (0.95, 0.05) = CORNER_RIGHT', () {
      expect(classifyZone(0.95, 0.05), 'CORNER_RIGHT');
    });

    test('wing kiri (0.15, 0.5) = WING_LEFT', () {
      expect(classifyZone(0.15, 0.5), 'WING_LEFT');
    });

    test('wing kanan (0.85, 0.5) = WING_RIGHT', () {
      expect(classifyZone(0.85, 0.5), 'WING_RIGHT');
    });

    test('medium kiri (0.38, 0.25) = MEDIUM_LEFT', () {
      expect(classifyZone(0.38, 0.25), 'MEDIUM_LEFT');
    });

    test('medium tengah (0.5, 0.25) = MEDIUM_CENTER', () {
      expect(classifyZone(0.5, 0.25), 'MEDIUM_CENTER');
    });

    test('medium kanan (0.62, 0.25) = MEDIUM_RIGHT', () {
      expect(classifyZone(0.62, 0.25), 'MEDIUM_RIGHT');
    });

    test('koordinat di luar rentang [0,1] tetap diklasifikasi tanpa error', () {
      expect(() => classifyZone(-0.5, 1.5), returnsNormally);
      expect(validZones.contains(classifyZone(-0.5, 1.5)), isTrue);
    });
  });

  group('calculateDistanceFt', () {
    test('jarak di ring sendiri (0.5, 0.08) mendekati 0', () {
      expect(calculateDistanceFt(0.5, 0.08), lessThanOrEqualTo(1));
    });

    test('jarak top of key lebih jauh dari jarak di paint', () {
      final distPaint = calculateDistanceFt(0.5, 0.15);
      final distTopKey = calculateDistanceFt(0.5, 0.85);
      expect(distTopKey, greaterThan(distPaint));
    });
  });

  group('validateZoneActionConsistency', () {
    test('2PT_MADE di PAINT = konsisten (true)', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'PAINT'), isTrue);
    });

    test('2PT_MADE di WING_LEFT = TIDAK konsisten (false)', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'WING_LEFT'), isFalse);
    });

    test('MISS_2PT di CORNER_RIGHT = TIDAK konsisten (false)', () {
      expect(
          validateZoneActionConsistency('MISS_2PT', 'CORNER_RIGHT'), isFalse);
    });

    test('3PT_MADE di CENTER_3 = konsisten (true)', () {
      expect(validateZoneActionConsistency('3PT_MADE', 'CENTER_3'), isTrue);
    });

    test('3PT_MADE di PAINT = TIDAK konsisten (false)', () {
      expect(validateZoneActionConsistency('3PT_MADE', 'PAINT'), isFalse);
    });

    test('MISS_3PT di MEDIUM_CENTER = TIDAK konsisten (false)', () {
      expect(
          validateZoneActionConsistency('MISS_3PT', 'MEDIUM_CENTER'),
          isFalse);
    });
  });

  group('pointsForZone', () {
    test('zona 2pt mengembalikan 2', () {
      expect(pointsForZone('PAINT'), 2);
      expect(pointsForZone('MEDIUM_LEFT'), 2);
    });

    test('zona 3pt mengembalikan 3', () {
      expect(pointsForZone('CORNER_LEFT'), 3);
      expect(pointsForZone('CENTER_3'), 3);
    });
  });

  group('derivePlayerStatsDocId', () {
    test('format putra: 7_ar_putra2526 -> 7_ar', () {
      expect(derivePlayerStatsDocId('7_ar_putra2526'), '7_ar');
    });

    test('format putri: 3_rn_putri2526 -> 3_rn', () {
      expect(derivePlayerStatsDocId('3_rn_putri2526'), '3_rn');
    });
  });

  group('buildStatsIncrement / buildStatsDecrement — simetri', () {
    // Daftar SEMUA action type yang memengaruhi player_stats. Jika ada
    // action type baru ditambahkan ke kSelfActionTypes di masa depan,
    // WAJIB ditambahkan juga di sini agar simetri tetap terverifikasi.
    const actionTypesAffectingStats = [
      '1PT_MADE',
      '2PT_MADE',
      '3PT_MADE',
      'MISS_1PT',
      'MISS_2PT',
      'MISS_3PT',
      'ASSIST',
      'REBOUND_OFF',
      'REBOUND_DEF',
      'STEAL',
      'TURNOVER',
      'BLOCK',
      'FOUL',
    ];

    for (final actionType in actionTypesAffectingStats) {
      test('$actionType — increment dan decrement punya field yang sama persis', () {
        final inc = buildStatsIncrement(actionType, null);
        final dec = buildStatsDecrement(actionType, null);

        expect(inc.keys.toSet(), dec.keys.toSet(),
            reason: 'Field yang terpengaruh harus identik antara '
                'increment dan decrement untuk $actionType');
        expect(inc.keys, isNotEmpty,
            reason: '$actionType harus menghasilkan minimal 1 increment');

        for (final key in inc.keys) {
          final incValue = inc[key] as FieldValue;
          final decValue = dec[key] as FieldValue;
          // FieldValue tidak punya getter publik untuk introspeksi nilai,
          // tapi keduanya harus sama-sama berupa FieldValue.increment.
          // Verifikasi tipe dan bahwa objeknya valid (non-null) sudah
          // memadai sebagai regression guard struktural; nilai numerik
          // dicek lebih lanjut via integration test dengan Firestore
          // Emulator (lihat README Step 13-15).
          expect(incValue, isA<FieldValue>());
          expect(decValue, isA<FieldValue>());
        }
      });
    }

    test('2PT_MADE dengan zone — increment shot_zones, decrement juga', () {
      final inc = buildStatsIncrement('2PT_MADE', 'PAINT');
      final dec = buildStatsDecrement('2PT_MADE', 'PAINT');

      expect(inc.containsKey('shot_zones.PAINT.made'), isTrue);
      expect(inc.containsKey('shot_zones.PAINT.attempted'), isTrue);
      expect(dec.containsKey('shot_zones.PAINT.made'), isTrue);
      expect(dec.containsKey('shot_zones.PAINT.attempted'), isTrue);
    });

    test('MISS_3PT dengan zone — hanya attempted yang increment, bukan made', () {
      final inc = buildStatsIncrement('MISS_3PT', 'CENTER_3');

      expect(inc.containsKey('shot_zones.CENTER_3.attempted'), isTrue);
      expect(inc.containsKey('shot_zones.CENTER_3.made'), isFalse);
      expect(inc.containsKey('fg3_attempted'), isTrue);
      expect(inc.containsKey('fg3_made'), isFalse);
    });

    test('1PT_MADE tidak menyentuh shot_zones sama sekali (free throw)', () {
      final inc = buildStatsIncrement('1PT_MADE', null);
      expect(inc.keys.any((k) => k.startsWith('shot_zones')), isFalse);
      expect(inc.containsKey('ft_made'), isTrue);
      expect(inc.containsKey('ft_attempted'), isTrue);
      expect(inc.containsKey('points'), isTrue);
    });

    test('action type sistem (TIMEOUT) menghasilkan map kosong', () {
      expect(buildStatsIncrement('TIMEOUT', null), isEmpty);
      expect(buildStatsDecrement('TIMEOUT', null), isEmpty);
    });

    test('action type UNDO menghasilkan map kosong (tidak rekursif)', () {
      expect(buildStatsIncrement('UNDO', null), isEmpty);
    });
  });
}
