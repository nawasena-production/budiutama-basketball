import 'package:flutter/material.dart';

/// Badge status pemain: active | injured | inactive
/// Digunakan di list item dan profil pemain.
class PlayerStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const PlayerStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.dotColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _configFor(String status) {
    switch (status) {
      case 'active':
        return _StatusConfig(
          label: 'Aktif',
          bgColor: const Color(0xFFEAF3DE),
          borderColor: const Color(0xFF639922),
          dotColor: const Color(0xFF3B6D11),
          textColor: const Color(0xFF27500A),
        );
      case 'injured':
        return _StatusConfig(
          label: 'Cedera',
          bgColor: const Color(0xFFFAEEDA),
          borderColor: const Color(0xFFEF9F27),
          dotColor: const Color(0xFFBA7517),
          textColor: const Color(0xFF633806),
        );
      case 'inactive':
        return _StatusConfig(
          label: 'Non-Aktif',
          bgColor: const Color(0xFFF1EFE8),
          borderColor: const Color(0xFF888780),
          dotColor: const Color(0xFF5F5E5A),
          textColor: const Color(0xFF444441),
        );
      default:
        return _StatusConfig(
          label: status,
          bgColor: const Color(0xFFF1EFE8),
          borderColor: const Color(0xFF888780),
          dotColor: const Color(0xFF5F5E5A),
          textColor: const Color(0xFF444441),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.dotColor,
    required this.textColor,
  });
}
