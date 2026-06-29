import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_result_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';
import 'package:budiutama_basketball/features/physical_tests/domain/providers/physical_test_provider.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

/// Panel input hasil tes berbasis waktu — T-Test dan Sprint 20m.
///
/// Berbeda dengan Beep Test (PASS/FAIL), tes ini menggunakan stopwatch
/// manual: Statistician/Coach menekan Start, lalu Stop saat pemain
/// menyelesaikan lintasan, dan waktu otomatis terisi ke field input.
class TimedTestPanel extends ConsumerStatefulWidget {
  final String sessionId;
  final String testType; // 't_test' | 'sprint_20m'
  final List<PlayerModel> players;
  final VoidCallback onStopSession;

  const TimedTestPanel({
    super.key,
    required this.sessionId,
    required this.testType,
    required this.players,
    required this.onStopSession,
  });

  @override
  ConsumerState<TimedTestPanel> createState() => _TimedTestPanelState();
}

class _TimedTestPanelState extends ConsumerState<TimedTestPanel> {
  final Set<String> _completedPlayerIds = {};
  final Map<String, double> _liveResults = {};
  String? _runningPlayerId;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startStopwatch(String playerId) {
    if (_runningPlayerId != null) return;
    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();

    setState(() {
      _runningPlayerId = playerId;
    });

    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _runningPlayerId != null) {
        setState(() {});
      }
    });
  }

  Future<void> _stopStopwatch(PlayerModel player) async {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    final seconds = _stopwatch.elapsedMilliseconds / 1000.0;

    setState(() {
      _liveResults[player.id] = seconds;
      _runningPlayerId = null;
    });

    final playerDocId = PhysicalTestRepository.derivePlayerDocId(player.id);
    final success =
        await ref.read(physicalTestActionsProvider.notifier).saveTimedResult(
              sessionId: widget.sessionId,
              playerDocId: playerDocId,
              fullPlayerId: player.id,
              fullName: player.fullName,
              timeSeconds: seconds,
            );

    if (!mounted) return;
    if (success) {
      setState(() => _completedPlayerIds.add(player.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan waktu ${player.fullName}.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  String get _testLabel =>
      widget.testType == 't_test' ? 'T-Test' : 'Sprint 20m';

  Map<String, double> _savedTimes(List<PhysicalTestResultModel> results) {
    final times = <String, double>{};
    for (final result in results) {
      final timeSeconds = result.timeSeconds;
      if (timeSeconds != null) {
        times[result.playerId] = timeSeconds;
      }
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync =
        ref.watch(physicalTestResultsStreamProvider(widget.sessionId));
    final savedResults = resultsAsync.valueOrNull ?? [];
    final savedTimes = _savedTimes(savedResults);

    final completedCount = widget.players.where((player) {
      return _completedPlayerIds.contains(player.id) ||
          savedTimes.containsKey(player.id);
    }).length;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFF4F6F8),
          child: Row(
            children: [
              const Icon(Icons.speed, color: Color(0xFF1A3A5C)),
              const SizedBox(width: 8),
              Text('Tes: $_testLabel',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '$completedCount/${widget.players.length} selesai',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7A8D)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: widget.players.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) =>
                _buildPlayerRow(widget.players[i], savedTimes),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: widget.onStopSession,
          icon: const Icon(Icons.stop, color: Colors.red),
          label: const Text('Stop Sesi', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(PlayerModel player, Map<String, double> savedTimes) {
    final savedTime = savedTimes[player.id];
    final isDone =
        _completedPlayerIds.contains(player.id) || savedTime != null;
    final isRunning = _runningPlayerId == player.id;
    final liveTime = _liveResults[player.id] ?? savedTime;

    return Container(
      color: isDone ? const Color(0xFFEDF1F5) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('#${player.jerseyNumber}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFE8420A))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (liveTime != null)
                  Text('${liveTime.toStringAsFixed(2)} detik',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7A8D))),
              ],
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle, color: Color(0xFF3B6D11))
          else if (isRunning)
            Row(
              children: [
                Text(
                  '${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _stopStopwatch(player),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA32D2D)),
                  child: const Text('STOP'),
                ),
              ],
            )
          else
            FilledButton(
              onPressed: _runningPlayerId == null
                  ? () => _startStopwatch(player.id)
                  : null,
              style:
                  FilledButton.styleFrom(backgroundColor: const Color(0xFF3B6D11)),
              child: const Text('START'),
            ),
        ],
      ),
    );
  }
}
