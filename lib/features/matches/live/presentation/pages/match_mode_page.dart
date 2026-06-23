import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/live/presentation/widgets/header/match_header.dart';
import 'package:budiutama_basketball/features/matches/live/presentation/widgets/left_panel/player_list_panel.dart';
import 'package:budiutama_basketball/features/matches/live/presentation/widgets/center_panel/center_panel_tabs.dart';
import 'package:budiutama_basketball/features/matches/live/presentation/widgets/right_panel/opponent_actions_panel.dart';
import 'package:budiutama_basketball/features/matches/live/presentation/widgets/timeline/event_timeline.dart';
import 'package:budiutama_basketball/features/matches/live/presentation/widgets/bottom_panel/substitution_panel.dart';

/// Halaman fullscreen Match Mode — entry point Live Match Statistics
/// Engine (PRD Section 4.3 Mode 2, SRS FR-LMS-01 s.d FR-LMS-17).
///
/// Dipaksa landscape dan menyembunyikan status/navigation bar selama
/// halaman ini aktif, lalu mengembalikan orientasi & system UI normal
/// saat ditutup (misal Statistician menekan tombol back setelah
/// POST_MATCH, atau navigasi keluar darurat).
class MatchModePage extends ConsumerStatefulWidget {
  final String matchId;
  const MatchModePage({super.key, required this.matchId});

  @override
  ConsumerState<MatchModePage> createState() => _MatchModePageState();
}

class _MatchModePageState extends ConsumerState<MatchModePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Cegah keluar tidak sengaja dari Match Mode hanya dengan satu
      // tap tombol back fisik Android — Statistician harus memakai
      // navigasi eksplisit (misal tombol "Selesai" setelah POST_MATCH)
      // sesuai NFR-USB-01 (semua aksi kritis maksimal 2 tap, tapi
      // KELUAR dari Match Mode tidak termasuk "aksi kritis" yang harus
      // dimudahkan — justru sebaliknya, harus disengaja).
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Column(
            children: [
              MatchHeader(matchId: widget.matchId),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: PlayerListPanel(matchId: widget.matchId),
                    ),
                    Expanded(
                      child: CenterPanelTabs(matchId: widget.matchId),
                    ),
                    SizedBox(
                      width: 160,
                      child: OpponentActionsPanel(matchId: widget.matchId),
                    ),
                    SizedBox(
                      width: 200,
                      child: EventTimeline(matchId: widget.matchId),
                    ),
                  ],
                ),
              ),
              SubstitutionPanel(matchId: widget.matchId),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Match Mode?'),
        content: const Text(
          'Pertandingan masih berlangsung. Statistik tetap tersimpan, '
          'tapi pastikan timer dalam keadaan PAUSE sebelum keluar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldExit == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
