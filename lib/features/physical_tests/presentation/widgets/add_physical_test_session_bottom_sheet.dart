import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_session_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';
import 'package:budiutama_basketball/features/physical_tests/domain/providers/physical_test_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Bottom sheet untuk membuat sesi tes fisik baru.
/// Manager & Coach bisa membuat sesi (SRS FR-PHY-01).
class AddPhysicalTestSessionBottomSheet extends ConsumerStatefulWidget {
  final String teamId;
  final String createdBy;
  /// Tahun ajaran aktif, contoh "2025/2026"
  final String academicYear;

  const AddPhysicalTestSessionBottomSheet({
    super.key,
    required this.teamId,
    required this.createdBy,
    required this.academicYear,
  });

  @override
  ConsumerState<AddPhysicalTestSessionBottomSheet> createState() =>
      _AddPhysicalTestSessionBottomSheetState();
}

class _AddPhysicalTestSessionBottomSheetState
    extends ConsumerState<AddPhysicalTestSessionBottomSheet> {
  String _testType = 'beep_test';
  late String _teamId;
  int _semester = 1;
  DateTime _scheduledAt = DateTime.now();
  bool _isSubmitting = false;

  static const _testTypes = [
    (value: 'beep_test', label: 'Beep Test', icon: Icons.directions_run),
    (value: 't_test', label: 'T-Test', icon: Icons.change_history),
    (value: 'sprint_20m', label: 'Sprint 20m', icon: Icons.speed),
  ];

  String get _generatedId => PhysicalTestRepository.generateSessionId(
        testType: _testType,
        teamId: _teamId,
        scheduledAt: _scheduledAt,
      );

  @override
  void initState() {
    super.initState();
    _teamId = widget.teamId;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final teamsAsync = ref.watch(teamsStreamProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8D6E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sesi Tes Fisik Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A5C)),
            ),
            const SizedBox(height: 20),

            _buildLabel('Tim *'),
            _buildTeamDropdown(teamsAsync),
            const SizedBox(height: 16),

            // Tipe tes
            _buildLabel('Jenis Tes *'),
            Row(
              children: _testTypes.map((t) {
                final isSelected = _testType == t.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _testType = t.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: t.value != 'sprint_20m' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3A5C)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A3A5C)
                              : const Color(0xFFC8D6E5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(t.icon, size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7A8D)),
                          const SizedBox(height: 4),
                          Text(t.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF6B7A8D))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tanggal pelaksanaan
            _buildLabel('Tanggal Pelaksanaan *'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC8D6E5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Color(0xFF6B7A8D)),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy', 'id_ID')
                          .format(_scheduledAt),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1C2B3A)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Semester
            _buildLabel('Semester *'),
            Row(
              children: [1, 2].map((s) {
                final isSelected = _semester == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _semester = s),
                    child: Container(
                      margin: EdgeInsets.only(right: s == 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3A5C).withValues(alpha: 0.1)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A3A5C)
                              : const Color(0xFFC8D6E5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text('Semester $s',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1A3A5C)
                                  : const Color(0xFF6B7A8D))),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preview ID
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tag, size: 14, color: Color(0xFF6B7A8D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ID Sesi: $_generatedId',
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF6B7A8D)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8420A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Mulai Sesi',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _scheduledAt = picked);
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final sessionId = _generatedId;
      final session = PhysicalTestSessionModel(
        id: sessionId,
        teamId: _teamId,
        testType: _testType,
        scheduledAt: _scheduledAt,
        academicYear: widget.academicYear,
        semester: _semester,
        isStoppedEarly: false,
        createdBy: widget.createdBy,
      );

      final success = await ref
          .read(physicalTestActionsProvider.notifier)
          .createSession(sessionId: sessionId, session: session);

      if (success && mounted) {
        Navigator.of(context).pop(sessionId);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal membuat sesi tes fisik.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C2B3A))),
      );

  Widget _buildTeamDropdown(AsyncValue<List<TeamModel>> teamsAsync) {
    return teamsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Gagal memuat tim: $e',
        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
      ),
      data: (teams) {
        final sortedTeams = sortTeamsForDisplay(teams);
        final selectedId = sortedTeams.any((team) => team.id == _teamId)
            ? _teamId
            : (sortedTeams.isNotEmpty ? sortedTeams.first.id : null);
        if (selectedId != null && selectedId != _teamId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _teamId = selectedId);
          });
        }

        return DropdownButtonFormField<String>(
          value: selectedId,
          decoration: InputDecoration(
            hintText: 'Pilih tim',
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC8D6E5)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
          items: sortedTeams
              .map(
                (team) => DropdownMenuItem(
                  value: team.id,
                  child: Text(team.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _teamId = value);
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Pilih tim' : null,
        );
      },
    );
  }
}
