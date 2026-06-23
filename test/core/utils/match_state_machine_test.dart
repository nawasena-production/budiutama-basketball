import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/match_state_machine.dart';

void main() {
  group('isValidTransition — alur normal', () {
    test('PRE_MATCH → Q1_ACTIVE valid', () {
      expect(isValidTransition('PRE_MATCH', 'Q1_ACTIVE'), isTrue);
    });

    test('Q1_ACTIVE → Q1_BREAK valid', () {
      expect(isValidTransition('Q1_ACTIVE', 'Q1_BREAK'), isTrue);
    });

    test('Q1_BREAK → Q2_ACTIVE valid', () {
      expect(isValidTransition('Q1_BREAK', 'Q2_ACTIVE'), isTrue);
    });

    test('Q2_ACTIVE → HALFTIME valid', () {
      expect(isValidTransition('Q2_ACTIVE', 'HALFTIME'), isTrue);
    });

    test('HALFTIME → Q3_ACTIVE valid', () {
      expect(isValidTransition('HALFTIME', 'Q3_ACTIVE'), isTrue);
    });

    test('Q3_ACTIVE → Q3_BREAK valid', () {
      expect(isValidTransition('Q3_ACTIVE', 'Q3_BREAK'), isTrue);
    });

    test('Q3_BREAK → Q4_ACTIVE valid', () {
      expect(isValidTransition('Q3_BREAK', 'Q4_ACTIVE'), isTrue);
    });

    test('Q4_ACTIVE → CHECK_SCORE valid', () {
      expect(isValidTransition('Q4_ACTIVE', 'CHECK_SCORE'), isTrue);
    });
  });

  group('isValidTransition — percabangan CHECK_SCORE', () {
    test('CHECK_SCORE → OT_ACTIVE valid (skor seri)', () {
      expect(isValidTransition('CHECK_SCORE', 'OT_ACTIVE'), isTrue);
    });

    test('CHECK_SCORE → POST_MATCH valid (skor tidak seri)', () {
      expect(isValidTransition('CHECK_SCORE', 'POST_MATCH'), isTrue);
    });

    test('OT_ACTIVE → POST_MATCH valid', () {
      expect(isValidTransition('OT_ACTIVE', 'POST_MATCH'), isTrue);
    });
  });

  group('isValidTransition — transisi tidak valid', () {
    test('PRE_MATCH → Q2_ACTIVE invalid (lompat Q1)', () {
      expect(isValidTransition('PRE_MATCH', 'Q2_ACTIVE'), isFalse);
    });

    test('Q1_ACTIVE → Q3_ACTIVE invalid (lompat Q2)', () {
      expect(isValidTransition('Q1_ACTIVE', 'Q3_ACTIVE'), isFalse);
    });

    test('POST_MATCH → Q1_ACTIVE invalid (tidak bisa mundur dari terminal)', () {
      expect(isValidTransition('POST_MATCH', 'Q1_ACTIVE'), isFalse);
    });

    test('Q2_ACTIVE → Q1_BREAK invalid (mundur)', () {
      expect(isValidTransition('Q2_ACTIVE', 'Q1_BREAK'), isFalse);
    });

    test('HALFTIME → Q4_ACTIVE invalid (lompat Q3)', () {
      expect(isValidTransition('HALFTIME', 'Q4_ACTIVE'), isFalse);
    });

    test('state asal tidak dikenal mengembalikan false, bukan error', () {
      expect(isValidTransition('STATE_TIDAK_ADA', 'Q1_ACTIVE'), isFalse);
    });

    test('state tujuan tidak dikenal mengembalikan false', () {
      expect(isValidTransition('PRE_MATCH', 'STATE_TIDAK_ADA'), isFalse);
    });
  });

  group('validTransitions — struktur peta', () {
    test('POST_MATCH adalah terminal state (tidak ada transisi keluar)', () {
      expect(validTransitions['POST_MATCH'], isEmpty);
    });

    test('semua 11 state terdaftar di peta', () {
      expect(validTransitions.keys, hasLength(11));
      expect(validTransitions.keys, contains('PRE_MATCH'));
      expect(validTransitions.keys, contains('Q1_ACTIVE'));
      expect(validTransitions.keys, contains('Q1_BREAK'));
      expect(validTransitions.keys, contains('Q2_ACTIVE'));
      expect(validTransitions.keys, contains('HALFTIME'));
      expect(validTransitions.keys, contains('Q3_ACTIVE'));
      expect(validTransitions.keys, contains('Q3_BREAK'));
      expect(validTransitions.keys, contains('Q4_ACTIVE'));
      expect(validTransitions.keys, contains('CHECK_SCORE'));
      expect(validTransitions.keys, contains('OT_ACTIVE'));
      expect(validTransitions.keys, contains('POST_MATCH'));
    });

    test('CHECK_SCORE adalah satu-satunya state dengan 2 opsi transisi', () {
      final branchingStates = validTransitions.entries
          .where((e) => e.value.length > 1)
          .map((e) => e.key)
          .toList();
      expect(branchingStates, equals(['CHECK_SCORE']));
    });
  });

  group('isActiveState', () {
    test('Q1_ACTIVE, Q2_ACTIVE, Q3_ACTIVE, Q4_ACTIVE, OT_ACTIVE adalah active', () {
      expect(isActiveState('Q1_ACTIVE'), isTrue);
      expect(isActiveState('Q2_ACTIVE'), isTrue);
      expect(isActiveState('Q3_ACTIVE'), isTrue);
      expect(isActiveState('Q4_ACTIVE'), isTrue);
      expect(isActiveState('OT_ACTIVE'), isTrue);
    });

    test('state break/halftime/pre/check/post BUKAN active', () {
      expect(isActiveState('PRE_MATCH'), isFalse);
      expect(isActiveState('Q1_BREAK'), isFalse);
      expect(isActiveState('HALFTIME'), isFalse);
      expect(isActiveState('Q3_BREAK'), isFalse);
      expect(isActiveState('CHECK_SCORE'), isFalse);
      expect(isActiveState('POST_MATCH'), isFalse);
    });

    test('state tidak dikenal mengembalikan false', () {
      expect(isActiveState('TIDAK_ADA'), isFalse);
    });
  });
}
