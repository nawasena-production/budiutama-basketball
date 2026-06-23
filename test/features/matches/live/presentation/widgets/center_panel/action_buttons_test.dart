import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/matches/live/presentation/widgets/center_panel/action_buttons.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ActionButtons — kPlayerActionButtons (data statis)', () {
    test('berisi tepat 13 tombol aksi sesuai SRS FR-LMS-03', () {
      expect(kPlayerActionButtons, hasLength(13));
    });

    test('hanya 2PT_MADE, 3PT_MADE, MISS_2PT, MISS_3PT yang butuh court overlay', () {
      final needsOverlay = kPlayerActionButtons
          .where((s) => s.needsCourtOverlay)
          .map((s) => s.actionType)
          .toSet();
      expect(
        needsOverlay,
        equals({'2PT_MADE', '3PT_MADE', 'MISS_2PT', 'MISS_3PT'}),
      );
    });

    test('free throw (1PT_MADE, MISS_1PT) TIDAK butuh court overlay', () {
      final ft = kPlayerActionButtons
          .firstWhere((s) => s.actionType == '1PT_MADE');
      final missFt = kPlayerActionButtons
          .firstWhere((s) => s.actionType == 'MISS_1PT');
      expect(ft.needsCourtOverlay, isFalse);
      expect(missFt.needsCourtOverlay, isFalse);
    });

    test('semua actionType unik (tidak ada duplikat tombol)', () {
      final types = kPlayerActionButtons.map((s) => s.actionType).toList();
      expect(types.toSet().length, types.length);
    });
  });

  group('ActionButtons — tampilan grid', () {
    testWidgets('menampilkan 13 tombol saat enabled', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          ActionButtons(enabled: true, onActionTap: (_) {}),
        ),
      );

      // Setiap tombol unik diidentifikasi lewat shortLabel-nya.
      for (final spec in kPlayerActionButtons) {
        expect(find.text(spec.shortLabel), findsOneWidget,
            reason: 'tombol "${spec.shortLabel}" (${spec.actionType}) harus tampil');
      }
    });
  });

  group('ActionButtons — interaksi saat enabled', () {
    testWidgets('tap tombol +2 memanggil onActionTap dengan spec 2PT_MADE',
        (tester) async {
      ActionButtonSpec? tapped;

      await tester.pumpWidget(
        wrapInApp(
          ActionButtons(
            enabled: true,
            onActionTap: (spec) => tapped = spec,
          ),
        ),
      );

      await tester.tap(find.text('+2'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.actionType, '2PT_MADE');
    });

    testWidgets('tap tombol FOUL memanggil onActionTap dengan spec FOUL',
        (tester) async {
      ActionButtonSpec? tapped;

      await tester.pumpWidget(
        wrapInApp(
          ActionButtons(
            enabled: true,
            onActionTap: (spec) => tapped = spec,
          ),
        ),
      );

      await tester.tap(find.text('FOUL'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.actionType, 'FOUL');
    });
  });

  group('ActionButtons — interaksi saat disabled', () {
    testWidgets('tap tombol manapun TIDAK memanggil onActionTap saat enabled=false',
        (tester) async {
      ActionButtonSpec? tapped;

      await tester.pumpWidget(
        wrapInApp(
          ActionButtons(
            enabled: false,
            onActionTap: (spec) => tapped = spec,
          ),
        ),
      );

      await tester.tap(find.text('+2'));
      await tester.pump();

      expect(tapped, isNull,
          reason: 'tombol harus disabled total saat belum ada pemain dipilih');
    });
  });
}
