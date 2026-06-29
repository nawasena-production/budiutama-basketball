import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_session_model.dart';
import 'package:budiutama_basketball/features/physical_tests/domain/providers/physical_test_provider.dart';
import 'package:budiutama_basketball/features/physical_tests/presentation/widgets/add_physical_test_session_bottom_sheet.dart';
import 'package:budiutama_basketball/features/physical_tests/presentation/widgets/beep_test_panel.dart';
import 'package:budiutama_basketball/features/physical_tests/presentation/widgets/timed_test_panel.dart';
import 'package:budiutama_basketball/features/physical_tests/presentation/widgets/timed_test_results_panel.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman utama Physical Test Management.
///
/// Tab per jenis tes: Beep Test, T-Test, Sprint 20m.
/// Manager & Coach: buat sesi baru, mulai sesi, input hasil.
/// Player: lihat riwayat hasil tes milik sendiri (read-only, ditangani
/// terpisah lewat halaman Statistik di Step 18).
class PhysicalTestPage extends ConsumerStatefulWidget {
  final String teamId;
  final String role;
  final String createdBy;
  final String academicYear;

  const PhysicalTestPage({
    super.key,
    required this.teamId,
    required this.role,
    required this.createdBy,
    this.academicYear = '2025/2026',
  });

  @override
  ConsumerState<PhysicalTestPage> createState() => _PhysicalTestPageState();
}

class _PhysicalTestPageState extends ConsumerState<PhysicalTestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _testTypes = ['beep_test', 't_test', 'sprint_20m'];
  static const _testLabels = ['Beep Test', 'T-Test', 'Sprint 20m'];

  bool get _canManage => widget.role == 'manager' || widget.role == 'coach';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _testTypes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedTestTypeProvider.notifier).state =
            _testTypes[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionId = ref.watch(activeSessionIdProvider);
    final activeSessionTeamId =
        ref.watch(activeSessionTeamIdProvider) ?? widget.teamId;

    // Jika ada sesi aktif, tampilkan panel input langsung (fullscreen-ish).
    if (activeSessionId != null) {
      return _ActiveSessionView(
        sessionId: activeSessionId,
        teamId: activeSessionTeamId,
        onClose: () {
          ref.read(activeSessionIdProvider.notifier).state = null;
          ref.read(activeSessionTeamIdProvider.notifier).state = null;
        },
      );
    }

    return AppPageScaffold(
      title: 'Tes Fisik',
      subtitle: 'Sesi beep test, agility, dan sprint pemain',
      icon: Icons.directions_run_outlined,
      floatingActionButton: _canManage
          ? FloatingActionButton(
              onPressed: _showAddSessionSheet,
              tooltip: 'Sesi Tes Fisik Baru',
              child: const Icon(Icons.add),
            )
          : null,
      bottom: Column(
        children: [
          const TeamToggleWidget(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _testLabels.map((l) => Tab(text: l)).toList(),
          ),
        ],
      ),
      child: TabBarView(
        controller: _tabController,
        children: _testTypes
            .map((type) => _SessionList(
                  teamId: widget.teamId,
                  testType: type,
                  canManage: _canManage,
                ))
            .toList(),
      ),
    );
  }

  void _showAddSessionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddPhysicalTestSessionBottomSheet(
        teamId: widget.teamId,
        createdBy: widget.createdBy,
        academicYear: widget.academicYear,
      ),
    );
  }
}

// ── DAFTAR SESI ───────────────────────────────────────────────────────────

class _SessionList extends ConsumerWidget {
  final String teamId;
  final String testType;
  final bool canManage;

  const _SessionList({
    required this.teamId,
    required this.testType,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(
      physicalTestSessionsProvider((teamId: teamId, testType: testType)),
    );

    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.fitness_center_outlined,
            message: 'Belum ada sesi tes untuk kategori ini.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: sessions.length,
          itemBuilder: (ctx, i) => _SessionCard(
            session: sessions[i],
            canManage: canManage,
            onStart: () {
              ref.read(activeSessionIdProvider.notifier).state = sessions[i].id;
              ref.read(activeSessionTeamIdProvider.notifier).state =
                  sessions[i].teamId;
            },
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final PhysicalTestSessionModel session;
  final bool canManage;
  final VoidCallback onStart;

  const _SessionCard({
    required this.session,
    required this.canManage,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = session.scheduledAt != null &&
        session.scheduledAt!
            .isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEFF4F8),
          child: Icon(
            session.isStoppedEarly == true
                ? Icons.pause_circle_outline
                : Icons.fitness_center,
            color: const Color(0xFF1A3A5C),
            size: 20,
          ),
        ),
        title: Text(
          session.scheduledAt != null
              ? DateFormat('EEEE, dd MMM yyyy', 'id_ID')
                  .format(session.scheduledAt!)
              : session.id,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          'Semester ${session.semester} • ${session.academicYear}'
          '${session.isStoppedEarly == true ? ' • Dihentikan awal' : ''}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D)),
        ),
        trailing: canManage && !isPast && session.isStoppedEarly != true
            ? FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A5C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Buka', style: TextStyle(fontSize: 12)),
              )
            : TextButton(
                onPressed: onStart,
                child: Text(
                  session.isStoppedEarly == true ? 'Lihat Hasil' : 'Lihat',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
      ),
    );
  }
}

// ── SESI AKTIF (panel input) ────────────────────────────────────────────

class _ActiveSessionView extends ConsumerWidget {
  final String sessionId;
  final String teamId;
  final VoidCallback onClose;

  const _ActiveSessionView({
    required this.sessionId,
    required this.teamId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(physicalTestSessionProvider(sessionId));
    final playersAsync = ref.watch(activePLayersStreamProvider(teamId));
    final resultsAsync = ref.watch(physicalTestResultsStreamProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesi Tes Fisik'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmClose(context, ref),
        ),
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (session) {
          if (session == null) {
            return const EmptyStateWidget(
              icon: Icons.error_outline,
              message: 'Sesi tes fisik tidak ditemukan.',
            );
          }

          return playersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (players) {
              if (players.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.group_off_outlined,
                  message: 'Tidak ada pemain aktif di tim ini.',
                );
              }

              final testType = session.testType;
              final isSessionCompleted = session.isStoppedEarly;
              final results = resultsAsync.valueOrNull ?? [];

              // Sesi selesai — T-Test & Sprint 20m: tampilkan hasil saja.
              if (isSessionCompleted &&
                  (testType == 't_test' || testType == 'sprint_20m')) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: TimedTestResultsPanel(
                    testType: testType,
                    players: players,
                    results: results,
                  ),
                );
              }

              // Batch 5 pemain per layar untuk Beep Test (sesuai kapasitas lintasan).
              final batch = players.take(5).toList();

              if (testType == 'beep_test') {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: BeepTestPanel(
                    sessionId: sessionId,
                    players: batch,
                    onStopSession: () => _stopSession(context, ref),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: TimedTestPanel(
                  sessionId: sessionId,
                  testType: testType,
                  players: players,
                  onStopSession: () => _stopSession(context, ref),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Tutup Sesi?',
      content:
          'Sesi akan tetap berjalan di latar belakang. Hasil yang sudah diinput tetap tersimpan.',
      confirmLabel: 'Tutup',
    );
    if (confirmed == true) onClose();
  }

  Future<void> _stopSession(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hentikan Sesi?',
      content:
          'Sesi akan ditandai selesai lebih awal. Hasil yang sudah diinput tetap tersimpan.',
      confirmLabel: 'Hentikan',
    );
    if (confirmed == true) {
      final success = await ref
          .read(physicalTestActionsProvider.notifier)
          .stopSessionEarly(sessionId);
      if (!context.mounted) return;

      if (success) {
        onClose();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghentikan sesi tes fisik.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
