// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a stub file. Run `flutter pub run build_runner build` to generate the proper file.

part of 'user_profile.dart';

// Stub schema - proper generation needed for production
// Note: This is a minimal stub. For production, run: flutter pub run build_runner build
final userProfileSchema = CollectionSchema<UserProfile>(
  name: 'UserProfile',
  id: 123456789,
  properties: {
    'id': PropertySchema(
      id: 0,
      name: 'id',
      type: IsarType.long,
    ),
    'fullName': PropertySchema(
      id: 1,
      name: 'fullName',
      type: IsarType.string,
    ),
    'bio': PropertySchema(
      id: 2,
      name: 'bio',
      type: IsarType.string,
    ),
    'skills': PropertySchema(
      id: 3,
      name: 'skills',
      type: IsarType.stringList,
    ),
  },
  indexes: {},
  idName: 'id',
  links: {},
  embeddedSchemas: {},
  estimateSize: ((UserProfile obj) => 100) as EstimateSize<UserProfile>,
  serialize:
      ((UserProfile obj, IsarWriter writer) {
            writer.writeLong(0, obj.id);
            writer.writeString(1, obj.fullName);
            writer.writeString(2, obj.bio);
            writer.writeStringList(3, obj.skills);
          })
          as Serialize<UserProfile>,
  deserialize:
      ((Id id, IsarReader reader) {
            final obj = UserProfile();
            obj.id = reader.readLong(0);
            obj.fullName = reader.readString(1);
            obj.bio = reader.readString(2);
            obj.skills = reader.readStringList(3) ?? [];
            return obj;
          })
          as Deserialize<UserProfile>,
  deserializeProp:
      ((IsarReader reader, int propertyId, int offset) => null)
          as DeserializeProp,
  getId: (UserProfile obj) => obj.id,
  getLinks: (UserProfile obj) => <IsarLinkBase<dynamic>>[],
  version: '1',
  attach:
      ((
            IsarCollection<UserProfile> collection,
            Id id,
            UserProfile object,
            bool alreadyLoaded,
          ) {})
          as Attach<UserProfile>,
);

// Export with the expected name (uppercase for schema constant)
// ignore: non_constant_identifier_names
final UserProfileSchema = userProfileSchema;

// Stub for collection access
extension UserProfileCollectionExtension on Isar {
  IsarCollection<UserProfile> get userProfiles =>
      this.collection<UserProfile>();
}
