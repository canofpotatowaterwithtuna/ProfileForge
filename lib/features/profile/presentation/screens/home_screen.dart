import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/firebase_providers.dart';
import '../../../../core_ui/atoms/link_favicon.dart';
import '../../../../core_ui/atoms/profile_strength_meter.dart';
import '../../../../core_ui/atoms/shimmer_loading.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/portfolio_export.dart';
import '../../domain/profile_strength.dart';
import '../providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    void openEdit(UserProfile profile) =>
        context.push<void>('/edit', extra: profile);

    void shareProfile(UserProfile profile) {
      final text = portfolioToShareableText(profile);
      if (text.trim().isNotEmpty)
        Share.share(
          text,
          subject: profile.fullName.isEmpty ? 'Portfolio' : profile.fullName,
        );
    }

    return Scaffold(
      body: profileAsync.when(
        loading: () => Center(
          child: ShimmerLoading(
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        error: (err, _) => _ErrorView(message: err.toString()),
        data: (profile) => _PortfolioScaffold(
          profile: profile,
          isLoggedIn: isLoggedIn,
          ref: ref,
          onEdit: () => openEdit(profile),
          onShare: () => shareProfile(profile),
          onPublish: isLoggedIn
              ? () => _publish(
                  context,
                  ref,
                  profile,
                  ref.read(isPublishedProvider).value ?? false,
                )
              : null,
        ),
      ),
    );
  }
}

void _showActionsSheet(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onEdit,
  required VoidCallback onShare,
  required VoidCallback? onPublish,
  required bool isLoggedIn,
  required bool isEmpty,
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Consumer(
        builder: (ctx, ref, _) {
          final isPublished = ref.watch(isPublishedProvider).value ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        ctx,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompactAction(
                      icon: Icons.explore_outlined,
                      label: 'Explore',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/explore');
                      },
                    ),
                    _CompactAction(
                      icon: Icons.search,
                      label: 'Discover',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/discover');
                      },
                    ),
                    _CompactAction(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: !isEmpty
                          ? () {
                              Navigator.pop(ctx);
                              onShare();
                            }
                          : null,
                    ),
                    _CompactAction(
                      icon: Icons.cloud_upload_outlined,
                      label: isPublished ? 'Update' : 'Publish',
                      onTap: onPublish != null
                          ? () {
                              Navigator.pop(ctx);
                              onPublish();
                            }
                          : null,
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  leading: Icon(
                    Icons.handshake_outlined,
                    size: 22,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  title: const Text('Hire requests'),
                  dense: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/hire-requests');
                  },
                ),
                ListTile(
                  leading: Icon(
                    isLoggedIn ? Icons.logout : Icons.login,
                    size: 22,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  title: Text(isLoggedIn ? 'Sign out' : 'Sign in'),
                  dense: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    isLoggedIn ? _signOut(context) : context.push('/auth');
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: onTap != null
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: onTap != null
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) context.go('/auth');
}

Future<void> _publish(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile,
  bool wasAlreadyPublished,
) async {
  try {
    await ref.read(portfolioFirestoreProvider).publish(profile);
    ref.invalidate(isPublishedProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasAlreadyPublished
                ? 'Portfolio updated'
                : 'Portfolio published online',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _PortfolioScaffold extends StatelessWidget {
  const _PortfolioScaffold({
    required this.profile,
    required this.isLoggedIn,
    required this.ref,
    required this.onEdit,
    required this.onShare,
    this.onPublish,
  });

  final UserProfile profile;
  final bool isLoggedIn;
  final WidgetRef ref;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback? onPublish;

  bool get _isEmpty =>
      profile.fullName.isEmpty &&
      profile.headline.isEmpty &&
      profile.bio.isEmpty &&
      profile.email.isEmpty &&
      profile.skills.isEmpty &&
      profile.links.isEmpty &&
      profile.experience.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileForge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => _showActionsSheet(
              context,
              ref,
              onEdit: onEdit,
              onShare: onShare,
              onPublish: onPublish,
              isLoggedIn: isLoggedIn,
              isEmpty: _isEmpty,
            ),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: _isEmpty
          ? _EmptyState(onEdit: onEdit, isLoggedIn: isLoggedIn)
          : _PortfolioBody(profile: profile, onEdit: onEdit, onShare: onShare),
      floatingActionButton: _isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              tooltip: 'Edit portfolio',
            ),
    );
  }
}

class _PortfolioBody extends StatelessWidget {
  const _PortfolioBody({
    required this.profile,
    required this.onEdit,
    required this.onShare,
  });

  final UserProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(
            fullName: profile.fullName,
            headline: profile.headline,
            isDark: isDark,
            strength: profileStrength(profile),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (profile.bio.isNotEmpty || profile.email.isNotEmpty) ...[
                _CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.bio.isNotEmpty)
                        Text(
                          profile.bio,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.5,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      if (profile.bio.isNotEmpty && profile.email.isNotEmpty)
                        const SizedBox(height: 16),
                      if (profile.email.isNotEmpty)
                        _EmailChip(email: profile.email),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.skills.isNotEmpty) ...[
                _SectionTitle(title: 'Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: profile.skills
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: isDark ? 0.4 : 0.6,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (profile.experience.isNotEmpty) ...[
                _SectionTitle(title: 'Experience'),
                const SizedBox(height: 10),
                ...profile.experience.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.role,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (e.company.isNotEmpty)
                            Text(
                              e.company,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          if (e.period.isNotEmpty)
                            Text(
                              e.period,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          if (e.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              e.description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (profile.links.isNotEmpty) ...[
                _SectionTitle(title: 'Links'),
                const SizedBox(height: 10),
                ...profile.links.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LinkTile(link: l),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.fullName,
    required this.headline,
    required this.isDark,
    this.strength = 0,
  });

  final String fullName;
  final String headline;
  final bool isDark;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF4338CA), const Color(0xFF7C3AED)]
              : [const Color(0xFF6366F1), const Color(0xFFA855F7)],
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  fullName.isEmpty
                      ? '?'
                      : fullName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            fullName.isEmpty ? 'Your name' : fullName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (headline.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              headline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (strength > 0) ...[
            const SizedBox(height: 16),
            ProfileStrengthMeter(
              strength: strength,
              size: 44,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({required this.email});

  final String email;

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMail(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              email,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.link});

  final ProfileLink link;

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) return;
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openUrl(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: LinkFavicon(
                    url: link.url,
                    size: 28,
                    fallbackColor: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title.isEmpty ? link.url : link.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (link.title.isNotEmpty && link.url != link.title)
                      Text(
                        link.url,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onEdit, required this.isLoggedIn});

  final VoidCallback onEdit;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF4338CA), const Color(0xFF1E1B4B)]
              : [const Color(0xFF6366F1), const Color(0xFFE0E7FF)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Create your portfolio',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add your name, headline, skills, and experience—then publish to get discovered.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FilledButton.tonal(
                  onPressed: onEdit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                  ),
                  child: const Text('Get started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
