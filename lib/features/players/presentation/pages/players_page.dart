import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/add_edit_player_bottom_sheet.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/player_list_item.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';
import 'player_detail_page.dart';

/// Halaman utama manajemen pemain.
///
/// Fitur:
/// - Daftar pemain real-time dari Firestore (via stream listener)
/// - Search berdasarkan nama atau nomor jersey
/// - Filter berdasarkan status: Semua / Aktif / Cedera / Non-Aktif
/// - FAB tambah pemain baru (Manager only)
/// - Navigasi ke detail pemain
///
/// Sesuai SRS FR-PLY-01 s.d FR-PLY-06.
class PlayersPage extends ConsumerStatefulWidget {
  /// ID tim yang sedang ditampilkan.
  final String teamId;

  /// Role pengguna yang sedang login (menentukan akses FAB dan aksi edit).
  final String role;

  const PlayersPage({
    super.key,
    required this.teamId,
    required this.role,
  });

  @override
  ConsumerState<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends ConsumerState<PlayersPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // null = semua
  late TabController _tabController;

  static const _statusFilters = [
    (label: 'Semua', value: null),
    (label: 'Aktif', value: 'active'),
    (label: 'Cedera', value: 'injured'),
    (label: 'Non-Aktif', value: 'inactive'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _statusFilter = _statusFilters[_tabController.index].value;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (
      teamId: widget.teamId,
      statusFilter: _statusFilter,
      searchQuery: _searchQuery,
    );
    final filteredAsync = ref.watch(filteredPlayersProvider(args));
    // Untuk total count header
    final allPlayersAsync = ref.watch(playersStreamProvider(widget.teamId));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.role == 'manager'
          ? FloatingActionButton(
              onPressed: _showAddPlayerSheet,
              tooltip: 'Tambah Pemain',
              child: const Icon(Icons.person_add_outlined),
            )
          : null,
      body: Column(
        children: [
          _buildToolbar(allPlayersAsync),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (players) => _buildPlayerList(players),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(AsyncValue<List<PlayerModel>> allAsync) {
    final total = allAsync.valueOrNull?.length ?? 0;
    final active =
        allAsync.valueOrNull?.where((p) => p.status == 'active').length ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama atau nomor jersey...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorWeight: 2.5,
            tabs: _statusFilters.map((f) => Tab(text: f.label)).toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryChip('Total', total.toString(), AppColors.navy),
              _summaryChip('Aktif', active.toString(), AppColors.success),
              _summaryChip(
                'Cedera',
                (allAsync.valueOrNull
                            ?.where((p) => p.status == 'injured')
                            .length ??
                        0)
                    .toString(),
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(List<PlayerModel> players) {
    if (players.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _statusFilter != null;
      return EmptyStateWidget(
        icon: Icons.people_outline,
        message: isFiltered
            ? 'Tidak ada pemain yang sesuai filter.'
            : 'Belum ada pemain di tim ini.\nTambahkan pemain pertama!',
        ctaLabel: widget.role == 'manager' ? 'Tambah Pemain' : null,
        onCtaPressed: widget.role == 'manager' ? _showAddPlayerSheet : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Firestore stream otomatis refresh — invalidate untuk force refresh
        ref.invalidate(playersStreamProvider(widget.teamId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 2, bottom: 88),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return PlayerListItem(
            player: player,
            onTap: () => _navigateToDetail(player),
          );
        },
      ),
    );
  }

  void _navigateToDetail(PlayerModel player) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerDetailPage(
          playerId: player.id,
          teamId: widget.teamId,
          role: widget.role,
        ),
      ),
    );
  }

  void _showAddPlayerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEditPlayerBottomSheet(teamId: widget.teamId),
    );
  }
}
