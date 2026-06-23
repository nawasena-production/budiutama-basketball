import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/injuries/data/repositories/injury_repository.dart';
import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';

void main() {
  group('InjuryRepository.generateReportId', () {
    test('format dasar {playerId}_{YYYYMMDD}', () {
      final id = InjuryRepository.generateReportId(
        playerId: '7_ar_putra2526',
        injuryDate: DateTime(2026, 2, 5),
      );
      expect(id, '7_ar_putra2526_20260205');
    });

    test('padding bulan dan tanggal di bawah 10', () {
      final id = InjuryRepository.generateReportId(
        playerId: '3_bd_putri2526',
        injuryDate: DateTime(2026, 1, 9),
      );
      expect(id, '3_bd_putri2526_20260109');
    });

    test('akhir tahun (Desember)', () {
      final id = InjuryRepository.generateReportId(
        playerId: '12_cd_putra2526',
        injuryDate: DateTime(2026, 12, 31),
      );
      expect(id, '12_cd_putra2526_20261231');
    });
  });

  group('PhysicalTestRepository.generateSessionId', () {
    test('format dasar {tipe}_{teamShort}_{YYYYMMDD}', () {
      final id = PhysicalTestRepository.generateSessionId(
        testType: 'beep_test',
        teamId: 'putra_2526',
        scheduledAt: DateTime(2026, 1, 20),
      );
      expect(id, 'beep_test_putra2526_20260120');
    });

    test('menghapus semua underscore pada teamId', () {
      final id = PhysicalTestRepository.generateSessionId(
        testType: 't_test',
        teamId: 'putri_2526',
        scheduledAt: DateTime(2026, 3, 1),
      );
      expect(id, 't_test_putri2526_20260301');
    });

    test('padding bulan dan tanggal di bawah 10', () {
      final id = PhysicalTestRepository.generateSessionId(
        testType: 'sprint_20m',
        teamId: 'putra_2526',
        scheduledAt: DateTime(2026, 9, 5),
      );
      expect(id, 'sprint_20m_putra2526_20260905');
    });
  });

  group('PhysicalTestRepository.derivePlayerDocId', () {
    test('drop suffix teamId dari fullPlayerId', () {
      expect(
        PhysicalTestRepository.derivePlayerDocId('7_ar_putra2526'),
        '7_ar',
      );
    });

    test('fullPlayerId dengan inisial 1 huruf', () {
      expect(
        PhysicalTestRepository.derivePlayerDocId('10_x_putri2526'),
        '10_x',
      );
    });

    test('fullPlayerId tanpa cukup bagian — fallback ke nilai asli', () {
      expect(
        PhysicalTestRepository.derivePlayerDocId('7'),
        '7',
      );
    });
  });
}
