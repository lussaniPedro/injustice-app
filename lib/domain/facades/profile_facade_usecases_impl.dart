import '../../core/typedefs/types_defs.dart';
import 'profile_facade_usecases_interface.dart';
import '../usecases/profile_usecases_interfaces.dart';

final class ProfileFacadeUsecasesImpl implements IProfileFacadeUseCases {
  final IGetAllProfilesUseCase _getAllProfilesUseCase;
  final IGetProfileByIdUseCase _getProfileByIdUseCase;
  final ISaveProfileUseCase _saveProfileUseCase;
  final IUpdateProfileUseCase _updateProfileUseCase;
  final IDeleteProfileUseCase _deleteProfileUseCase;

  ProfileFacadeUsecasesImpl({
    required IGetAllProfilesUseCase getAllProfilesUseCase,
    required IGetProfileByIdUseCase getProfileByIdUseCase,
    required ISaveProfileUseCase saveProfileUseCase,
    required IUpdateProfileUseCase updateProfileUseCase,
    required IDeleteProfileUseCase deleteProfileUseCase,
  })  : _getAllProfilesUseCase = getAllProfilesUseCase,
        _getProfileByIdUseCase = getProfileByIdUseCase,
        _saveProfileUseCase = saveProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteProfileUseCase = deleteProfileUseCase;

  @override
  Future<ListProfileResult> getAllProfiles(NoParams params) =>
      _getAllProfilesUseCase(params);

  @override
  Future<ProfileResult> getProfileById(ProfileIdParams params) =>
      _getProfileByIdUseCase(params);

  @override
  Future<ProfileResult> saveProfile(ProfileParams params) =>
      _saveProfileUseCase(params);

  @override
  Future<ProfileResult> updateProfile(ProfileParams params) =>
      _updateProfileUseCase(params);

  @override
  Future<VoidResult> deleteProfile(ProfileIdParams params) =>
      _deleteProfileUseCase(params);
}