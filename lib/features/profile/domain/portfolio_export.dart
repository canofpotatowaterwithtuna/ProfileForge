import 'models/profile_model.dart';

String portfolioToShareableText(UserProfile p) {
  final buffer = StringBuffer();
  if (p.fullName.isNotEmpty) buffer.writeln(p.fullName);
  if (p.headline.isNotEmpty) buffer.writeln(p.headline);
  if (p.bio.isNotEmpty) buffer.writeln('\n${p.bio}');
  if (p.email.isNotEmpty) buffer.writeln('\nContact: ${p.email}');
  if (p.skills.isNotEmpty) {
    buffer.writeln('\nSkills: ${p.skills.map((s) => s.name).join(', ')}');
  }
  if (p.experience.isNotEmpty) {
    buffer.writeln('\nExperience');
    for (final e in p.experience) {
      buffer.writeln(
        '• ${e.role}${e.company.isNotEmpty ? ' at ${e.company}' : ''}${e.period.isNotEmpty ? ' · ${e.period}' : ''}',
      );
      if (e.description.isNotEmpty) buffer.writeln('  ${e.description}');
    }
  }
  if (p.links.isNotEmpty) {
    buffer.writeln('\nLinks');
    for (final l in p.links) {
      buffer.writeln('• ${l.title.isEmpty ? l.url : '${l.title}: ${l.url}'}');
    }
  }
  buffer.writeln('\n— ProfileForge');
  return buffer.toString().trim();
}
