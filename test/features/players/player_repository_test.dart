import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/players/data/repositories/player_repository.dart';

void main() {
  group('PlayerRepository.generatePlayerId', () {
    test('nama satu kata menghasilkan satu inisial', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 7,
        fullName: 'Ahmad',
        teamId: 'putra_2526',
      );
      // "Ahmad" → inisial "a", team "putra2526"
      expect(id, '7_a_putra2526');
    });

    test('nama dua kata menghasilkan dua inisial', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 7,
        fullName: 'Ahmad Rizki',
        teamId: 'putra_2526',
      );
      expect(id, '7_ar_putra2526');
    });

    test('nama lebih dari dua kata hanya ambil dua kata pertama', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 11,
        fullName: 'Budi Santoso Wijaya',
        teamId: 'putra_2526',
      );
      // Hanya "Budi Santoso" → "bs"
      expect(id, '11_bs_putra2526');
    });

    test('nama dengan huruf kapital dikonversi ke lowercase', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 3,
        fullName: 'RINA NURAINI',
        teamId: 'putri_2526',
      );
      expect(id, '3_rn_putri2526');
    });

    test('jersey number nol tetap valid', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 0,
        fullName: 'Dimas Pratama',
        teamId: 'putra_2526',
      );
      expect(id, '0_dp_putra2526');
    });

    test('jersey number dua digit tetap valid', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 15,
        fullName: 'Galih Wibowo',
        teamId: 'putra_2526',
      );
      expect(id, '15_gw_putra2526');
    });

    test('teamId underscore dihilangkan dalam docId', () {
      final id = PlayerRepository.generatePlayerId(
        jerseyNumber: 4,
        fullName: 'Fajar Hidayat',
        teamId: 'putra_2627',
      );
      expect(id, '4_fh_putra2627');
    });
  });
}
