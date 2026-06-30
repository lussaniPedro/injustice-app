import '../../core/typedefs/types_defs.dart';
import '../../domain/models/profile_entity.dart';

abstract interface class IProfileLocalStorage {
  Future<ListProfileResult> getAllProfiles();
  Future<ProfileResult> getProfileById(String id);
  Future<ProfileResult> saveProfile(Profile profile);
  Future<ProfileResult> updateProfile(Profile profile);
  Future<VoidResult> deleteProfile(String id);
}