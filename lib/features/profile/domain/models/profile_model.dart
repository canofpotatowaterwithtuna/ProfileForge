import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  final String id;
  final String name;
  const Skill({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class ProfileLink extends Equatable {
  final String id;
  final String title;
  final String url;

  const ProfileLink({required this.id, required this.title, required this.url});

  @override
  List<Object?> get props => [id, title, url];
}

class Experience extends Equatable {
  final String id;
  final String role;
  final String company;
  final String period;
  final String description;

  const Experience({
    required this.id,
    this.role = '',
    this.company = '',
    this.period = '',
    this.description = '',
  });

  @override
  List<Object?> get props => [id, role, company, period, description];
}

class UserProfile extends Equatable {
  final String fullName;
  final String headline;
  final String bio;
  final String email;
  final List<Skill> skills;
  final List<ProfileLink> links;
  final List<Experience> experience;

  const UserProfile({
    this.fullName = '',
    this.headline = '',
    this.bio = '',
    this.email = '',
    this.skills = const [],
    this.links = const [],
    this.experience = const [],
  });

  UserProfile copyWith({
    String? fullName,
    String? headline,
    String? bio,
    String? email,
    List<Skill>? skills,
    List<ProfileLink>? links,
    List<Experience>? experience,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      links: links ?? this.links,
      experience: experience ?? this.experience,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    headline,
    bio,
    email,
    skills,
    links,
    experience,
  ];
}
