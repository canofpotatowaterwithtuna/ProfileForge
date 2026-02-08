import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../profile/domain/models/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/profile_pdf_builder.dart';

/// L5: PDF export with Modern/Classic themes and Share.
class ForgeScreen extends ConsumerStatefulWidget {
  const ForgeScreen({super.key});

  @override
  ConsumerState<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends ConsumerState<ForgeScreen> {
  PdfTheme _theme = PdfTheme.modern;
  bool _exporting = false;

  Future<void> _exportAndShare() async {
    final profileAsync = ref.read(profileProvider);
    final profile = profileAsync.value;
    if (profile == null) return;
    setState(() => _exporting = true);
    try {
      final pdf = await ProfilePdfBuilder.build(profile, _theme);
      final path = await ProfilePdfBuilder.saveToTempFile(pdf);
      await Share.shareXFiles(
        [XFile(path)],
        text:
            'Portfolio — ${profile.fullName.isEmpty ? 'ProfileForge' : profile.fullName}',
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final hasProfile = profileAsync.value != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Forge')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.picture_as_pdf, size: 56),
          const SizedBox(height: 16),
          Text('Export as PDF', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Choose a theme and share your portfolio as a PDF.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<PdfTheme>(
            segments: const [
              ButtonSegment(
                value: PdfTheme.modern,
                label: Text('Modern'),
                icon: Icon(Icons.auto_awesome),
              ),
              ButtonSegment(
                value: PdfTheme.classic,
                label: Text('Classic'),
                icon: Icon(Icons.description),
              ),
            ],
            selected: {_theme},
            onSelectionChanged: (s) => setState(() => _theme = s.first),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: (_exporting || !hasProfile) ? null : _exportAndShare,
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            label: Text(_exporting ? 'Exporting…' : 'Export & Share PDF'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (!hasProfile) const SizedBox(height: 8),
          if (!hasProfile)
            Text(
              'Load your profile first from the home screen.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
