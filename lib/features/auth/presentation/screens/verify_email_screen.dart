import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Shown after signup (or when signed in with unverified email).
/// User must click the verification link sent to their email.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _loading = false;
  bool _resendSent = false;
  String? _error;
  DateTime? _resendCooldownUntil;
  Timer? _cooldownTimer;

  static const _resendCooldownSeconds = 60;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldownUntil = DateTime.now().add(
      const Duration(seconds: _resendCooldownSeconds),
    );
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _resendCooldownUntil!
          .difference(DateTime.now())
          .inSeconds;
      if (remaining <= 0) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        setState(() => _resendCooldownUntil = null);
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _checkVerified() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final verified = await ref.read(authServiceProvider).reloadUser();
      if (!mounted) return;
      if (verified) {
        context.go('/discover');
      } else {
        setState(
          () => _error =
              'Email not verified yet. Check your inbox and click the link.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _loading = true;
      _error = null;
      _resendSent = false;
    });
    try {
      await ref.read(authServiceProvider).sendVerificationEmail();
      if (!mounted) return;
      setState(() {
        _resendSent = true;
        _loading = false;
      });
      _startResendCooldown();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Failed to resend';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to resend verification email';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify your email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a verification link to $email. Click the link in the email to verify your account.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_resendSent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verification email sent. Check your inbox.',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _loading ? null : _checkVerified,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("I've verified my email"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: (_loading || _resendCooldownUntil != null)
                        ? null
                        : _resendEmail,
                    child: _resendCooldownUntil != null
                        ? Text(
                            'Resend in ${_resendCooldownUntil!.difference(DateTime.now()).inSeconds}s',
                          )
                        : const Text('Resend verification email'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            await ref.read(authServiceProvider).signOut();
                            if (!context.mounted) return;
                            context.go('/auth');
                          },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
