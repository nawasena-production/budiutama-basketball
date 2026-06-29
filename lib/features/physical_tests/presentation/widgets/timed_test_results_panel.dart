import 'package:flutter/material.dart';

import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_result_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

/// Panel read-only untuk menampilkan hasil T-Test atau Sprint 20m
/// setelah sesi dihentikan (is_stopped_early = true).
class TimedTestResultsPanel extends StatelessWidget {
  final String testType;
  final List<PlayerModel> players;
  final List<PhysicalTestResultModel> results;

  const TimedTestResultsPanel({
    super.key,
    required this.testType,
    required this.players,
    required this.results,
  });

  String get _testLabel =>
      testType == 't_test' ? 'T-Test' : 'Sprint 20m';

  Map<String, PhysicalTestResultModel> get _resultsByPlayerDocId {
    return {for (final r in results) r.id: r};
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = players.where((player) {
      final docId = PhysicalTestRepository.derivePlayerDocId(player.id);
      return _resultsByPlayerDocId[docId]?.timeSeconds != null;
    }).length;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFEAF3DE),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF3B6D11)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hasil $_testLabel — Sesi Selesai',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$completedCount/${players.length} pemain',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7A8D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: players.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) => _buildPlayerRow(players[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(PlayerModel player) {
    final docId = PhysicalTestRepository.derivePlayerDocId(player.id);
    final result = _resultsByPlayerDocId[docId];
    final timeSeconds = result?.timeSeconds;
    final hasResult = timeSeconds != null;

    return Container(
      color: hasResult ? const Color(0xFFEDF1F5) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#${player.jerseyNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8420A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              player.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (hasResult)
            Text(
              '${timeSeconds.toStringAsFixed(2)} detik',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A5C),
              ),
            )
          else
            const Text(
              '—',
              style: TextStyle(color: Color(0xFF6B7A8D)),
            ),
          const SizedBox(width: 8),
          Icon(
            hasResult ? Icons.check_circle : Icons.remove_circle_outline,
            color: hasResult
                ? const Color(0xFF3B6D11)
                : const Color(0xFF6B7A8D),
            size: 20,
          ),
        ],
      ),
    );
  }
}
