import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/firebase_providers.dart';
import '../../../profile/data/portfolio_firestore_service.dart';
import '../../../profile/data/profile_firestore_dto.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../../core_ui/atoms/ai_search_loader.dart';
import '../../../../core_ui/atoms/pastel_rainbow_input.dart';
import '../../../../core_ui/atoms/shimmer_loading.dart';

/// Discover candidates: primary keyword/name search + secondary AI-powered search.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _queryController = TextEditingController();
  bool _keywordLoading = false;
  bool _aiLoading = false;
  List<PublicPortfolio> _allPortfolios = [];
  List<PublicPortfolio> _results = [];
  String? _error;
  bool _usedAiSearch = false;
  bool _aiMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPortfolios());
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<PublicPortfolio> _keywordSearch(
    List<PublicPortfolio> list,
    String query,
  ) {
    final q = query.trim();
    if (q.isEmpty) return list;
    final lowerQuery = q.toLowerCase();
    final searchableFor = (PublicPortfolio p) =>
        '${p.profile.fullName} ${p.profile.headline} ${p.profile.bio} '
                '${p.profile.skills.map((Skill s) => s.name).join(' ')} '
                '${p.profile.experience.map((Experience e) => '${e.role} ${e.company} ${e.description}').join(' ')}'
            .toLowerCase();

    final matches = <PublicPortfolio>[];
    for (final p in list) {
      final searchable = searchableFor(p);
      if (searchable.contains(lowerQuery)) {
        matches.add(p);
      } else {
        final words = lowerQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        final score = words.where((w) => searchable.contains(w)).length;
        if (score > 0) matches.add(p);
      }
    }
    matches.sort((a, b) {
      final aName = a.profile.fullName.toLowerCase();
      final bName = b.profile.fullName.toLowerCase();
      if (aName.startsWith(lowerQuery) && !bName.startsWith(lowerQuery)) return -1;
      if (!aName.startsWith(lowerQuery) && bName.startsWith(lowerQuery)) return 1;
      final aText = '${a.profile.fullName} ${a.profile.headline}'.toLowerCase();
      final bText = '${b.profile.fullName} ${b.profile.headline}'.toLowerCase();
      final words = lowerQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final aScore = words.where((w) => aText.contains(w)).length;
      final bScore = words.where((w) => bText.contains(w)).length;
      return bScore.compareTo(aScore);
    });
    return matches;
  }

  void _showDiscoverMenu(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text('Menu', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.explore_outlined, size: 22, color: Theme.of(ctx).colorScheme.onPrimaryContainer)),
                title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Browse portfolios', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                onTap: () { Navigator.pop(ctx); context.push('/explore'); },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)), child: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 22, color: Theme.of(ctx).colorScheme.onPrimaryContainer)),
                title: Text(isLoggedIn ? 'Sign out' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(isLoggedIn ? 'Sign out of your account' : 'Sign in to send hire requests', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                onTap: () { Navigator.pop(ctx); if (isLoggedIn) { FirebaseAuth.instance.signOut(); context.go('/auth'); } else { context.push('/auth'); } },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadPortfolios() async {
    if (_allPortfolios.isNotEmpty) return;
    setState(() => _keywordLoading = true);
    try {
      final portfolios = await FirebaseFirestore.instance
          .collection('portfolios')
          .where('published', isEqualTo: true)
          .get();
      final list = portfolios.docs.map((d) {
        final data = d.data();
        final profile = ProfileFirestoreDto.fromMap(data);
        return PublicPortfolio(userId: d.id, profile: profile);
      }).toList();
      if (!mounted) return;
      final keyword = _queryController.text.trim();
      setState(() {
        _allPortfolios = list;
        _keywordLoading = false;
        _results = keyword.isEmpty ? list : _keywordSearch(list, keyword);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load. Check Firebase.';
        _keywordLoading = false;
      });
    }
  }

  void _runKeywordSearch() {
    final query = _queryController.text.trim();
    setState(() {
      _error = null;
      _usedAiSearch = false;
      if (query.isEmpty) {
        _results = _allPortfolios;
      } else {
        _results = _keywordSearch(_allPortfolios, query);
      }
    });
  }

  Future<void> _runAiSearch() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Describe who you\'re looking for');
      return;
    }
    if (_allPortfolios.isEmpty) await _loadPortfolios();
    if (_allPortfolios.isEmpty) return;

    setState(() {
      _aiLoading = true;
      _error = null;
    });

    try {
      final aiService = ref.read(aiDiscoveryServiceProvider);
      final indices = await aiService.findMatchingIndices(
        portfolios: _allPortfolios,
        description: query,
        maxResults: 20,
      );
      if (!mounted) return;
      setState(() {
        _usedAiSearch = true;
        _aiLoading = false;
        _results = indices.isNotEmpty
            ? indices.map((i) => _allPortfolios[i]).toList()
            : [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'AI search failed. Try keyword search.';
        _aiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => _showDiscoverMenu(context),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Find the right people',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search by name or describe who you need',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (_aiMode) PastelRainbowInput(
                        controller: _queryController,
                        hintText: 'Describe your ideal candidate...',
                        prefixIcon: Icon(Icons.auto_awesome, size: 20, color: Theme.of(context).colorScheme.primary),
                        onSubmitted: (_) => _runAiSearch(),
                      ) else TextField(
                        controller: _queryController,
                        decoration: InputDecoration(
                          hintText: 'Name, skills, company...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                          filled: true,
                        ),
                        onSubmitted: (_) => _runKeywordSearch(),
                        onChanged: (_) => _runKeywordSearch(),
                      ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(
                      selected: !_aiMode,
                      label: const Text('Keyword'),
                      avatar: const Icon(Icons.search, size: 18, color: Colors.grey),
                      onSelected: (v) => setState(() {
                        _aiMode = false;
                        _runKeywordSearch();
                      }),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _aiMode,
                      label: _aiLoading ? const Text('Searching...') : const Text('AI'),
                      avatar: _aiLoading
                          ? SizedBox(width: 18, height: 18, child: AiSearchLoader(size: 18))
                          : Icon(Icons.auto_awesome, size: 18, color: _aiMode ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary),
                      onSelected: _aiLoading ? null : (v) => setState(() {
                        _aiMode = true;
                        if (_queryController.text.trim().isNotEmpty) _runAiSearch();
                      }),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                if (_usedAiSearch && _results.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('AI matched ${_results.length} candidates', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _keywordLoading && _allPortfolios.isEmpty
                ? Center(
                    child: ShimmerLoading(child: _buildShimmerCard(context)),
                  )
                : _aiLoading && _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AiSearchLoader(size: 80),
                        const SizedBox(height: 24),
                        Text(
                          'AI is finding matching candidates...',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Understanding your description',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _usedAiSearch ? 'No candidates found' : 'No results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _usedAiSearch
                              ? 'Try a different search or browse Explore'
                              : _queryController.text.trim().isEmpty
                                  ? 'No published portfolios yet. Browse Explore.'
                                  : 'No matches for "${_queryController.text.trim()}". Try different keywords',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final p = _results[i];
                      return _PortfolioTile(
                        profile: p.profile,
                        onTap: () => context.push('/profile/${p.userId}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.profile, required this.onTap});

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skills = profile.skills.take(3).map((s) => s.name).join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          child: Text(
            profile.fullName.isEmpty ? '?' : profile.fullName[0].toUpperCase(),
          ),
        ),
        title: Text(
          profile.fullName.isEmpty ? 'Anonymous' : profile.fullName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (profile.headline.isNotEmpty) profile.headline,
            if (skills.isNotEmpty) skills,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
