import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/matches/dashboard/data/models/match_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/presentation/widgets/starter_picker_widget.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';

/// Halaman detail satu pertandingan.
///
/// Menampilkan:
/// - Info pertandingan (lawan, venue, tanggal, fase)
/// - Konfigurasi timer (hanya Manager, sebelum START MATCH)
/// - Lineup starter picker (hanya Statistician, sebelum START MATCH)
/// - Tombol START MATCH (hanya Statistician, status scheduled)
/// - Skor dan state aktif (saat ongoing)
/// - Rekap hasil (saat finished)
///
/// Sesuai SRS FR-MCH-02, FR-MCH-05, dan UC-05.
class MatchDetailPage extends ConsumerStatefulWidget {
  final String matchId;
  final String role;
  final String teamId;

  const MatchDetailPage({
    super.key,
    required this.matchId,
    required this.role,
    required this.teamId,
  });

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  // Konfigurasi timer (local state untuk form edit)
  int _quarterDuration = 10;
  int _numPeriods = 4;
  int _otDuration = 5;
  bool _timerConfigDirty = false; // ada perubahan yang belum disimpan

  bool _isStartingMatch = false;

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchStreamProvider(widget.matchId));

    return matchAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Pertandingan')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (match) {
        if (match == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pertandingan')),
            body: const Center(child: Text('Pertandingan tidak ditemukan.')),
          );
        }

        // Sync timer config dari Firestore ke local state (sekali saja)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_timerConfigDirty) {
            setState(() {
              _quarterDuration = match.quarterDurationMinutes;
              _numPeriods = match.numPeriods;
              _otDuration = match.otDurationMinutes;
            });
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            title: Text('vs ${match.opponentName}'),
            backgroundColor: const Color(0xFF1A3A5C),
            foregroundColor: Colors.white,
            actions: [
              // Manager: batalkan pertandingan (hanya scheduled)
              if (widget.role == 'manager' && match.status == 'scheduled')
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: 'Batalkan Pertandingan',
                  onPressed: () => _confirmCancel(match),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status card
              _buildStatusCard(match),
              const SizedBox(height: 12),

              // Info pertandingan
              _buildInfoCard(match),
              const SizedBox(height: 12),

              // Timer config (Manager, belum dikunci)
              if (widget.role == 'manager' && !match.timerConfigLocked) ...[
                _buildTimerConfigCard(match),
                const SizedBox(height: 12),
              ],

              // Skor (jika ongoing atau finished)
              if (match.status == 'ongoing' || match.status == 'finished') ...[
                _buildScoreCard(match),
                const SizedBox(height: 12),
              ],

              // Starter picker (Statistician, status scheduled)
              if (widget.role == 'statistician' &&
                  match.status == 'scheduled') ...[
                _buildStarterSection(match),
                const SizedBox(height: 12),
              ],

              // START MATCH button (Statistician only)
              if (widget.role == 'statistician' &&
                  match.status == 'scheduled') ...[
                _buildStartMatchButton(match),
                const SizedBox(height: 12),
              ],

              // Buka Match Mode (saat ongoing — semua role bisa lihat)
              if (match.status == 'ongoing') ...[
                _buildOpenMatchModeButton(match),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── SECTION WIDGETS ───────────────────────────────────────────────────

  Widget _buildStatusCard(MatchModel match) {
    final cfg = _statusConfig(match.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cfg.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cfg.borderColor),
      ),
      child: Row(
        children: [
          Icon(cfg.icon, size: 16, color: cfg.textColor),
          const SizedBox(width: 8),
          Text(
            cfg.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: cfg.textColor,
            ),
          ),
          if (match.status == 'ongoing') ...[
            const SizedBox(width: 8),
            Text(
              '· ${match.currentState.replaceAll('_', ' ')}',
              style: TextStyle(fontSize: 12, color: cfg.textColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(MatchModel match) {
    return _Card(
      title: 'Informasi Pertandingan',
      child: Column(
        children: [
          _infoRow(Icons.people_outline, 'Lawan', match.opponentName),
          _infoRow(Icons.location_on_outlined, 'Venue',
              match.venue.isNotEmpty ? match.venue : '-'),
          _infoRow(
            Icons.calendar_today_outlined,
            'Jadwal',
            match.scheduledAt != null
                ? DateFormat('EEEE, dd MMM yyyy · HH:mm', 'id_ID')
                    .format(match.scheduledAt!)
                : '-',
          ),
          _infoRow(
              Icons.emoji_events_outlined, 'Fase', _phaseLabel(match.phase)),
          _infoRow(
              Icons.home_outlined, 'Tipe', _matchTypeLabel(match.matchType)),
          _infoRow(Icons.timer_outlined, 'Timer',
              '${match.quarterDurationMinutes} menit × ${match.numPeriods} periode'),
        ],
      ),
    );
  }

  Widget _buildTimerConfigCard(MatchModel match) {
    return _Card(
      title: 'Konfigurasi Timer',
      trailing: _timerConfigDirty
          ? TextButton(
              onPressed: () => _saveTimerConfig(match),
              child: const Text('Simpan'),
            )
          : null,
      child: Column(
        children: [
          // Info: dikunci setelah START MATCH
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: Color(0xFFBA7517)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Konfigurasi ini akan dikunci otomatis setelah START MATCH ditekan.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF633806)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Durasi per quarter
          _timerConfigRow(
            'Durasi per Quarter',
            DropdownButton<int>(
              value: _quarterDuration,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (int i = 1; i <= 20; i++)
                  DropdownMenuItem(value: i, child: Text('$i menit')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _quarterDuration = v;
                    _timerConfigDirty = true;
                  });
                }
              },
            ),
          ),

          _timerConfigRow(
            'Jumlah Periode',
            DropdownButton<int>(
              value: _numPeriods,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 Quarter')),
                DropdownMenuItem(value: 2, child: Text('2 Babak')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _numPeriods = v;
                    _timerConfigDirty = true;
                  });
                }
              },
            ),
          ),

          _timerConfigRow(
            'Durasi OT',
            DropdownButton<int>(
              value: _otDuration,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (int i = 1; i <= 10; i++)
                  DropdownMenuItem(value: i, child: Text('$i menit')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _otDuration = v;
                    _timerConfigDirty = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(MatchModel match) {
    return _Card(
      title: 'Skor',
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('Budi Utama',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7A8D))),
                const SizedBox(height: 4),
                Text(
                  match.homeScore.toString(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
              ],
            ),
          ),
          const Text('–',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7A8D))),
          Expanded(
            child: Column(
              children: [
                Text(
                  match.opponentName,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  match.opponentScore.toString(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterSection(MatchModel match) {
    return _Card(
      title: 'Lineup Pemain Starter',
      child: StarterPickerWidget(
        teamId: widget.teamId,
        // onConfirmed: null — konfirmasi dihandle di tombol START MATCH
      ),
    );
  }

  Widget _buildStartMatchButton(MatchModel match) {
    final starters = ref.watch(selectedStartersProvider);
    final isReady = starters.length == 5;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isStartingMatch || !isReady
            ? null
            : () => _confirmStartMatch(match),
        icon: _isStartingMatch
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow, size: 20),
        label: Text(
          isReady
              ? 'MULAI PERTANDINGAN'
              : 'Pilih 5 Starter Terlebih Dahulu (${starters.length}/5)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE8420A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor:
              const Color(0xFFE8420A).withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildOpenMatchModeButton(MatchModel match) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.go('/match/${widget.matchId}'),
        icon: const Icon(Icons.open_in_full, size: 18),
        label: const Text(
          'BUKA MATCH MODE',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1A3A5C),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────

  Future<void> _saveTimerConfig(MatchModel match) async {
    final success =
        await ref.read(matchActionsProvider.notifier).updateTimerConfig(
              match.id,
              quarterDurationMinutes: _quarterDuration,
              numPeriods: _numPeriods,
              otDurationMinutes: _otDuration,
            );

    if (success && mounted) {
      setState(() => _timerConfigDirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfigurasi timer disimpan.'),
          backgroundColor: Color(0xFF3B6D11),
        ),
      );
    }
  }

  Future<void> _confirmStartMatch(MatchModel match) async {
    final starters = ref.read(selectedStartersProvider);
    final starterNames =
        starters.map((p) => '#${p.jerseyNumber} ${p.fullName}').join('\n');

    final confirmed = await showConfirmDialog(
      context,
      title: 'Mulai Pertandingan?',
      content: 'Pertandingan vs ${match.opponentName} akan dimulai.\n\n'
          'Starter:\n$starterNames\n\n'
          'Timer: ${match.quarterDurationMinutes} menit × ${match.numPeriods} periode.\n'
          'Konfigurasi akan dikunci setelah ini.',
      confirmLabel: 'Mulai',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isStartingMatch = true);

    try {
      final success = await ref.read(matchActionsProvider.notifier).startMatch(
            matchId: match.id,
            starters: starters,
            quarterDurationMinutes: match.quarterDurationMinutes,
          );

      if (success && mounted) {
        // Reset starter selection
        ref.read(selectedStartersProvider.notifier).state = [];
        // Navigasi ke Match Mode fullscreen
        context.go('/match/${match.id}');
      } else if (mounted) {
        final error = ref.read(matchActionsProvider).error;
        _showError(error?.toString() ?? 'Gagal memulai pertandingan.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isStartingMatch = false);
    }
  }

  Future<void> _confirmCancel(MatchModel match) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Pertandingan?',
      content: 'Pertandingan vs ${match.opponentName} akan dibatalkan. '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Batalkan',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(matchActionsProvider.notifier).cancelMatch(match.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  // ── HELPER WIDGETS ────────────────────────────────────────────────────────

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF6B7A8D)),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerConfigRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1C2B3A))),
          ),
          control,
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  ({
    String label,
    Color bgColor,
    Color borderColor,
    Color textColor,
    IconData icon
  }) _statusConfig(String status) {
    switch (status) {
      case 'scheduled':
        return (
          label: 'Terjadwal',
          bgColor: const Color(0xFFE6F1FB),
          borderColor: const Color(0xFF378ADD),
          textColor: const Color(0xFF0C447C),
          icon: Icons.schedule_outlined,
        );
      case 'ongoing':
        return (
          label: 'Sedang Berlangsung',
          bgColor: const Color(0xFFEAF3DE),
          borderColor: const Color(0xFF639922),
          textColor: const Color(0xFF27500A),
          icon: Icons.sports_basketball,
        );
      case 'finished':
        return (
          label: 'Selesai',
          bgColor: const Color(0xFFF1EFE8),
          borderColor: const Color(0xFF888780),
          textColor: const Color(0xFF444441),
          icon: Icons.check_circle_outline,
        );
      case 'cancelled':
        return (
          label: 'Dibatalkan',
          bgColor: const Color(0xFFFCEBEB),
          borderColor: const Color(0xFFE24B4A),
          textColor: const Color(0xFF791F1F),
          icon: Icons.cancel_outlined,
        );
      default:
        return (
          label: status,
          bgColor: const Color(0xFFF1EFE8),
          borderColor: const Color(0xFF888780),
          textColor: const Color(0xFF444441),
          icon: Icons.info_outline,
        );
    }
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'penyisihan':
        return 'Penyisihan';
      case 'perempat_final':
        return 'Perempat Final';
      case 'semifinal':
        return 'Semifinal';
      case 'final':
        return 'Final';
      case 'friendly':
        return 'Friendly / Uji Coba';
      default:
        return phase;
    }
  }

  String _matchTypeLabel(String type) {
    switch (type) {
      case 'home':
        return 'Home';
      case 'away':
        return 'Away';
      case 'neutral':
        return 'Netral';
      default:
        return type;
    }
  }
}

// ── REUSABLE CARD ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Card({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
