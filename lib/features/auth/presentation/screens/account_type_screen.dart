import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profileforge/core/di/firebase_providers.dart';

/// One-time setup: choose portfolio owner or company/hirer.
class AccountTypeScreen extends ConsumerStatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  ConsumerState<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends ConsumerState<AccountTypeScreen> {
  bool _loading = false;
  String? _selected;
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(accountTypeServiceProvider).setAccountType(
            accountType: _selected!,
            companyName: _selected == 'hirer' ? _companyController.text.trim() : null,
          );
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Icon(Icons.workspace_premium, size: 64, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text('How will you use ProfileForge?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Choose your account type. You can change this later.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _OptionTile(
                icon: Icons.person,
                title: 'Portfolio owner',
                subtitle: 'Showcase your work and get discovered',
                selected: _selected == 'portfolio',
                onTap: () => setState(() => _selected = 'portfolio'),
              ),
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.business_center,
                title: 'Company / Hirer',
                subtitle: 'Find and hire talent',
                selected: _selected == 'hirer',
                onTap: () => setState(() => _selected = 'hirer'),
              ),
              if (_selected == 'hirer') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company name (optional)', hintText: 'Acme Inc'),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
              const Spacer(flex: 1),
              FilledButton(
                onPressed: (_selected == null || _loading) ? null : _save,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.5) : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 28, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
