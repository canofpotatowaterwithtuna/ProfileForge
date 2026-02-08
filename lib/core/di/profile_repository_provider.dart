import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/profile_storage.dart';
import '../../features/profile/data/repositories/profile_repository_local_impl.dart';
import '../../features/profile/data/repositories/profile_repository_mock_impl.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';

final profileStorageProvider = FutureProvider<ProfileStorage>((ref) => ProfileStorage.create());

/// Default: local (SharedPreferences). Override in tests with [profileRepositoryMockOverride].
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final asyncStorage = ref.watch(profileStorageProvider);
  return asyncStorage.when(
    data: (storage) => ProfileRepositoryLocalImpl(storage),
    loading: () => throw StateError('ProfileStorage not ready'),
    error: (e, _) => throw StateError('ProfileStorage error: $e'),
  );
});

/// For tests: override with mock and optional initial profile.
// ignore: inference_failure_on_function_return_type
profileRepositoryMockOverride({UserProfile? initial}) =>
    profileRepositoryProvider.overrideWith(
      (ref) => ProfileRepositoryMockImpl(initial: initial),
    );
