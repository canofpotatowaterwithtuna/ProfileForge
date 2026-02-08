import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/profile_model.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late List<Skill> _skills;
  late List<ProfileLink> _links;
  late List<Experience> _experience;
  var _saving = false;

  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _bioController = TextEditingController(text: widget.profile.bio);
    _emailController = TextEditingController(text: widget.profile.email);
    _skills = List.from(widget.profile.skills);
    _links = List.from(widget.profile.links);
    _experience = List.from(widget.profile.experience);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addSkill() {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add skill'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Flutter, UI Design',
            ),
            onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty)
        setState(
          () => _skills = [..._skills, Skill(id: _uuid.v4(), name: value)],
        );
    });
  }

  void _removeSkill(Skill skill) =>
      setState(() => _skills = _skills.where((s) => s.id != skill.id).toList());

  void _addLink() {
    showDialog<ProfileLink?>(
      context: context,
      builder: (ctx) {
        final titleController = TextEditingController();
        final urlController = TextEditingController();
        return AlertDialog(
          title: const Text('Add link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g. GitHub',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://...',
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                var url = urlController.text.trim();
                if (url.isNotEmpty) {
                  if (!url.contains(RegExp(r'^https?://')))
                    url = 'https://$url';
                  Navigator.pop(
                    ctx,
                    ProfileLink(
                      id: _uuid.v4(),
                      title: titleController.text.trim(),
                      url: url,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) setState(() => _links = [..._links, value]);
    });
  }

  void _removeLink(ProfileLink link) =>
      setState(() => _links = _links.where((l) => l.id != link.id).toList());

  void _addExperience() {
    showDialog<Experience?>(
      context: context,
      builder: (ctx) {
        final role = TextEditingController();
        final company = TextEditingController();
        final period = TextEditingController();
        final desc = TextEditingController();
        return AlertDialog(
          title: const Text('Add experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    hintText: 'e.g. Software Engineer',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: company,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'e.g. Acme Inc',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: period,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    hintText: 'e.g. 2020 – Present',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                Experience(
                  id: _uuid.v4(),
                  role: role.text.trim(),
                  company: company.text.trim(),
                  period: period.text.trim(),
                  description: desc.text.trim(),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) setState(() => _experience = [..._experience, value]);
    });
  }

  void _removeExperience(Experience e) => setState(
    () => _experience = _experience.where((x) => x.id != e.id).toList(),
  );

  Future<void> _save() async {
    if (_saving) return;
    final profile = widget.profile.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? 'Your name'
          : _nameController.text.trim(),
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? 'Tell people about yourself.'
          : _bioController.text.trim(),
      email: _emailController.text.trim(),
      skills: _skills,
      links: _links,
      experience: _experience,
    );
    setState(() => _saving = true);
    try {
      final ok = await ref
          .read(profileProvider.notifier)
          .updateFullProfile(profile);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portfolio saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reorderSkills(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _skills.removeAt(oldIndex);
      _skills.insert(newIndex, item);
    });
  }

  void _reorderExperience(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _experience.removeAt(oldIndex);
      _experience.insert(newIndex, item);
    });
  }

  TextStyle? _sectionLabel(BuildContext context) => Theme.of(context)
      .textTheme
      .titleSmall
      ?.copyWith(color: Theme.of(context).colorScheme.primary);

  Widget _sectionHeader(String title, {required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: _sectionLabel(context)),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _hint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit portfolio'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Name', style: _sectionLabel(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Your full name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          Text('Headline', style: _sectionLabel(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _headlineController,
            decoration: const InputDecoration(
              hintText: 'e.g. Flutter Developer · Building apps',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          Text('Bio', style: _sectionLabel(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Short bio or tagline',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Text('Email', style: _sectionLabel(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: 'you@example.com'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _sectionHeader('Skills', onAdd: _addSkill),
          const SizedBox(height: 8),
          _skills.isEmpty
              ? _hint(context, 'Tap Add to add skills.')
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: true,
                  itemCount: _skills.length,
                  onReorder: _reorderSkills,
                  itemBuilder: (context, index) {
                    final s = _skills[index];
                    return ListTile(
                      key: ValueKey(s.id),
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      title: Text(s.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeSkill(s),
                        tooltip: 'Remove',
                      ),
                    );
                  },
                ),
          const SizedBox(height: 24),
          _sectionHeader('Experience', onAdd: _addExperience),
          const SizedBox(height: 8),
          if (_experience.isEmpty)
            _hint(context, 'Add roles and companies.')
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: true,
              onReorder: _reorderExperience,
              itemCount: _experience.length,
              itemBuilder: (context, index) {
                final e = _experience[index];
                return ListTile(
                  key: ValueKey(e.id),
                  title: Text(
                    '${e.role}${e.company.isNotEmpty ? ' at ${e.company}' : ''}',
                  ),
                  subtitle: Text(
                    [
                      if (e.period.isNotEmpty) e.period,
                      if (e.description.isNotEmpty) e.description,
                    ].join(' · '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeExperience(e),
                    tooltip: 'Remove',
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          _sectionHeader('Links', onAdd: _addLink),
          const SizedBox(height: 8),
          if (_links.isEmpty)
            _hint(context, 'Add GitHub, website, or social profiles.')
          else
            ..._links.map(
              (l) => ListTile(
                title: Text(l.title.isEmpty ? l.url : l.title),
                subtitle: l.title.isNotEmpty
                    ? Text(l.url, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeLink(l),
                  tooltip: 'Remove',
                ),
              ),
            ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save portfolio'),
          ),
        ],
      ),
    );
  }
}
