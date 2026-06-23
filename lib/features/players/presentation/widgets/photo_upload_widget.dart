import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Widget untuk upload dan preview foto pemain.
///
/// Implementasi Free Plan: foto dikompres maksimal 200KB lalu disimpan
/// sebagai base64 string di field `photo_base64` dokumen Firestore.
/// Sesuai PRD Section 6.1 dan SRS FR-PLY-05.
class PhotoUploadWidget extends StatefulWidget {
  /// Base64 string foto yang sudah ada (untuk mode edit).
  final String? currentBase64;

  /// Callback saat foto berhasil dipilih dan dikompres.
  /// Menerima base64 string dengan prefix data URI, atau null jika foto dihapus.
  final ValueChanged<String?> onPhotoChanged;

  const PhotoUploadWidget({
    super.key,
    this.currentBase64,
    required this.onPhotoChanged,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final _picker = ImagePicker();
  String? _localBase64; // base64 setelah dipilih (belum disimpan ke Firestore)
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _localBase64 = widget.currentBase64;
  }

  String? get _displayBase64 => _localBase64 ?? widget.currentBase64;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isProcessing ? null : _showPickerOptions,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE6F1FB),
              border: Border.all(
                color: const Color(0xFF378ADD),
                width: 2,
              ),
            ),
            child: _buildPhotoContent(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ketuk untuk ubah foto',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF6B7A8D),
              ),
        ),
      ],
    );
  }

  Widget _buildPhotoContent() {
    if (_isProcessing) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_displayBase64 != null && _displayBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(
          _displayBase64!.contains(',')
              ? _displayBase64!.split(',').last
              : _displayBase64!,
        );
        return ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 88,
            height: 88,
          ),
        );
      } catch (_) {
        // Fallback jika base64 tidak valid
      }
    }

    return const Icon(
      Icons.add_a_photo_outlined,
      color: Color(0xFF378ADD),
      size: 32,
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            if (_displayBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isProcessing = true);

    try {
      // Kompres foto maksimal 200KB sesuai PRD (batas dokumen Firestore 1MB)
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        quality: 70,
        minWidth: 400,
        minHeight: 400,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        _showError('Gagal memproses foto. Coba lagi.');
        return;
      }

      // Validasi ukuran setelah kompresi (max 200KB)
      const maxBytes = 200 * 1024;
      if (compressed.length > maxBytes) {
        _showError(
          'Foto terlalu besar setelah kompresi '
          '(${(compressed.length / 1024).toStringAsFixed(0)}KB). '
          'Maksimal 200KB. Coba foto dengan resolusi lebih kecil.',
        );
        return;
      }

      final base64Str =
          'data:image/jpeg;base64,${base64Encode(compressed)}';

      setState(() => _localBase64 = base64Str);
      widget.onPhotoChanged(base64Str);
    } catch (e) {
      _showError('Error memproses foto: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _removePhoto() {
    setState(() => _localBase64 = null);
    widget.onPhotoChanged(null);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }
}
