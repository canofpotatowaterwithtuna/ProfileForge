import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/profile_repository_provider.dart';
import '../../domain/models/profile_model.dart';

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    await ref.watch(profileStorageProvider.future);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getProfile();
    return result.fold((f) => throw Exception(f.message), (r) => r);
  }

  /// Optimistic update: set UI immediately, then persist; on failure revert. Returns true if saved.
  Future<bool> updateFullProfile(UserProfile profile) async {
    final previous = state.value;
    state = AsyncValue.data(profile);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.saveProfile(profile);
    return result.fold(
      (f) {
        state = AsyncValue.data(previous ?? profile);
        return false;
      },
      (_) {
        state = AsyncValue.data(profile);
        return true;
      },
    );
  }

  void updateProfile(String name, String bio) {
    state.whenData((current) {
      updateFullProfile(current.copyWith(fullName: name, bio: bio));
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
