import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:budiutama_basketball/core/constants/role_navigation.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String userId;
  final String deviceHash;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.userId,
    required this.deviceHash,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _cooldown = 60;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingOtpProvider);
    final email = widget.email.isNotEmpty ? widget.email : pending?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A3A5C),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: Color(0xFFE8420A),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verifikasi Device',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _codeController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _verify,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verifikasi'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: (_cooldown == 0 && !_isResending && !_isLoading)
                        ? _resend
                        : null,
                    child: Text(
                      _isResending
                          ? 'Mengirim...'
                          : _cooldown == 0
                              ? 'Kirim ulang kode'
                              : 'Kirim ulang dalam $_cooldown detik',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final pending = ref.read(pendingOtpProvider);
    final userId = widget.userId.isNotEmpty ? widget.userId : pending?.userId;
    final deviceHash =
        widget.deviceHash.isNotEmpty ? widget.deviceHash : pending?.deviceHash;
    final code = _codeController.text.trim();

    if (userId == null || deviceHash == null || code.length != 6) {
      _showMessage('Masukkan 6 digit kode verifikasi.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Validasi kode di server — Cloud Function verifyDeviceCode memeriksa
      // kode, expiry, lalu menambahkan deviceHash ke trusted_device_ids (C1).
      await ref.read(authRepositoryProvider).verifyAndTrustDevice(
            userId,
            code,
            deviceHash,
          );
      ref.read(pendingOtpProvider.notifier).state = null;
      final role = await ref.read(authRepositoryProvider).getRole();
      if (mounted) context.go(RoleNavigation.defaultPath(role));
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Verifikasi gagal. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    final pending = ref.read(pendingOtpProvider);
    final userId = widget.userId.isNotEmpty ? widget.userId : pending?.userId;
    if (userId == null) return;

    setState(() => _isResending = true);
    try {
      // Kirim ulang kode via Cloud Function — kode baru di-generate
      // server-side dan dikirim ke email user (C2).
      await ref.read(authRepositoryProvider).sendVerificationCode(userId);
      _showMessage('Kode verifikasi baru telah dikirim ke email Anda.');
      _startCooldown();
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Gagal mengirim kode. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else if (mounted) {
        setState(() => _cooldown--);
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
