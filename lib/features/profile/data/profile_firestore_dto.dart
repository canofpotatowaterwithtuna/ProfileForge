import '../../profile/domain/models/profile_model.dart';

/// Serialization for Firestore. Maps [UserProfile] to/from Map.
class ProfileFirestoreDto {
  static Map<String, dynamic> toMap(UserProfile p) {
    return {
      'fullName': p.fullName,
      'headline': p.headline,
      'bio': p.bio,
      'email': p.email,
      'skills': p.skills.map((s) => {'id': s.id, 'name': s.name}).toList(),
      'links': p.links
          .map((l) => {'id': l.id, 'title': l.title, 'url': l.url})
          .toList(),
      'experience': p.experience
          .map(
            (e) => {
              'id': e.id,
              'role': e.role,
              'company': e.company,
              'period': e.period,
              'description': e.description,
            },
          )
          .toList(),
      'searchText': _searchText(p),
    };
  }

  static String _searchText(UserProfile p) {
    final parts = [
      p.fullName,
      p.headline,
      p.bio,
      p.skills.map((s) => s.name).join(' '),
      p.experience
          .map((e) => '${e.role} ${e.company} ${e.description}')
          .join(' '),
    ];
    return parts.join(' ').toLowerCase();
  }

  static UserProfile fromMap(Map<String, dynamic> m) {
    return UserProfile(
      fullName: (m['fullName'] as String?) ?? '',
      headline: (m['headline'] as String?) ?? '',
      bio: (m['bio'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      skills: _skillsFromList(m['skills']),
      links: _linksFromList(m['links']),
      experience: _experienceFromList(m['experience']),
    );
  }

  static List<Skill> _skillsFromList(dynamic list) {
    if (list is! List) return [];
    return list.map((e) {
      if (e is! Map) return const Skill(id: '', name: '');
      return Skill(
        id: (e['id'] as String?) ?? '',
        name: (e['name'] as String?) ?? '',
      );
    }).toList();
  }

  static List<ProfileLink> _linksFromList(dynamic list) {
    if (list is! List) return [];
    return list.map((e) {
      if (e is! Map) return const ProfileLink(id: '', title: '', url: '');
      return ProfileLink(
        id: (e['id'] as String?) ?? '',
        title: (e['title'] as String?) ?? '',
        url: (e['url'] as String?) ?? '',
      );
    }).toList();
  }

  static List<Experience> _experienceFromList(dynamic list) {
    if (list is! List) return [];
    return list.map((e) {
      if (e is! Map) return const Experience(id: '');
      return Experience(
        id: (e['id'] as String?) ?? '',
        role: (e['role'] as String?) ?? '',
        company: (e['company'] as String?) ?? '',
        period: (e['period'] as String?) ?? '',
        description: (e['description'] as String?) ?? '',
      );
    }).toList();
  }
}
