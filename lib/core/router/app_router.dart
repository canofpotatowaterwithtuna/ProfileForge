import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/firebase_providers.dart';
import '../../features/auth/presentation/screens/account_type_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/forge/presentation/screens/forge_screen.dart';
import '../../features/hire/presentation/screens/hire_requests_screen.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/home_wrapper.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeWrapper(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final profile = state.extra as UserProfile;
              return EditProfileScreen(profile: profile);
            },
          ),
        ],
      ),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/account-type',
        builder: (_, __) => const AccountTypeScreen(),
      ),
      GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
      GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
      GoRoute(path: '/forge', builder: (_, __) => const ForgeScreen()),
      GoRoute(
        path: '/hire-requests',
        builder: (_, __) => const HireRequestsScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return PublicProfileScreen(userId: userId);
        },
      ),
    ],
    redirect: (context, state) async {
      final path = state.uri.path;
      if (path == '/auth' || path == '/account-type' || path == '/verify-email')
        return null;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '/auth';
      if (!user.emailVerified) return '/verify-email';
      final accountType = await ref
          .read(accountTypeServiceProvider)
          .getAccountType();
      if (accountType == null) return '/account-type';
      return null;
    },
  );
});
