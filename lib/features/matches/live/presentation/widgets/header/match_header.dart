import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/core/utils/timer_calculator.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/timer_provider.dart';
import 'match_timer_widget.dart';
import 'connection_status.dart';

/// Header Match Mode — menampilkan skor, label quarter, timer, info
/// timeout & foul, serta status koneksi Firestore (SRS FR-LMS-01).
///
/// Skor dan quarter diambil real-time dari [matchStreamProvider] (Step 9),
/// bukan dari hardcoded value seperti versi skeleton dev guide.
class MatchHeader extends ConsumerWidget {
  final String matchId;
  const MatchHeader({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchStreamProvider(matchId));
    final statsAsync = ref.watch(livePlayerStatsStreamProvider(matchId));

    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: matchAsync.when(
        loading: () => const SizedBox(
          height: 56,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (e, _) => SizedBox(
          height: 56,
          child: Center(
            child: Text(
              'Gagal memuat data pertandingan',
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ),
        ),
        data: (match) {
          if (match == null) {
            return const SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Pertandingan tidak ditemukan',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            );
          }

          // Total foul tim dihitung agregat dari materialized player_stats
          // (sum field `fouls` semua pemain) — tidak ada field foul
          // terpisah di dokumen match, sesuai struktur Firestore di SDD
          // Section 3.2 (foul disimpan per-pemain di player_stats, bukan
          // sebagai counter tim independen).
          final totalFouls =
              statsAsync.valueOrNull?.fold<int>(0, (sum, s) => sum + s.fouls) ??
                  0;

          return Row(
            children: [
              Expanded(
                child: _ScoreColumn(
                  label: 'BUDI UTAMA',
                  score: match.homeScore,
                ),
              ),
              Column(
                children: [
                  Text(
                    _quarterLabel(match.currentState),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                  MatchTimerWidget(matchId: matchId),
                  const Text(
                    'Server Timestamp sync',
                    style: TextStyle(color: Color(0xFF334155), fontSize: 9),
                  ),
                  const SizedBox(height: 6),
                  _MatchClockControls(
                    matchId: matchId,
                    currentState: match.currentState,
                    quarterDurationMinutes: match.quarterDurationMinutes,
                    otDurationMinutes: match.otDurationMinutes,
                  ),
                ],
              ),
              const SizedBox(width: 32),
              _InfoColumn(
                label: 'FOUL TIM',
                value: '$totalFouls',
                valueColor: totalFouls >= 5
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFCD34D),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _ScoreColumn(
                  label: 'LAWAN',
                  score: match.opponentScore,
                ),
              ),
              const ConnectionStatusIndicator(),
            ],
          );
        },
      ),
    );
  }

  /// Menerjemahkan `current_state` menjadi label singkat untuk header.
  /// Contoh: Q1_ACTIVE → "Q1", Q1_BREAK → "Q1 BREAK", HALFTIME →
  /// "HALFTIME", OT_ACTIVE → "OT", POST_MATCH → "SELESAI".
  static String _quarterLabel(String currentState) {
    switch (currentState) {
      case 'PRE_MATCH':
        return 'PRA-PERTANDINGAN';
      case 'Q1_ACTIVE':
        return 'Q1';
      case 'Q1_BREAK':
        return 'Q1 — JEDA';
      case 'Q2_ACTIVE':
        return 'Q2';
      case 'HALFTIME':
        return 'HALFTIME';
      case 'Q3_ACTIVE':
        return 'Q3';
      case 'Q3_BREAK':
        return 'Q3 — JEDA';
      case 'Q4_ACTIVE':
        return 'Q4';
      case 'CHECK_SCORE':
        return 'CEK SKOR';
      case 'OT_ACTIVE':
        return 'OT';
      case 'POST_MATCH':
        return 'SELESAI';
      default:
        return currentState;
    }
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreColumn({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        Text(
          '$score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MatchClockControls extends ConsumerStatefulWidget {
  final String matchId;
  final String currentState;
  final int quarterDurationMinutes;
  final int otDurationMinutes;

  const _MatchClockControls({
    required this.matchId,
    required this.currentState,
    required this.quarterDurationMinutes,
    required this.otDurationMinutes,
  });

  @override
  ConsumerState<_MatchClockControls> createState() =>
      _MatchClockControlsState();
}

class _MatchClockControlsState extends ConsumerState<_MatchClockControls> {
  // Flag lokal per-widget untuk mencegah double-tap. Sengaja TIDAK memakai
  // matchActionsProvider.isLoading karena provider itu non-family dan
  // shared — loading dari createMatch/cancelMatch di halaman lain akan
  // memblokir tombol live match secara keliru (M5).
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final timerState =
        ref.watch(timerStateStreamProvider(widget.matchId)).valueOrNull;
    final timerControlState = ref.watch(timerControlProvider(widget.matchId));
    final isBusy = _isBusy || timerControlState.isLoading;
    final isRunning = timerState?.isRunning ?? false;
    final quarter = timerState?.quarter ?? 1;

    if (widget.currentState == 'PRE_MATCH') {
      return _HeaderControlButton(
        icon: Icons.play_arrow_rounded,
        label: 'START MATCH',
        foreground: const Color(0xFF0F172A),
        background: const Color(0xFFFCD34D),
        onPressed: isBusy ? null : () => _startMatchClock(context),
      );
    }

    if (!_isClockControllable(widget.currentState)) {
      final nextState = _nextStateFor(widget.currentState);
      if (nextState == null) return const SizedBox(height: 30);
      return _HeaderControlButton(
        icon: nextState.endsWith('_ACTIVE')
            ? Icons.play_arrow_rounded
            : Icons.skip_next_rounded,
        label: _nextStateLabel(widget.currentState),
        foreground: const Color(0xFFE0F2FE),
        background: const Color(0xFF075985),
        onPressed: isBusy
            ? null
            : () => _confirmAndTransitionPeriod(
                  context,
                  timerState: timerState,
                ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderControlButton(
          icon: Icons.play_arrow_rounded,
          label: 'RESUME',
          foreground: const Color(0xFFDCFCE7),
          background: const Color(0xFF166534),
          onPressed: isBusy || isRunning
              ? null
              : () => ref
                  .read(timerControlProvider(widget.matchId).notifier)
                  .resume(currentQuarter: quarter),
        ),
        const SizedBox(width: 6),
        _HeaderControlButton(
          icon: Icons.pause_rounded,
          label: 'PAUSE',
          foreground: const Color(0xFFFFEDD5),
          background: const Color(0xFF9A3412),
          onPressed: isBusy || !isRunning
              ? null
              : () =>
                  ref.read(timerControlProvider(widget.matchId).notifier).pause(),
        ),
        const SizedBox(width: 6),
        _HeaderControlButton(
          icon: Icons.skip_next_rounded,
          label: _nextStateLabel(widget.currentState),
          foreground: const Color(0xFFE0F2FE),
          background: const Color(0xFF075985),
          onPressed: isBusy
              ? null
              : () => _confirmAndTransitionPeriod(
                    context,
                    timerState: timerState,
                  ),
        ),
      ],
    );
  }

  // M7: state transition + timer start dalam satu transaction atomik via
  // startFirstQuarter(). Menggantikan dua write terpisah yang sebelumnya
  // bisa partial-commit jika koneksi terputus di antara keduanya.
  Future<void> _startMatchClock(BuildContext context) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final success =
          await ref.read(matchActionsProvider.notifier).startFirstQuarter(
                matchId: widget.matchId,
                fullDurationSeconds:
                    (widget.quarterDurationMinutes * 60).toDouble(),
              );
      if (!success && mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal memulai pertandingan.')),
        );
      }
    } on AppException catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal memulai pertandingan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  bool _isClockControllable(String state) {
    return state == 'Q1_ACTIVE' ||
        state == 'Q2_ACTIVE' ||
        state == 'Q3_ACTIVE' ||
        state == 'Q4_ACTIVE' ||
        state == 'OT_ACTIVE';
  }

  String _nextStateLabel(String state) {
    switch (state) {
      case 'Q1_ACTIVE':
        return 'END Q1';
      case 'Q1_BREAK':
        return 'START Q2';
      case 'Q2_ACTIVE':
        return 'END Q2';
      case 'HALFTIME':
        return 'START Q3';
      case 'Q3_ACTIVE':
        return 'END Q3';
      case 'Q3_BREAK':
        return 'START Q4';
      case 'Q4_ACTIVE':
        return 'CHECK';
      case 'CHECK_SCORE':
        return 'FINISH';
      case 'OT_ACTIVE':
        return 'END OT';
      default:
        return 'NEXT';
    }
  }

  String? _nextStateFor(String state) {
    switch (state) {
      case 'Q1_ACTIVE':
        return 'Q1_BREAK';
      case 'Q1_BREAK':
        return 'Q2_ACTIVE';
      case 'Q2_ACTIVE':
        return 'HALFTIME';
      case 'HALFTIME':
        return 'Q3_ACTIVE';
      case 'Q3_ACTIVE':
        return 'Q3_BREAK';
      case 'Q3_BREAK':
        return 'Q4_ACTIVE';
      case 'Q4_ACTIVE':
        return 'CHECK_SCORE';
      case 'CHECK_SCORE':
        return 'POST_MATCH';
      case 'OT_ACTIVE':
        return 'POST_MATCH';
      default:
        return null;
    }
  }

  Future<void> _confirmAndTransitionPeriod(
    BuildContext context, {
    required TimerStateModel? timerState,
  }) async {
    final nextState = _nextStateFor(widget.currentState);
    if (nextState == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_dialogTitleFor(nextState)),
        content: Text(_dialogMessageFor(nextState)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (_isBusy) return;
    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final currentTimeRemaining =
          timerState != null ? currentRemainingSeconds(timerState) : 0.0;
      final success =
          await ref.read(matchActionsProvider.notifier).transitionLiveState(
                matchId: widget.matchId,
                nextState: nextState,
                currentTimeRemaining: currentTimeRemaining,
                quarterDurationSeconds:
                    (widget.quarterDurationMinutes * 60).toDouble(),
                otDurationSeconds: (widget.otDurationMinutes * 60).toDouble(),
              );
      if (!success && mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal mengubah periode.')),
        );
      }
    } on AppException catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal mengubah periode.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _dialogTitleFor(String nextState) {
    switch (nextState) {
      case 'Q2_ACTIVE':
        return 'Mulai Quarter 2?';
      case 'Q3_ACTIVE':
        return 'Mulai Quarter 3?';
      case 'Q4_ACTIVE':
        return 'Mulai Quarter 4?';
      case 'POST_MATCH':
        return 'Selesaikan Pertandingan?';
      default:
        return 'Ubah Periode?';
    }
  }

  String _dialogMessageFor(String nextState) {
    switch (nextState) {
      case 'Q1_BREAK':
      case 'HALFTIME':
      case 'Q3_BREAK':
      case 'CHECK_SCORE':
      case 'POST_MATCH':
        return 'Menit bermain pemain yang sedang di lapangan akan dihitung '
            'sampai waktu timer saat ini.';
      case 'Q2_ACTIVE':
      case 'Q3_ACTIVE':
      case 'Q4_ACTIVE':
        return 'Timer akan di-reset ke durasi quarter penuh dan pemain '
            'on-court memulai stint baru.';
      default:
        return 'Lanjutkan transisi periode pertandingan?';
    }
  }
}

class _HeaderControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  const _HeaderControlButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: const Color(0xFF334155),
          foregroundColor: foreground,
          disabledForegroundColor: const Color(0xFF64748B),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
