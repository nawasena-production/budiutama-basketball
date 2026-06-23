import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget untuk upload dan preview foto pemain.
///
/// Implementasi Free Plan: foto dikompres maksimal 200KB lalu disimpan
/// sebagai base64 string di field `photo_base64` dokumen Firestore.
class PhotoUploadWidget extends StatefulWidget {
  final String? currentBase64;
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
  String? _localBase64;
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
        final raw = _displayBase64!;
        final base64Str = raw.contains(',') ? raw.split(',').last : raw;
        // Validate base64 before decoding
        final bytes = base64Decode(base64Str);
        if (bytes.isNotEmpty) {
          return ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: 88,
              height: 88,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.add_a_photo_outlined,
                color: Color(0xFF378ADD),
                size: 32,
              ),
            ),
          );
        }
      } catch (_) {
        // Fallback ke icon jika base64 tidak valid
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
                _pickPhoto(ImageSource.camera); // Fix #3: use camera source
              },
            ),
            if (_displayBase64 != null && _displayBase64!.isNotEmpty)
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
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (picked == null) return;

      setState(() => _isProcessing = true);

      // Read file bytes
      final bytes = await picked.readAsBytes();

      // Check size (max 200KB)
      const maxBytes = 200 * 1024;
      if (bytes.length > maxBytes) {
        if (mounted) {
          _showError(
            'Foto terlalu besar (${(bytes.length / 1024).toStringAsFixed(0)}KB). '
            'Gunakan foto dengan ukuran lebih kecil atau kualitas lebih rendah.',
          );
        }
        return;
      }

      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      if (mounted) {
        setState(() => _localBase64 = base64Str);
        widget.onPhotoChanged(base64Str);
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memproses foto. Pastikan izin kamera/galeri diberikan.');
      }
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