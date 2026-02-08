import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/account_type_service.dart';
import '../../features/discover/data/ai_discovery_service.dart';
import '../../features/hire/data/hire_service.dart';
import '../../features/profile/data/portfolio_firestore_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final portfolioFirestoreProvider = Provider<PortfolioFirestoreService>((ref) {
  return PortfolioFirestoreService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final hireServiceProvider = Provider<HireService>((ref) {
  return HireService(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

final accountTypeServiceProvider = Provider<AccountTypeService>((ref) {
  return AccountTypeService(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

final aiDiscoveryServiceProvider = Provider<AiDiscoveryService>((ref) {
  return AiDiscoveryService.create();
});

final isPublishedProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth.currentUser == null) return false;
  return ref.read(portfolioFirestoreProvider).isPublished();
});
