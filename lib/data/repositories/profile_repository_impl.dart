import '../../core/typedefs/types_defs.dart';
import '../../domain/models/profile_entity.dart';
import '../services/profile_local_storage_interface.dart';
import 'profile_repository_interface.dart';

final class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileLocalStorage _localStorage;

  ProfileRepositoryImpl({required IProfileLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<ListProfileResult> getAllProfiles() => _localStorage.getAllProfiles();

  @override
  Future<ProfileResult> getProfileById(String id) =>
      _localStorage.getProfileById(id);

  @override
  Future<ProfileResult> saveProfile(Profile profile) =>
      _localStorage.saveProfile(profile);

  @override
  Future<ProfileResult> updateProfile(Profile profile) =>
      _localStorage.updateProfile(profile);

  @override
  Future<VoidResult> deleteProfile(String id) =>
      _localStorage.deleteProfile(id);
}