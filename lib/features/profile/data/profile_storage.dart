import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/profile_model.dart';

const _keyProfile = 'profileforge_profile_v1';

class ProfileStorage {
  ProfileStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<ProfileStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileStorage(prefs);
  }

  UserProfile load() {
    final json = _prefs.getString(_keyProfile);
    if (json == null) return const UserProfile();
    try {
      return _profileFromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(_profileToJson(profile)));
  }

  static Map<String, dynamic> _profileToJson(UserProfile p) {
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
    };
  }

  static UserProfile _profileFromJson(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] as String? ?? '',
      headline: map['headline'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      email: map['email'] as String? ?? '',
      skills:
          (map['skills'] as List<dynamic>?)
              ?.map(
                (e) => Skill(id: e['id'] as String, name: e['name'] as String),
              )
              .toList() ??
          const [],
      links:
          (map['links'] as List<dynamic>?)
              ?.map(
                (e) => ProfileLink(
                  id: e['id'] as String,
                  title: e['title'] as String,
                  url: e['url'] as String,
                ),
              )
              .toList() ??
          const [],
      experience:
          (map['experience'] as List<dynamic>?)
              ?.map(
                (e) => Experience(
                  id: e['id'] as String,
                  role: e['role'] as String? ?? '',
                  company: e['company'] as String? ?? '',
                  period: e['period'] as String? ?? '',
                  description: e['description'] as String? ?? '',
                ),
              )
              .toList() ??
          const [],
    );
  }
}
