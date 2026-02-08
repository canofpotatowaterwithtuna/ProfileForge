import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String fullName;
  late String bio;

  // We'll store skills as a simple list of strings for L1
  List<String> skills = [];

  UserProfile({
    this.fullName = '',
    this.bio = '',
    this.skills = const [],
  });
}
