import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get preferredLanguage => text().nullable()();
  TextColumn get state => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [UserProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // User Profile methods
  Future<List<UserProfile>> getAllUserProfiles() => select(userProfiles).get();
  
  Future<UserProfile?> getUserProfile() => select(userProfiles).getSingleOrNull();
  
  Future<int> insertUserProfile(UserProfilesCompanion profile) {
    return into(userProfiles).insert(profile);
  }
  
  Future<bool> updateUserProfile(UserProfilesCompanion profile) {
    return update(userProfiles).replace(profile);
  }
  
  Future<int> deleteUserProfile(int id) {
    return (delete(userProfiles)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nazarriya.db'));
    return NativeDatabase(file);
  });
}
