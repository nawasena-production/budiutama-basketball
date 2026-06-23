import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';
import 'package:budiutama_basketball/features/physical_tests/domain/providers/physical_test_provider.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

/// Panel input Beep Test — menampilkan hingga 5 pemain sekaligus dalam
/// kartu PASS/FAIL, sesuai SRS FR-PHY-02 dan UI/UX flow.
///
/// Audio beep_test.mp3 diputar otomatis saat panel terbuka.
/// Setiap kartu yang sudah diinput akan ditandai "Selesai" dan disable.
class BeepTestPanel extends ConsumerStatefulWidget {
  final String sessionId;
  final List<PlayerModel> players; // maksimal 5 pemain per batch
  final VoidCallback onStopSession;
  final VoidCallback? onAllCompleted;

  const BeepTestPanel({
    super.key,
    required this.sessionId,
    required this.players,
    required this.onStopSession,
    this.onAllCompleted,
  });

  @override
  ConsumerState<BeepTestPanel> createState() => _BeepTestPanelState();
}

class _BeepTestPanelState extends ConsumerState<BeepTestPanel> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final Set<String> _completedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _startAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startAudio() async {
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(AssetSource('audio/beep_test.mp3'));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _handlePass(PlayerModel player) async {
    await _saveResult(player, passed: true, level: null, shuttle: null);
  }

  Future<void> _handleFail(PlayerModel player) async {
    final result = await _showFailDialog(player);
    if (result == null) return;
    await _saveResult(
      player,
      passed: false,
      level: result.level,
      shuttle: result.shuttle,
    );
  }

  Future<void> _saveResult(
    PlayerModel player, {
    required bool passed,
    required int? level,
    required int? shuttle,
  }) async {
    final playerDocId = PhysicalTestRepository.derivePlayerDocId(player.id);

    final success =
        await ref.read(physicalTestActionsProvider.notifier).saveBeepResult(
              sessionId: widget.sessionId,
              playerDocId: playerDocId,
              fullPlayerId: player.id,
              fullName: player.fullName,
              // Untuk pemain yang PASS, level/shuttle dianggap maksimum
              // dari level terakhir yang berhasil dilewati (default 0 jika
              // tidak ada input manual — manager dapat mengedit nanti).
              beepLevel: level ?? 0,
              beepShuttle: shuttle ?? 0,
            );

    if (!mounted) return;

    if (success) {
      setState(() => _completedPlayerIds.add(player.id));
      if (_completedPlayerIds.length == widget.players.length) {
        widget.onAllCompleted?.call();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan hasil ${player.fullName}.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<({int level, int shuttle})?> _showFailDialog(
      PlayerModel player) async {
    int level = 1, shuttle = 1;
    return showDialog<({int level, int shuttle})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${player.fullName} — Gagal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan level dan shuttle terakhir:'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(labelText: 'Level'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          setDialogState(() => level = int.tryParse(v) ?? 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      decoration:
                          const InputDecoration(labelText: 'Shuttle'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setDialogState(
                          () => shuttle = int.tryParse(v) ?? 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, (level: level, shuttle: shuttle)),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status audio
        Container(
          padding: const EdgeInsets.all(12),
          color: _isPlaying
              ? const Color(0xFFEAF3DE)
              : const Color(0xFFF4F6F8),
          child: Row(
            children: [
              Icon(
                _isPlaying ? Icons.volume_up : Icons.volume_off,
                color: _isPlaying
                    ? const Color(0xFF3B6D11)
                    : const Color(0xFF6B7A8D),
              ),
              const SizedBox(width: 8),
              Text(_isPlaying
                  ? 'Audio Beep Test berjalan'
                  : 'Audio berhenti'),
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
        const SizedBox(height: 16),
        // Kartu pemain — responsif, tanpa scroll pada layar lebar
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return ListView(
                  children: widget.players
                      .map((p) => _buildPlayerCard(p))
                      .toList(),
                );
              }
              return Row(
                children: widget.players
                    .map((p) => Expanded(child: _buildPlayerCard(p)))
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () async {
            await _stopAudio();
            widget.onStopSession();
          },
          icon: const Icon(Icons.stop, color: Colors.red),
          label: const Text('Stop Sesi', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerModel player) {
    final isDone = _completedPlayerIds.contains(player.id);
    return Card(
      margin: const EdgeInsets.all(8),
      color: isDone ? const Color(0xFFEDF1F5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDone)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B6D11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Selesai',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            const SizedBox(height: 8),
            Text(
              '#${player.jerseyNumber}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8420A),
              ),
            ),
            Text(player.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text(player.positionsDisplay,
                style: const TextStyle(
                    color: Color(0xFF6B7A8D), fontSize: 12)),
            const SizedBox(height: 16),
            if (!isDone) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePass(player),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B6D11),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('PASS', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleFail(player),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA32D2D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('FAIL', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
