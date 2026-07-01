import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/core/constants/role_navigation.dart';
import 'package:budiutama_basketball/core/utils/device_id_helper.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: isWide
                      ? Row(
                          children: [
                            const Expanded(child: _LoginBrandPanel()),
                            const SizedBox(width: 32),
                            SizedBox(
                              width: 420,
                              child: _LoginFormCard(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                emailFocusNode: _emailFocusNode,
                                passwordFocusNode: _passwordFocusNode,
                                isLoading: _isLoading,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: _togglePasswordVisibility,
                                onSubmit: _handleLogin,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _LoginBrandPanel(compact: true),
                            const SizedBox(height: 24),
                            _LoginFormCard(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              emailFocusNode: _emailFocusNode,
                              passwordFocusNode: _passwordFocusNode,
                              isLoading: _isLoading,
                              obscurePassword: _obscurePassword,
                              onTogglePassword: _togglePasswordVisibility,
                              onSubmit: _handleLogin,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Blokir router agar tidak redirect ke dashboard selama pengecekan
    // trusted-device / pengiriman OTP berlangsung secara async. Tanpa ini,
    // auth state change dari signIn() akan memicu router sebelum
    // pendingOtpProvider sempat di-set (race condition).
    ref.read(isOtpCheckPendingProvider.notifier).state = true;

    try {
      final repository = ref.read(authRepositoryProvider);
      final credential = await repository.signIn(
        _emailController.text,
        _passwordController.text,
      );
      final role = await repository.getRole();
      final userId = await repository.getCurrentUserDocumentId();
      final deviceHash = _getDeviceId();

      if ((role == 'coach' || role == 'manager') && userId != null) {
        final trusted = await repository.isDeviceTrusted(userId, deviceHash);
        if (!trusted) {
          await repository.sendVerificationCode(userId);
          ref.read(pendingOtpProvider.notifier).state = PendingOtp(
            email: credential.user?.email ?? _emailController.text.trim(),
            userId: userId,
            deviceHash: deviceHash,
          );
          // Lepas blokir SETELAH pendingOtp di-set agar router redirect ke /otp
          ref.read(isOtpCheckPendingProvider.notifier).state = false;
          if (mounted) {
            context.go(
              '/otp',
              extra: {
                'email': credential.user?.email ?? _emailController.text.trim(),
                'userId': userId,
                'deviceHash': deviceHash,
              },
            );
          }
          return;
        }
      }

      ref.read(pendingOtpProvider.notifier).state = null;
      ref.read(isOtpCheckPendingProvider.notifier).state = false;
      if (mounted) context.go(RoleNavigation.defaultPath(role));
    } on AuthException catch (error) {
      // Sign out untuk rollback jika login berhasil tapi langkah selanjutnya
      // gagal (mis. gagal kirim OTP) — user harus login ulang.
      await ref.read(authRepositoryProvider).signOut();
      ref.read(isOtpCheckPendingProvider.notifier).state = false;
      _showGenericError(error.message);
    } catch (_) {
      await ref.read(authRepositoryProvider).signOut();
      ref.read(isOtpCheckPendingProvider.notifier).state = false;
      _showGenericError('Login gagal. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Kembalikan device ID yang stabil dan persisten.
  /// Di Flutter Web, ID disimpan di localStorage sehingga tetap sama
  /// lintas sesi browser. Di platform lain, ID baru di-generate tiap sesi
  /// (tanpa shared_preferences). Format: 'device_{32 hex chars}'.
  String _getDeviceId() {
    var id = getPersistedDeviceId();
    if (id.isEmpty) {
      final rng = math.Random.secure();
      id = List.generate(16, (_) => rng.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      persistDeviceId(id);
    }
    return 'device_$id';
  }

  void _showGenericError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  final bool compact;

  const _LoginBrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 72 : 84,
          height: compact ? 72 : 84,
          decoration: BoxDecoration(
            color: AppColors.orangeSoft.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Icon(
            Icons.sports_basketball,
            size: 42,
            color: AppColors.orange,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Budi Utama Basketball',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 28 : 42,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sports academy management system untuk admin, pelatih, atlet, dan manajer tim.',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: compact ? 13 : 16,
            height: 1.5,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 28),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _LoginPill(label: 'Training'),
              _LoginPill(label: 'Matches'),
              _LoginPill(label: 'Statistics'),
              _LoginPill(label: 'Athlete Data'),
            ],
          ),
        ],
      ],
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _LoginFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isLoading,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masuk',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gunakan akun terdaftar untuk melanjutkan.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('email_field'),
                controller: emailController,
                focusNode: emailFocusNode,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  final isValid =
                      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
                  return isValid ? null : 'Email tidak valid';
                },
                onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('password_field'),
                controller: passwordController,
                focusNode: passwordFocusNode,
                enabled: !isLoading,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: isLoading ? null : onTogglePassword,
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) >= 8
                    ? null
                    : 'Password minimal 8 karakter',
                onFieldSubmitted: (_) {
                  if (!isLoading) onSubmit();
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Masuk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPill extends StatelessWidget {
  final String label;

  const _LoginPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
