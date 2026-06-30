import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/lineup_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';

/// Bottom Panel — proses substitusi pemain dua langkah (SRS FR-LMS-07):
/// 1. Pilih pemain KELUAR (dari on-court)
/// 2. Pilih pemain MASUK (dari bench + yang belum pernah bermain)
/// 3. Konfirmasi
///
/// Pemain yang belum pernah bermain (tidak punya dokumen `lineups`) diambil
/// dari roster aktif tim via [activePLayersStreamProvider] — saat mereka
/// dipilih sebagai "IN", [SubstitutionNotifier.ensureBenchPlayerInitialized]
/// dipanggil terlebih dahulu untuk membuat dokumen lineup mereka sebelum
/// substitusi dikonfirmasi.
class SubstitutionPanel extends ConsumerStatefulWidget {
  final String matchId;
  const SubstitutionPanel({super.key, required this.matchId});

  @override
  ConsumerState<SubstitutionPanel> createState() => _SubstitutionPanelState();
}

class _SubstitutionPanelState extends ConsumerState<SubstitutionPanel> {
  String? _selectedOutId;  // lineup doc ID pemain KELUAR
  String? _selectedInId;   // statsDocId pemain MASUK (bisa dari lineup atau roster)
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchStreamProvider(widget.matchId));
    final allLineupsAsync = ref.watch(allLineupStreamProvider(widget.matchId));
    final timerAsync = ref.watch(timerStateStreamProvider(widget.matchId));

    final teamId = matchAsync.valueOrNull?.homeTeamId;
    final rosterAsync = teamId != null
        ? ref.watch(activePLayersStreamProvider(teamId))
        : const AsyncData<List<PlayerModel>>([]);

    final allLineups = allLineupsAsync.valueOrNull ?? const [];
    final roster = rosterAsync.valueOrNull ?? const [];

    final onCourt = allLineups.where((l) => l.isOnCourt).toList();
    final offCourt = allLineups.where((l) => !l.isOnCourt).toList();

    // Pemain dari roster yang BELUM punya lineup doc sama sekali
    final lineupPlayerIds = allLineups.map((l) => l.playerId).toSet();
    final neverPlayed = roster
        .where((p) => !lineupPlayerIds.contains(p.id))
        .toList();

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Substitusi',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(width: 12),

          // Pemain KELUAR
          Expanded(
            child: _SubPanel(
              label: 'Pemain KELUAR',
              items: onCourt.map((l) => _SubItem(
                id: l.id,
                label: '#${l.jerseyNumber} ${l.fullName}',
                isSelected: _selectedOutId == l.id,
                style: _SubItemStyle.out,
              )).toList(),
              onSelect: (id) => setState(() {
                _selectedOutId = _selectedOutId == id ? null : id;
              }),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: Color(0xFF475569), size: 18),
          ),

          // Pemain MASUK — gabungan off-court (lineup doc ada) + belum pernah main
          Expanded(
            child: _SubPanel(
              label: 'Pemain MASUK (bench)',
              items: [
                ...offCourt.map((l) => _SubItem(
                  id: l.id,       // statsDocId (jersey_inisial)
                  label: '#${l.jerseyNumber} ${l.fullName}',
                  isSelected: _selectedInId == l.id,
                  style: _SubItemStyle.bench,
                )),
                ...neverPlayed.map((p) {
                  // Derive statsDocId dari player ID penuh (jersey_inisial)
                  final statsDocId = _deriveStatsDocId(p.id);
                  return _SubItem(
                    id: statsDocId,
                    label: '#${p.jerseyNumber} ${p.fullName} *',
                    isSelected: _selectedInId == statsDocId,
                    style: _SubItemStyle.bench,
                  );
                }),
              ],
              onSelect: (id) => setState(() {
                _selectedInId = _selectedInId == id ? null : id;
              }),
            ),
          ),

          const SizedBox(width: 12),
          FilledButton(
            onPressed: (_selectedOutId != null &&
                    _selectedInId != null &&
                    !_isLoading)
                ? () => _confirmSubstitution(
                      context: context,
                      allLineups: allLineups,
                      neverPlayed: neverPlayed,
                      timerState: timerAsync.valueOrNull,
                    )
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8420A),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Konfirmasi Sub',
                    style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSubstitution({
    required BuildContext context,
    required List<LineupModel> allLineups,
    required List<PlayerModel> neverPlayed,
    required TimerStateModel? timerState,
  }) async {
    final outId = _selectedOutId;
    final inId = _selectedInId;
    if (outId == null || inId == null) return;

    // Simpan messenger sebelum async gap (showDialog) agar BuildContext
    // tidak diakses lintas await (use_build_context_synchronously — M2).
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final outName = _findLineupById(allLineups, outId)?.fullName ?? outId;
        final inName = _findInPlayerName(allLineups, neverPlayed, inId);
        return AlertDialog(
          title: const Text('Konfirmasi Substitusi'),
          content: Text(
            'Keluarkan $outName dan masukkan $inName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final currentQuarter = timerState?.quarter ?? 1;
      final currentTimeRemaining = timerState != null
          ? currentRemainingSeconds(timerState)
          : 0.0;
      final userId = await ref.read(currentUserDocIdProvider.future);
      if (userId == null) return;

      final outLineup = _findLineupById(allLineups, outId);
      if (outLineup == null) return;

      // Tentukan apakah pemain IN sudah punya lineup doc atau belum
      final inLineup = _findLineupById(allLineups, inId);
      final inPlayer = _findNeverPlayedByStatsDocId(neverPlayed, inId);
      bool success;

      if (inLineup != null) {
        success = await ref
            .read(substitutionProvider(widget.matchId).notifier)
            .substitute(
              playerOut: outLineup,
              playerIn: inLineup,
              currentQuarter: currentQuarter,
              currentTimeRemaining: currentTimeRemaining,
              createdBy: userId,
            );
      } else if (inPlayer != null) {
        success = await ref
            .read(substitutionProvider(widget.matchId).notifier)
            .substituteWithNewPlayer(
              playerOut: outLineup,
              newPlayerStatsDocId: inId,
              newPlayerId: inPlayer.id,
              newPlayerFullName: inPlayer.fullName,
              newPlayerJerseyNumber: inPlayer.jerseyNumber,
              newPlayerPosition: inPlayer.primaryPosition,
              currentQuarter: currentQuarter,
              currentTimeRemaining: currentTimeRemaining,
              createdBy: userId,
            );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Data pemain tidak ditemukan.')),
        );
        return;
      }

      if (!success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Substitusi gagal. Coba lagi.')),
        );
        return;
      }

      // Reset pilihan setelah berhasil
      if (mounted) {
        setState(() {
          _selectedOutId = null;
          _selectedInId = null;
        });
      }
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Ambil dua bagian pertama dari player ID: '{jersey}_{inisial}_{teamId}'
  // → '{jersey}_{inisial}'. Sama dengan derivePlayerStatsDocId() di
  // match_action_provider.dart. Tidak boleh pakai split('_putra') karena
  // tim bisa punya suffix lain (contoh: _smaputra2526 → patah di 'putra').
  String _deriveStatsDocId(String fullPlayerId) {
    final parts = fullPlayerId.split('_');
    return parts.length >= 2 ? '${parts[0]}_${parts[1]}' : fullPlayerId;
  }

  LineupModel? _findLineupById(List<LineupModel> list, String id) {
    for (final l in list) {
      if (l.id == id) return l;
    }
    return null;
  }

  PlayerModel? _findNeverPlayedByStatsDocId(
    List<PlayerModel> neverPlayed,
    String statsDocId,
  ) {
    for (final p in neverPlayed) {
      if (_deriveStatsDocId(p.id) == statsDocId) return p;
    }
    return null;
  }

  String _findInPlayerName(
    List<LineupModel> allLineups,
    List<PlayerModel> neverPlayed,
    String statsDocId,
  ) {
    for (final l in allLineups) {
      if (l.id == statsDocId) return l.fullName;
    }
    for (final p in neverPlayed) {
      if (_deriveStatsDocId(p.id) == statsDocId) return p.fullName;
    }
    return statsDocId;
  }
}

class _SubItem {
  final String id;
  final String label;
  final bool isSelected;
  final _SubItemStyle style;

  const _SubItem({
    required this.id,
    required this.label,
    required this.isSelected,
    required this.style,
  });
}

enum _SubItemStyle { out, bench }

class _SubPanel extends StatelessWidget {
  final String label;
  final List<_SubItem> items;
  final ValueChanged<String> onSelect;

  const _SubPanel({
    required this.label,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((item) => _Pill(item: item, onSelect: onSelect)).toList(),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final _SubItem item;
  final ValueChanged<String> onSelect;

  const _Pill({required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = item.isSelected
        ? item.style == _SubItemStyle.out
            ? (
                const Color(0xFF450A0A),
                const Color(0xFFE24B4A),
                const Color(0xFFFCA5A5),
              )
            : (
                const Color(0xFF052E16),
                const Color(0xFF22C55E),
                const Color(0xFF86EFAC),
              )
        : (
            const Color(0xFF0F172A),
            const Color(0xFF334155),
            const Color(0xFF94A3B8),
          );

    return GestureDetector(
      onTap: () => onSelect(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          item.label,
          style: TextStyle(color: fg, fontSize: 10),
        ),
      ),
    );
  }
}
