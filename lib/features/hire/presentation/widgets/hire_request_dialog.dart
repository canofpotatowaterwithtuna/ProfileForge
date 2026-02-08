import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/firebase_providers.dart';
import '../../data/hire_service.dart';

/// Dialog to send a hire request.
class HireRequestDialog extends ConsumerStatefulWidget {
  const HireRequestDialog({
    super.key,
    required this.toUserId,
    required this.recipientEmail,
    required this.recipientName,
  });

  final String toUserId;
  final String recipientEmail;
  final String recipientName;

  static Future<void> show(
    BuildContext context, {
    required String toUserId,
    required String recipientEmail,
    required String recipientName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => HireRequestDialog(
        toUserId: toUserId,
        recipientEmail: recipientEmail,
        recipientName: recipientName,
      ),
    );
  }

  @override
  ConsumerState<HireRequestDialog> createState() => _HireRequestDialogState();
}

class _HireRequestDialogState extends ConsumerState<HireRequestDialog> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _messageController = TextEditingController();
  final _contactEmailController = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _messageController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    final company = _companyController.text.trim();
    final message = _messageController.text.trim();
    final contactEmail = _contactEmailController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Your name is required');
      return;
    }
    if (contactEmail.isEmpty) {
      setState(() => _error = 'Contact email is required');
      return;
    }
    if (message.isEmpty) {
      setState(() => _error = 'Please add a message');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await ref
          .read(hireServiceProvider)
          .sendHireRequest(
            toUserId: widget.toUserId,
            recipientEmail: widget.recipientEmail,
            fromName: name,
            fromCompany: company,
            message: message,
            contactEmail: contactEmail,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hire request sent! They\'ll see it in Hire requests.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to send: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.handshake,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send hire request',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.recipientName} will see your request in their Hire requests.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name *',
                    hintText: 'John Smith',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company (optional)',
                    hintText: 'Acme Inc',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact email *',
                    hintText: 'you@company.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    hintText: 'We\'d like to discuss a role...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
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
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _sending ? null : _send,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _sending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send hire request'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
