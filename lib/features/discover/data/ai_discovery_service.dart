import 'package:firebase_ai/firebase_ai.dart';
import '../../profile/data/portfolio_firestore_service.dart';

/// Uses Firebase AI Logic (Gemini) to match user descriptions to public portfolios.
/// No API key needed—Firebase manages authentication.
class AiDiscoveryService {
  AiDiscoveryService(this._model);

  final GenerativeModel _model;

  /// Creates a service using Firebase AI Logic (Gemini Developer API).
  static AiDiscoveryService create() {
    final model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
    return AiDiscoveryService(model);
  }

  /// Returns indices of [portfolios] that best match [description], sorted by relevance.
  Future<List<int>> findMatchingIndices({
    required List<PublicPortfolio> portfolios,
    required String description,
    int maxResults = 10,
  }) async {
    if (portfolios.isEmpty) return [];
    if (description.trim().isEmpty) {
      return List.generate(
        portfolios.length.clamp(0, maxResults),
        (i) => i,
      );
    }

    final summaries = portfolios.asMap().entries.map((e) {
      final p = e.value.profile;
      final skills = p.skills.map((s) => s.name).join(', ');
      final exp =
          p.experience.map((x) => '${x.role} at ${x.company}').join('; ');
      return '[${e.key}] ${p.fullName} | ${p.headline} | ${p.bio} | Skills: $skills | Experience: $exp';
    }).join('\n');

    const systemPrompt = '''
You are a strict portfolio matching assistant. Given a list of portfolios (each prefixed with [index]) and a user's description of who they're looking for, return ONLY the indices of portfolios that GENUINELY match the user's request. The match must be clear and relevant—e.g. "painting professional" must match artists/painters, NOT software developers or unrelated fields. Return at most 10 indices. If NO portfolio genuinely matches the description, return exactly "none". Do not guess or include loosely related profiles. Be strict about relevance.
''';

    final prompt = '''
$systemPrompt

Portfolios:
$summaries

User is looking for: "$description"

Return only the indices (e.g. 0,3,1,7) or "none" if no genuine matches.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim().toLowerCase() ?? '';
      if (text == 'none' || text.isEmpty) return [];

      final parts = text.split(RegExp(r'[,;\s]+'));
      final indices = <int>{};
      for (final s in parts) {
        final i = int.tryParse(s);
        if (i != null && i >= 0 && i < portfolios.length) indices.add(i);
      }
      return indices.take(maxResults).toList();
    } catch (_) {
      return [];
    }
  }
}
