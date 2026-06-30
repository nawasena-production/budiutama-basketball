import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/features/training/data/models/training_session_model.dart';
import 'package:budiutama_basketball/features/training/data/repositories/training_repository.dart';
import 'package:budiutama_basketball/features/training/domain/providers/training_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Bottom sheet untuk membuat jadwal sesi latihan baru.
/// Hanya dapat diakses oleh Manager (SRS FR-TRN-01).
///
/// Document ID convention: {teamShort}_{tipe}_{YYYYMMDD}
/// Contoh: putra2526_fisik_20260110
class AddTrainingBottomSheet extends ConsumerStatefulWidget {
  final String teamId;
  final String createdBy; // user document ID Manager

  const AddTrainingBottomSheet({
    super.key,
    required this.teamId,
    required this.createdBy,
  });

  @override
  ConsumerState<AddTrainingBottomSheet> createState() =>
      _AddTrainingBottomSheetState();
}

class _AddTrainingBottomSheetState
    extends ConsumerState<AddTrainingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '120');

  String _sessionType = 'physical';
  late String _teamId;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isSubmitting = false;

  static const _sessionTypes = [
    (value: 'physical', label: 'Fisik', icon: Icons.directions_run),
    (value: 'technical', label: 'Teknik', icon: Icons.sports_basketball),
    (value: 'tactical', label: 'Taktik', icon: Icons.analytics_outlined),
    (value: 'scrimmage', label: 'Scrimmage', icon: Icons.group_outlined),
    (value: 'recovery', label: 'Recovery', icon: Icons.spa_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _teamId = widget.teamId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8D6E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buat Jadwal Latihan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Tim *'),
              _buildTeamDropdown(teamsAsync),
              const SizedBox(height: 14),

              // Tipe sesi — horizontal chip selector
              _buildLabel('Tipe Sesi *'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _sessionTypes
                      .map((t) => _TypeChip(
                            label: t.label,
                            icon: t.icon,
                            isSelected: _sessionType == t.value,
                            onTap: () =>
                                setState(() => _sessionType = t.value),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Judul sesi
              _buildLabel('Judul Sesi *'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                    'Contoh: Sesi Fisik — Daya Tahan Aerobik'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul sesi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Tanggal dan waktu
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal *'),
                        _buildDateField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Waktu *'),
                        _buildTimeField(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Lokasi dan durasi
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Lokasi'),
                        TextFormField(
                          controller: _locationController,
                          decoration:
                              _inputDecoration('Contoh: Lapangan Sekolah'),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Durasi (menit)'),
                        TextFormField(
                          controller: _durationController,
                          decoration: _inputDecoration('120'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            final n = int.tryParse(v);
                            if (n == null || n < 15 || n > 300) {
                              return '15–300';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Deskripsi / Program
              _buildLabel('Deskripsi Program'),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                    'Contoh: Fokus pada peningkatan VO2 max dan stamina tim'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Buat Jadwal Latihan',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _scheduledDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('id', 'ID'),
        );
        if (picked != null) setState(() => _scheduledDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _scheduledDate == null && _isSubmitting
                ? Colors.red
                : const Color(0xFFC8D6E5),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF6B7A8D)),
            const SizedBox(width: 8),
            Text(
              _scheduledDate != null
                  ? DateFormat('dd MMM yyyy', 'id_ID').format(_scheduledDate!)
                  : 'Pilih tanggal',
              style: TextStyle(
                fontSize: 13,
                color: _scheduledDate != null
                    ? const Color(0xFF1C2B3A)
                    : const Color(0xFF6B7A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _scheduledTime ?? const TimeOfDay(hour: 15, minute: 0),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _scheduledTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC8D6E5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 16, color: Color(0xFF6B7A8D)),
            const SizedBox(width: 8),
            Text(
              _scheduledTime != null
                  ? _scheduledTime!.format(context)
                  : 'Waktu',
              style: TextStyle(
                fontSize: 13,
                color: _scheduledTime != null
                    ? const Color(0xFF1C2B3A)
                    : const Color(0xFF6B7A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          decoration: _inputDecoration('Pilih tim'),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_scheduledDate == null) {
      _showError('Tanggal latihan wajib diisi.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Gabungkan tanggal + waktu
      final time = _scheduledTime ?? const TimeOfDay(hour: 15, minute: 0);
      final scheduledAt = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        time.hour,
        time.minute,
      );

      final sessionId = TrainingRepository.generateSessionId(
        teamId: _teamId,
        sessionType: _sessionType,
        scheduledAt: scheduledAt,
      );

      final duration = int.tryParse(_durationController.text) ?? 120;

      final session = TrainingSessionModel(
        id: sessionId,
        teamId: _teamId,
        title: _titleController.text.trim(),
        sessionType: _sessionType,
        scheduledAt: scheduledAt,
        durationMinutes: duration,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: widget.createdBy,
      );

      final success = await ref
          .read(trainingActionsProvider.notifier)
          .createSession(sessionId: sessionId, session: session);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal latihan berhasil dibuat.'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
      } else if (mounted) {
        _showError('Gagal membuat jadwal latihan. Coba lagi.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C2B3A),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F6F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF1A3A5C), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}

/// Chip pilih tipe sesi latihan.
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8, bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A3A5C)
              : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A3A5C)
                : const Color(0xFFC8D6E5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF6B7A8D),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : const Color(0xFF1C2B3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
