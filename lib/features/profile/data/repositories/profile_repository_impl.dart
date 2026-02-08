import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart' as isar;
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final Isar _isar;
  ProfileRepositoryImpl(this._isar);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final entity = await _isar.userProfiles.where().findFirst();
      return Right(_toDomain(entity ?? isar.UserProfile()));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) async {
    try {
      await _isar.writeTxn(() => _isar.userProfiles.put(_toEntity(profile)));
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  UserProfile _toDomain(isar.UserProfile entity) {
    return UserProfile(
      fullName: entity.fullName,
      bio: entity.bio,
      skills: entity.skills.map((s) => Skill(id: s, name: s)).toList(),
    );
  }

  isar.UserProfile _toEntity(UserProfile profile) {
    return isar.UserProfile(
      fullName: profile.fullName,
      bio: profile.bio,
      skills: profile.skills.map((s) => s.name).toList(),
    );
  }
}
