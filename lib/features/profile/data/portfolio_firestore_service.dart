import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/domain/models/profile_model.dart';
import 'profile_firestore_dto.dart';

/// Publishes portfolios to Firestore and fetches public profiles.
class PortfolioFirestoreService {
  PortfolioFirestoreService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _collection = 'portfolios';

  /// Publish the current user's profile to Firestore.
  Future<void> publish(UserProfile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    final data = ProfileFirestoreDto.toMap(profile);
    data['userId'] = uid;
    data['published'] = true;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(_collection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Whether the current user's portfolio is published.
  Future<bool> isPublished() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore.collection(_collection).doc(uid).get();
    final data = doc.data();
    return data?['published'] == true;
  }

  /// Unpublish (remove from public listings).
  Future<void> setPublished(bool published) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection(_collection).doc(uid).update({
      'published': published,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all public portfolios (for Explore).
  Stream<List<PublicPortfolio>> streamPublicPortfolios() {
    return _firestore
        .collection(_collection)
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docToPublic(d)).toList());
  }

  /// Fetch all public portfolios once (for AI search).
  Future<List<PublicPortfolio>> fetchPublicPortfolios() async {
    final snap = await _firestore
        .collection(_collection)
        .where('published', isEqualTo: true)
        .get();
    return snap.docs.map((d) => _docToPublic(d)).toList();
  }

  /// Get a single portfolio by userId.
  Future<PublicPortfolio?> getPortfolio(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || data['published'] != true) return null;
    return _docToPublic(doc);
  }

  PublicPortfolio _docToPublic(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final profile = ProfileFirestoreDto.fromMap(data);
    final userId = (data['userId'] as String?) ?? doc.id;
    return PublicPortfolio(userId: userId, profile: profile);
  }
}

class PublicPortfolio {
  const PublicPortfolio({required this.userId, required this.profile});
  final String userId;
  final UserProfile profile;
}
