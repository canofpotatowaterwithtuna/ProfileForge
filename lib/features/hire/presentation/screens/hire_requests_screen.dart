import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/hire_service.dart';

/// Shows hire requests received by the current user.
class HireRequestsScreen extends ConsumerWidget {
  const HireRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hire requests')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text('Sign in to view hire requests', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => context.push('/auth'), child: const Text('Sign in')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hire requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('hireRequests').where('toUserId', isEqualTo: uid).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = (snap.data?.docs ?? [])..sort((a, b) {
              final aT = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              final bT = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              return bT.compareTo(aT);
            });
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 24),
                  Text('No hire requests yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Companies will see your portfolio and contact you here.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final m = d.data();
              final fromName = m['fromName'] as String? ?? 'Someone';
              final fromCompany = m['fromCompany'] as String? ?? '';
              final message = m['message'] as String? ?? '';
              final contactEmail = m['contactEmail'] as String? ?? '';
              final createdAt = (m['createdAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(fromName.isEmpty ? '?' : fromName[0].toUpperCase()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fromName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                if (fromCompany.isNotEmpty) Text(fromCompany, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                              ],
                            ),
                          ),
                          if (createdAt != null) Text(_formatDate(createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
                      ],
                      if (contactEmail.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () => _launchEmail(contactEmail, fromName),
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: Text('Reply to $contactEmail'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Future<void> _launchEmail(String email, String subject) async {
    final uri = Uri.parse('mailto:$email?subject=Re: Hire request from $subject');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}