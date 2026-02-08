import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages account type (portfolio vs hirer) in Firestore.
class AccountTypeService {
  AccountTypeService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _users = 'users';

  Future<void> setAccountType({
    required String accountType,
    String? companyName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _firestore.collection(_users).doc(uid).set({
      'accountType': accountType,
      if (companyName != null && companyName.isNotEmpty)
        'companyName': companyName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getAccountType() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection(_users).doc(uid).get();
    return doc.data()?['accountType'] as String?;
  }

  Stream<String?> streamAccountType() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore
        .collection(_users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['accountType'] as String?);
  }
}
