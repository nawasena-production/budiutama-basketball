import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/events/data/repositories/event_repository.dart';
import 'package:budiutama_basketball/features/events/domain/providers/events_provider.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Bottom sheet untuk membuat event/turnamen baru.
/// Hanya dapat diakses oleh Manager (FR-MCH-01 dari SRS).
///
/// Document ID convention: {tipe}_{namasingkat}_{tahun}
/// Contoh: porseni_kota_2526
class AddEventBottomSheet extends ConsumerStatefulWidget {
  final String teamId;
  final String academicYear; // "2025/2026"
  final String createdBy;

  const AddEventBottomSheet({
    super.key,
    required this.teamId,
    required this.academicYear,
    required this.createdBy,
  });

  @override
  ConsumerState<AddEventBottomSheet> createState() =>
      _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends ConsumerState<AddEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizerController = TextEditingController();
  final _locationController = TextEditingController();

  String _eventType = 'porseni';
  late String _teamId;
  final Set<String> _selectedPlayerIds = {};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  static const _eventTypes = [
    (value: 'porseni', label: 'Porseni'),
    (value: 'popda', label: 'Popda'),
    (value: 'dbl', label: 'DBL'),
    (value: 'liga_pelajar', label: 'Liga Pelajar'),
    (value: 'antar_sekolah', label: 'Antar Sekolah'),
    (value: 'persahabatan', label: 'Persahabatan / Friendly'),
    (value: 'lainnya', label: 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _teamId = widget.teamId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final teamsAsync = ref.watch(teamsStreamProvider);
    final playersAsync = ref.watch(activePLayersStreamProvider(_teamId));

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
                'Buat Event / Turnamen',
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

              // Tipe event
              _buildLabel('Tipe Event *'),
              DropdownButtonFormField<String>(
                initialValue: _eventType,
                decoration: _inputDecoration(null),
                items: _eventTypes
                    .map((t) => DropdownMenuItem(
                          value: t.value,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _eventType = v);
                },
              ),
              const SizedBox(height: 14),

              // Nama event
              _buildLabel('Nama Event *'),
              TextFormField(
                controller: _nameController,
                decoration:
                    _inputDecoration('Contoh: Porseni Tingkat Kota 2025/2026'),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama event tidak boleh kosong';
                  }
                  if (v.trim().length < 5) return 'Nama minimal 5 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Penyelenggara
              _buildLabel('Penyelenggara'),
              TextFormField(
                controller: _organizerController,
                decoration: _inputDecoration(
                    'Contoh: Dinas Pendidikan Kota Yogyakarta'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),

              // Lokasi
              _buildLabel('Lokasi'),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Contoh: GOR Amongraga'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),

              _buildLabel('Pemain yang Dibawa *'),
              _buildPlayerSelector(playersAsync),
              const SizedBox(height: 14),

              // Tanggal mulai dan selesai
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Mulai'),
                        _DatePickerField(
                          value: _startDate,
                          hint: 'Pilih tanggal',
                          onChanged: (d) => setState(() => _startDate = d),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Selesai'),
                        _DatePickerField(
                          value: _endDate,
                          hint: 'Pilih tanggal',
                          firstDate: _startDate,
                          onChanged: (d) => setState(() => _endDate = d),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preview Document ID
              if (_nameController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC8D6E5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF6B7A8D)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ID: ${_previewEventId()}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Buat Event',
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

  String _previewEventId() {
    final yearCode = EventRepository.academicYearToCode(widget.academicYear);
    return EventRepository.generateEventId(
      eventType: _eventType,
      eventName: _nameController.text.trim(),
      academicYearCode: yearCode,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlayerIds.isEmpty) {
      _showError('Pilih minimal 1 pemain yang mengikuti event.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final yearCode = EventRepository.academicYearToCode(widget.academicYear);
      final eventId = EventRepository.generateEventId(
        eventType: _eventType,
        eventName: _nameController.text.trim(),
        academicYearCode: yearCode,
      );

      final event = EventModel(
        id: eventId,
        teamId: _teamId,
        name: _nameController.text.trim(),
        organizer: _organizerController.text.trim(),
        eventType: _eventType,
        location: _locationController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        academicYear: widget.academicYear,
        playerIds: _selectedPlayerIds.toList()..sort(),
        status: 'upcoming',
        createdBy: widget.createdBy,
      );

      final success = await ref
          .read(eventActionsProvider.notifier)
          .createEvent(eventId: eventId, event: event);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dibuat.'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
      } else if (mounted) {
        _showError('Gagal membuat event. Coba lagi.');
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
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
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
            if (mounted) {
              setState(() {
                _teamId = selectedId;
                _selectedPlayerIds.clear();
              });
            }
          });
        }

        return DropdownButtonFormField<String>(
          initialValue: selectedId,
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
            if (value == null) return;
            setState(() {
              _teamId = value;
              _selectedPlayerIds.clear();
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Pilih tim' : null,
        );
      },
    );
  }

  Widget _buildPlayerSelector(AsyncValue<List<PlayerModel>> playersAsync) {
    return playersAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Gagal memuat pemain: $e',
        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
      ),
      data: (players) {
        if (players.isEmpty) {
          return const Text(
            'Tidak ada pemain aktif di tim ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
          );
        }

        final allPlayerIds = players.map((player) => player.id).toSet();
        final allSelected = allPlayerIds.isNotEmpty &&
            allPlayerIds.every(_selectedPlayerIds.contains);

        return SizedBox(
          height: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC8D6E5)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedPlayerIds.length}/${players.length} pemain dipilih',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7A8D),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            if (allSelected) {
                              _selectedPlayerIds.removeAll(allPlayerIds);
                            } else {
                              _selectedPlayerIds.addAll(allPlayerIds);
                            }
                          });
                        },
                        icon: Icon(
                          allSelected
                              ? Icons.check_box_outlined
                              : Icons.select_all,
                          size: 18,
                        ),
                        label:
                            Text(allSelected ? 'Hapus semua' : 'Pilih semua'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final selected = _selectedPlayerIds.contains(player.id);
                      return CheckboxListTile(
                        dense: true,
                        value: selected,
                        title: Text(
                          '#${player.jerseyNumber} ${player.fullName}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedPlayerIds.add(player.id);
                            } else {
                              _selectedPlayerIds.remove(player.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        borderSide: const BorderSide(color: Color(0xFF1A3A5C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}

/// Widget field pilih tanggal — tap untuk buka DatePicker.
class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final DateTime? firstDate;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('id', 'ID'),
        );
        onChanged(picked);
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
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF6B7A8D)),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? DateFormat('dd MMM yyyy', 'id_ID').format(value!)
                  : hint,
              style: TextStyle(
                fontSize: 13,
                color: value != null
                    ? const Color(0xFF1C2B3A)
                    : const Color(0xFF6B7A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
