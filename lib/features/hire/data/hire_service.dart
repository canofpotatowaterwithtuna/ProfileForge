import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sends hire requests. Recipients see them in-app with contact info to manage externally.
class HireService {
  HireService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _hireRequests = 'hireRequests';

  /// Send a hire request. Recipient sees it in Hire requests screen with contact info.
  Future<void> sendHireRequest({
    required String toUserId,
    required String recipientEmail,
    required String fromName,
    required String fromCompany,
    required String message,
    required String contactEmail,
  }) async {
    final fromUserId = _auth.currentUser?.uid;
    if (fromUserId == null) throw StateError('Not authenticated');

    await _firestore.collection(_hireRequests).doc().set({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromName': fromName,
      'fromCompany': fromCompany,
      'message': message,
      'contactEmail': contactEmail,
      'recipientEmail': recipientEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream hire requests received by the current user.
  /// Uses simple where (no composite index needed). Sorts by createdAt in memory.
  Stream<List<HireRequest>> streamHireRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(_hireRequests)
        .where('toUserId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => _toRequest(d)).toList();
          list.sort((a, b) {
            final aAt = a.createdAt ?? DateTime(0);
            final bAt = b.createdAt ?? DateTime(0);
            return bAt.compareTo(aAt); // newest first
          });
          return list;
        });
  }
}

HireRequest _toRequest(DocumentSnapshot doc) {
  final m = doc.data() as Map<String, dynamic>? ?? {};
  return HireRequest(
    id: doc.id,
    fromName: m['fromName'] as String? ?? '',
    fromCompany: m['fromCompany'] as String? ?? '',
    message: m['message'] as String? ?? '',
    contactEmail: m['contactEmail'] as String? ?? '',
    createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
  );
}

class HireRequest {
  const HireRequest({
    required this.id,
    required this.fromName,
    required this.fromCompany,
    required this.message,
    required this.contactEmail,
    this.createdAt,
  });
  final String id;
  final String fromName;
  final String fromCompany;
  final String message;
  final String contactEmail;
  final DateTime? createdAt;
}
