import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// In-memory mock implementation for tests and overrides.
class ProfileRepositoryMockImpl implements IProfileRepository {
  ProfileRepositoryMockImpl({UserProfile? initial})
    : _profile = initial ?? const UserProfile();

  UserProfile _profile;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async => Right(_profile);

  @override
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) async {
    _profile = profile;
    return const Right(unit);
  }

  /// For tests: reset to empty or a given profile.
  void setProfile(UserProfile profile) {
    _profile = profile;
  }
}
