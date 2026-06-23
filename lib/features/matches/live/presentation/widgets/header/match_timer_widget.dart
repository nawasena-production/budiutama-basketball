import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/timer_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';

/// Menampilkan hitungan mundur timer pertandingan.
///
/// Listener Firestore ([timerStateStreamProvider]) hanya memberi tahu
/// KAPAN `is_running`/`seconds_at_start`/`started_at` berubah (yaitu
/// saat Statistician menekan START/PAUSE/RESUME) — bukan setiap detik.
/// Supaya angka di layar tetap berdetak setiap 100ms TANPA membombardir
/// Firestore dengan write, widget ini menyimpan [TimerStateModel]
/// terbaru yang diterima dari stream, lalu menjalankan
/// `Timer.periodic(100ms)` LOKAL yang hanya memanggil
/// `currentRemainingSeconds()` ulang menggunakan state yang sama
/// (SDD Section 3.5 — kalkulasi sisi client, bukan polling server).
class MatchTimerWidget extends ConsumerStatefulWidget {
  final String matchId;
  const MatchTimerWidget({super.key, required this.matchId});

  @override
  ConsumerState<MatchTimerWidget> createState() => _MatchTimerWidgetState();
}

class _MatchTimerWidgetState extends ConsumerState<MatchTimerWidget> {
  Timer? _ticker;
  TimerStateModel _latestState = const TimerStateModel();
  double _displaySeconds = 600.0;

  @override
  void initState() {
    super.initState();
    _displaySeconds = currentRemainingSeconds(_latestState);
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      final next = currentRemainingSeconds(_latestState);
      // Hindari rebuild yang sia-sia kalau timer sedang PAUSE — nilainya
      // tidak berubah sama sekali sampai ada event baru dari stream.
      if (next != _displaySeconds) {
        setState(() => _displaySeconds = next);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen dipakai (bukan ref.watch langsung untuk _latestState)
    // supaya update dari Firestore disimpan ke state lokal tanpa memicu
    // rebuild ganda — rebuild visual murni didorong oleh Timer.periodic
    // di atas, sedangkan ref.listen hanya menyegarkan acuan kalkulasi.
    ref.listen<AsyncValue<TimerStateModel>>(
      timerStateStreamProvider(widget.matchId),
      (previous, next) {
        next.whenData((state) {
          _latestState = state;
          final recalculated = currentRemainingSeconds(state);
          if (mounted) setState(() => _displaySeconds = recalculated);
        });
      },
    );

    final runningLow = isTimeRunningLow(_displaySeconds);

    return Text(
      formatSeconds(_displaySeconds),
      style: TextStyle(
        color: runningLow ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }
}
