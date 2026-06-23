import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Stopwatch _stopwatch = Stopwatch();
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(const Duration(milliseconds: 100), (i) => i);
  }

  void _startStopwatch(String playerId) {
    setState(() {
      _runningPlayerId = playerId;
      _stopwatch = Stopwatch()..start();
    });
  }

  Future<void> _stopStopwatch(PlayerModel player) async {
    _stopwatch.stop();
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

  @override
  Widget build(BuildContext context) {
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
                '${_completedPlayerIds.length}/${widget.players.length} selesai',
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
            itemBuilder: (ctx, i) => _buildPlayerRow(widget.players[i]),
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

  Widget _buildPlayerRow(PlayerModel player) {
    final isDone = _completedPlayerIds.contains(player.id);
    final isRunning = _runningPlayerId == player.id;
    final liveTime = _liveResults[player.id];

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
            StreamBuilder<int>(
              stream: _ticker,
              builder: (_, __) => Row(
                children: [
                  Text(
                    '${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A5C)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _stopStopwatch(player),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFA32D2D)),
                    child: const Text('STOP'),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed: () => _startStopwatch(player.id),
              style:
                  FilledButton.styleFrom(backgroundColor: const Color(0xFF3B6D11)),
              child: const Text('START'),
            ),
        ],
      ),
    );
  }
}
