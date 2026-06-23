import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Memonitor `FirebaseFirestore.instance.snapshotsInSync()` — stream ini
/// memancarkan event setiap kali SEMUA listener Firestore aktif di app
/// sudah menerima data terbaru dari server (bukan dari cache lokal).
///
/// Catatan penting: stream ini TIDAK secara eksplisit memberi tahu
/// "device sedang offline" — ia hanya berhenti memancarkan event baru
/// saat tidak ada sinkronisasi terjadi. Karena itu kita memakai
/// `AsyncValue.when` dengan loading/error state, BUKAN sekadar
/// `.hasValue`, supaya jeda singkat di awal (sebelum event pertama
/// diterima) tidak langsung ditampilkan sebagai "Offline" yang
/// menyesatkan Statistician.
final firestoreSyncStatusProvider = StreamProvider<void>((ref) {
  return FirebaseFirestore.instance.snapshotsInSync();
});

class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(firestoreSyncStatusProvider);

    final (color, label) = syncStatus.when(
      data: (_) => (Colors.green, 'Firestore'),
      loading: () => (Colors.amber, 'Menyambungkan…'),
      error: (_, __) => (Colors.red, 'Offline'),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
