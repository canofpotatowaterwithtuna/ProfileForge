import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sends hire requests. Recipients see them in-app (no email - works on Firebase Spark plan).
class HireService {
  HireService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _hireRequests = 'hireRequests';

  /// Send a hire request. Recipient sees it in Hire requests screen.
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

  /// Stream hire requests for the current user (as recipient).
  Stream<List<HireRequest>> streamHireRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(_hireRequests)
        .where('toUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _toRequest(d)).toList());
  }
}

HireRequest _toRequest(DocumentSnapshot doc) {
  final m = doc.data() as Map<String, dynamic>? ?? {};
  return HireRequest(
    id: doc.id,
    fromUserId: m['fromUserId'] as String? ?? '',
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
    required this.fromUserId,
    required this.fromName,
    required this.fromCompany,
    required this.message,
    required this.contactEmail,
    this.createdAt,
  });
  final String id;
  final String fromUserId;
  final String fromName;
  final String fromCompany;
  final String message;
  final String contactEmail;
  final DateTime? createdAt;
}
