import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/firebase_providers.dart';
import '../../../discover/presentation/screens/discover_screen.dart';
import 'home_screen.dart';

/// Shows HomeScreen for portfolio owners, DiscoverScreen for hirers.
class HomeWrapper extends ConsumerWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountTypeAsync = ref.watch(_accountTypeStreamProvider);

    return accountTypeAsync.when(
      data: (accountType) {
        if (accountType == 'hirer') return const DiscoverScreen();
        return const HomeScreen();
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      ),
      error: (_, __) => const HomeScreen(),
    );
  }
}

final _accountTypeStreamProvider = StreamProvider<String?>((ref) {
  return ref.watch(accountTypeServiceProvider).streamAccountType();
});