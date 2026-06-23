import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/zone_classifier.dart';

void main() {
  group('classifyZone — PAINT', () {
    test('tepat di bawah ring, dalam batas paint = PAINT', () {
      expect(classifyZone(0.5, 0.15), 'PAINT');
    });

    test('tepi kiri paint (x=paintXMin, y dalam batas) = PAINT', () {
      expect(classifyZone(paintXMin, 0.1), 'PAINT');
    });

    test('tepi kanan paint (x=paintXMax, y dalam batas) = PAINT', () {
      expect(classifyZone(paintXMax, 0.1), 'PAINT');
    });

    test('tepi bawah paint (y=paintYMax) masih PAINT', () {
      expect(classifyZone(0.5, paintYMax), 'PAINT');
    });

    test('sedikit di luar tepi bawah paint BUKAN PAINT', () {
      expect(classifyZone(0.5, paintYMax + 0.01), isNot('PAINT'));
    });
  });

  group('classifyZone — CORNER', () {
    test('dekat baseline kiri, luar arc = CORNER_LEFT', () {
      // y < cornerLineY (0.18) dan jarak dari ring > threePtRadius (0.43)
      expect(classifyZone(0.05, 0.05), 'CORNER_LEFT');
    });

    test('dekat baseline kanan, luar arc = CORNER_RIGHT', () {
      expect(classifyZone(0.95, 0.05), 'CORNER_RIGHT');
    });
  });

  group('classifyZone — WING & CENTER_3', () {
    test('luar arc, y tinggi (>0.55), tengah = CENTER_3', () {
      expect(classifyZone(0.5, 0.8), 'CENTER_3');
    });

    test('luar arc, y sedang, kiri = WING_LEFT', () {
      expect(classifyZone(0.05, 0.45), 'WING_LEFT');
    });

    test('luar arc, y sedang, kanan = WING_RIGHT', () {
      expect(classifyZone(0.95, 0.45), 'WING_RIGHT');
    });
  });

  group('classifyZone — MEDIUM RANGE', () {
    test('dalam arc, luar paint, kiri (x<0.42) = MEDIUM_LEFT', () {
      expect(classifyZone(0.20, 0.25), 'MEDIUM_LEFT');
    });

    test('dalam arc, luar paint, kanan (x>0.58) = MEDIUM_RIGHT', () {
      expect(classifyZone(0.80, 0.25), 'MEDIUM_RIGHT');
    });

    test('dalam arc, luar paint, tengah (0.42<=x<=0.58) = MEDIUM_CENTER', () {
      expect(classifyZone(0.5, 0.40), 'MEDIUM_CENTER');
    });
  });

  group('classifyZone — clamping & edge cases', () {
    test('koordinat sedikit di luar [0,1] (floating point error) tidak error', () {
      expect(() => classifyZone(-0.001, 1.0005), returnsNormally);
    });

    test('koordinat negatif besar tetap menghasilkan zona valid (clamped)', () {
      final zone = classifyZone(-5.0, -5.0);
      expect(validZones.contains(zone), isTrue);
    });

    test('koordinat lebih dari 1.0 tetap menghasilkan zona valid (clamped)', () {
      final zone = classifyZone(10.0, 10.0);
      expect(validZones.contains(zone), isTrue);
    });

    test('seluruh output classifyZone selalu termasuk salah satu dari 9 validZones', () {
      final testPoints = [
        [0.5, 0.1], [0.1, 0.1], [0.9, 0.1],
        [0.1, 0.5], [0.9, 0.5], [0.5, 0.8],
        [0.3, 0.3], [0.7, 0.3], [0.5, 0.4],
      ];
      for (final p in testPoints) {
        final zone = classifyZone(p[0], p[1]);
        expect(validZones.contains(zone), isTrue,
            reason: 'zona "$zone" dari titik $p harus ada di validZones');
      }
    });
  });

  group('calculateDistanceFt', () {
    test('titik tepat di ring menghasilkan jarak mendekati 0 ft', () {
      expect(calculateDistanceFt(ringX, ringY), lessThanOrEqualTo(2));
    });

    test('jarak selalu non-negatif', () {
      expect(calculateDistanceFt(0.0, 0.0), greaterThanOrEqualTo(0));
      expect(calculateDistanceFt(1.0, 1.0), greaterThanOrEqualTo(0));
    });

    test('titik lebih jauh dari ring menghasilkan jarak ft lebih besar', () {
      final near = calculateDistanceFt(0.5, 0.2);
      final far = calculateDistanceFt(0.5, 0.9);
      expect(far, greaterThan(near));
    });

    test('koordinat di luar [0,1] tidak menyebabkan error (clamped)', () {
      expect(() => calculateDistanceFt(-1.0, 2.0), returnsNormally);
    });
  });

  group('validateZoneActionConsistency', () {
    test('2PT_MADE di PAINT = konsisten (true)', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'PAINT'), isTrue);
    });

    test('2PT_MADE di MEDIUM_LEFT/CENTER/RIGHT = konsisten', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'MEDIUM_LEFT'), isTrue);
      expect(validateZoneActionConsistency('2PT_MADE', 'MEDIUM_CENTER'), isTrue);
      expect(validateZoneActionConsistency('2PT_MADE', 'MEDIUM_RIGHT'), isTrue);
    });

    test('2PT_MADE di zona 3PT manapun = TIDAK konsisten (false)', () {
      for (final zone in zones3pt) {
        expect(
          validateZoneActionConsistency('2PT_MADE', zone),
          isFalse,
          reason: '2PT_MADE di zona $zone (3 poin) harus inkonsisten',
        );
      }
    });

    test('MISS_2PT di zona 3PT = TIDAK konsisten', () {
      expect(validateZoneActionConsistency('MISS_2PT', 'WING_LEFT'), isFalse);
    });

    test('3PT_MADE di CENTER_3/CORNER/WING = konsisten', () {
      for (final zone in zones3pt) {
        expect(
          validateZoneActionConsistency('3PT_MADE', zone),
          isTrue,
          reason: '3PT_MADE di zona $zone (3 poin) harus konsisten',
        );
      }
    });

    test('3PT_MADE di zona 2PT manapun = TIDAK konsisten', () {
      for (final zone in zones2pt) {
        expect(
          validateZoneActionConsistency('3PT_MADE', zone),
          isFalse,
          reason: '3PT_MADE di zona $zone (2 poin) harus inkonsisten',
        );
      }
    });

    test('MISS_3PT di zona 2PT = TIDAK konsisten', () {
      expect(validateZoneActionConsistency('MISS_3PT', 'PAINT'), isFalse);
    });

    test('action_type selain 2PT/3PT (mis. ASSIST) selalu dianggap konsisten', () {
      // Fungsi ini tidak seharusnya dipanggil untuk non-shot actions,
      // tapi harus tetap aman (true) jika dipanggil — bukan crash.
      expect(validateZoneActionConsistency('ASSIST', 'PAINT'), isTrue);
      expect(validateZoneActionConsistency('STEAL', 'WING_LEFT'), isTrue);
    });
  });

  group('pointsForZone', () {
    test('zona 2pt mengembalikan 2', () {
      for (final zone in zones2pt) {
        expect(pointsForZone(zone), 2);
      }
    });

    test('zona 3pt mengembalikan 3', () {
      for (final zone in zones3pt) {
        expect(pointsForZone(zone), 3);
      }
    });
  });

  group('konsistensi internal: zones2pt + zones3pt == validZones', () {
    test('gabungan zones2pt dan zones3pt persis sama dengan validZones', () {
      final combined = {...zones2pt, ...zones3pt};
      expect(combined, equals(validZones));
    });

    test('tidak ada zona yang muncul di kedua set (2pt dan 3pt) sekaligus', () {
      final intersection = zones2pt.intersection(zones3pt);
      expect(intersection, isEmpty);
    });
  });
}
