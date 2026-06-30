import '../../core/typedefs/types_defs.dart';

abstract interface class IProfileFacadeUseCases {
  Future<ListProfileResult> getAllProfiles(NoParams params);
  Future<ProfileResult> getProfileById(ProfileIdParams params);
  Future<ProfileResult> saveProfile(ProfileParams params);
  Future<ProfileResult> updateProfile(ProfileParams params);
  Future<VoidResult> deleteProfile(ProfileIdParams params);
}