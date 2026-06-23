import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/lineup_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/match_action_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/timer_provider.dart';
import 'action_buttons.dart';
import 'court_overlay.dart';
import 'live_player_stats_table.dart';

/// Center Panel — dua tab sesuai SRS Section 7.1 / FR-LMS-03 & FR-LMS-16:
/// Tab 1 "Input Mode" (tombol aksi + court overlay + kontrol timer +
/// undo, khusus Statistician) dan Tab 2 "Live Player Stats" (tabel
/// real-time, terlihat oleh Coach/Manager/Statistician).
class CenterPanelTabs extends ConsumerWidget {
  final String matchId;
  const CenterPanelTabs({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(centerPanelTabIndexProvider(matchId));

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          _TabBar(matchId: matchId, activeIndex: tabIndex),
          Expanded(
            child: IndexedStack(
              index: tabIndex,
              children: [
                _InputModeTab(matchId: matchId),
                LivePlayerStatsTable(matchId: matchId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  final String matchId;
  final int activeIndex;

  const _TabBar({required this.matchId, required this.activeIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _TabItem(
          label: '📥 Input Mode',
          isActive: activeIndex == 0,
          onTap: () => ref
              .read(centerPanelTabIndexProvider(matchId).notifier)
              .state = 0,
        ),
        _TabItem(
          label: '📊 Live Player Stats',
          isActive: activeIndex == 1,
          onTap: () => ref
              .read(centerPanelTabIndexProvider(matchId).notifier)
              .state = 1,
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFFE8420A) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFFE8420A) : const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab 1 — Input Mode. Menggabungkan: label pemain terpilih, grid 13
/// tombol aksi, court overlay (muncul sebagai overlay penuh saat
/// dibutuhkan), tombol undo, dan kontrol timer PAUSE/RESUME.
class _InputModeTab extends ConsumerWidget {
  final String matchId;
  const _InputModeTab({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLineupId = ref.watch(selectedPlayerLineupIdProvider(matchId));
    final pendingAction = ref.watch(pendingShotActionProvider(matchId));
    final matchAsync = ref.watch(matchStreamProvider(matchId));
    final timerAsync = ref.watch(timerStateStreamProvider(matchId));
    final lineupsAsync = ref.watch(onCourtLineupStreamProvider(matchId));

    final onCourtLineups = lineupsAsync.valueOrNull ?? const [];
    final selectedLineup = _findById(onCourtLineups, selectedLineupId);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLineup != null
                    ? 'Aksi — #${selectedLineup.jerseyNumber} '
                        '${selectedLineup.fullName}'
                    : 'Pilih pemain di panel kiri terlebih dahulu',
                style: const TextStyle(color: Color(0xFF475569), fontSize: 11),
              ),
              const SizedBox(height: 8),
              ActionButtons(
                enabled: selectedLineup != null,
                onActionTap: (spec) => _handleActionTap(
                  context: context,
                  ref: ref,
                  spec: spec,
                  selectedPlayerId: selectedLineup?.playerId,
                ),
              ),
              const SizedBox(height: 8),
              _UndoButton(matchId: matchId),
              const SizedBox(height: 8),
              _TimerControls(matchId: matchId, timerAsync: timerAsync),
            ],
          ),
        ),
        if (pendingAction != null && matchAsync.valueOrNull != null)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F172A),
              child: CourtOverlay(
                actionType: pendingAction,
                onDismiss: () => ref
                    .read(pendingShotActionProvider(matchId).notifier)
                    .state = null,
                onLocationSelected: (result) => _handleShotLocationSelected(
                  context: context,
                  ref: ref,
                  result: result,
                  actionType: pendingAction,
                  selectedPlayerId: selectedLineup?.playerId,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleActionTap({
    required BuildContext context,
    required WidgetRef ref,
    required ActionButtonSpec spec,
    required String? selectedPlayerId,
  }) {
    if (selectedPlayerId == null) return;

    if (spec.needsCourtOverlay) {
      ref.read(pendingShotActionProvider(matchId).notifier).state =
          spec.actionType;
      return;
    }

    // Free throw / aksi non-shot — langsung catat tanpa court overlay.
    _recordSelfAction(
      context: context,
      ref: ref,
      actionType: spec.actionType,
      playerId: selectedPlayerId,
    );
  }

  Future<void> _handleShotLocationSelected({
    required BuildContext context,
    required WidgetRef ref,
    required ShotLocationResult result,
    required String actionType,
    required String? selectedPlayerId,
  }) async {
    ref.read(pendingShotActionProvider(matchId).notifier).state = null;
    if (selectedPlayerId == null) return;

    await _recordSelfAction(
      context: context,
      ref: ref,
      actionType: actionType,
      playerId: selectedPlayerId,
      zone: result.zone,
      shotX: result.x,
      shotY: result.y,
      shotDistanceFt: result.distanceFt,
    );
  }

  Future<void> _recordSelfAction({
    required BuildContext context,
    required WidgetRef ref,
    required String actionType,
    required String playerId,
    String? zone,
    double? shotX,
    double? shotY,
    int? shotDistanceFt,
  }) async {
    final match = ref.read(matchStreamProvider(matchId)).valueOrNull;
    final timerState = ref.read(timerStateStreamProvider(matchId)).valueOrNull;
    final userId = await ref.read(currentUserDocIdProvider.future);

    if (match == null || timerState == null || userId == null) return;

    try {
      await ref.read(matchActionProvider(matchId).notifier).recordAction(
            currentMatchState: match.currentState,
            playerId: playerId,
            actionType: actionType,
            quarter: timerState.quarter,
            timeRemaining: timerState.secondsAtStart,
            createdBy: userId,
            zone: zone,
            shotX: shotX,
            shotY: shotY,
            shotDistanceFt: shotDistanceFt,
            // Court Overlay sudah menampilkan dialog konfirmasi sendiri
            // bila zona tidak sesuai tombol (FR-LMS-14) SEBELUM callback
            // ini terpanggil sama sekali — jadi pada titik ini, validasi
            // ulang di sisi notifier hanya akan menjadi duplikasi UX.
            forceConfirmed: true,
          );
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _UndoButton extends ConsumerWidget {
  final String matchId;
  const _UndoButton({required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleUndo(context, ref),
        icon: const Icon(Icons.undo, size: 16, color: Color(0xFF94A3B8)),
        label: const Text(
          'Undo aksi terakhir',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF475569)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Future<void> _handleUndo(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Aksi Terakhir?'),
        content: const Text(
          'Aksi statistik terakhir akan dibatalkan. Event asli tetap '
          'tersimpan (ditandai dibatalkan), tidak benar-benar dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final userId = await ref.read(currentUserDocIdProvider.future);
    if (userId == null) return;

    final success = await ref
        .read(matchActionProvider(matchId).notifier)
        .undoLastAction(createdBy: userId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Aksi terakhir berhasil dibatalkan.'
                : 'Tidak ada aksi yang bisa dibatalkan.',
          ),
        ),
      );
    }
  }
}

class _TimerControls extends ConsumerWidget {
  final String matchId;
  final AsyncValue<TimerStateModel> timerAsync;

  const _TimerControls({required this.matchId, required this.timerAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = timerAsync.valueOrNull;
    final isRunning = timerState?.isRunning ?? false;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isRunning
                ? null
                : () => ref
                    .read(timerControlProvider(matchId).notifier)
                    .resume(currentQuarter: timerState?.quarter ?? 1),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF334155)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              '▶ RESUME',
              style: TextStyle(
                color: isRunning
                    ? const Color(0xFF334155)
                    : const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: !isRunning
                ? null
                : () =>
                    ref.read(timerControlProvider(matchId).notifier).pause(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF334155)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              '⏸ PAUSE',
              style: TextStyle(
                color: !isRunning
                    ? const Color(0xFF334155)
                    : const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper pencarian sederhana — sengaja TIDAK memakai `firstOrNull` dari
/// `package:collection` karena package tersebut tidak dideklarasikan
/// secara eksplisit di `pubspec.yaml` proyek ini; menghindari menambah
/// dependency baru hanya untuk satu pemanggilan.
LineupModel? _findById(List<LineupModel> list, String? id) {
  if (id == null) return null;
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
}
