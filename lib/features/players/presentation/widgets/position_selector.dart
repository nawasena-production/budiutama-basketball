import 'package:flutter/material.dart';

import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

/// Multi-select chip untuk posisi pemain (PG, SG, SF, PF, C).
class PositionSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const PositionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static String label(String pos) {
    switch (pos) {
      case 'PG':
        return 'PG – Point Guard';
      case 'SG':
        return 'SG – Shooting Guard';
      case 'SF':
        return 'SF – Small Forward';
      case 'PF':
        return 'PF – Power Forward';
      case 'C':
        return 'C – Center';
      default:
        return pos;
    }
  }

  static List<String> sortedPositions(Set<String> positions) {
    return positions.toList()
      ..sort(
        (a, b) =>
            kPlayerPositions.indexOf(a).compareTo(kPlayerPositions.indexOf(b)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kPlayerPositions.map((pos) {
        final isSelected = selected.contains(pos);
        return FilterChip(
          label: Text(
            pos,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7A8D),
            ),
          ),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: const Color(0xFF1A3A5C),
          backgroundColor: const Color(0xFFF4F6F8),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF1A3A5C)
                : const Color(0xFFC8D6E5),
          ),
          onSelected: (value) {
            final next = Set<String>.from(selected);
            if (value) {
              next.add(pos);
            } else {
              next.remove(pos);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
