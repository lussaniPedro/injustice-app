import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/profile_repository_interface.dart';
import 'profile_usecases_interfaces.dart';

const int kMaxProfilesPerAccount = 4;

final class GetAllProfilesUseCaseImpl implements IGetAllProfilesUseCase {
  final IProfileRepository _repository;

  GetAllProfilesUseCaseImpl({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<ListProfileResult> call(NoParams params) {
    return _repository.getAllProfiles();
  }
}

final class GetProfileByIdUseCaseImpl implements IGetProfileByIdUseCase {
  final IProfileRepository _repository;

  GetProfileByIdUseCaseImpl({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<ProfileResult> call(ProfileIdParams params) {
    return _repository.getProfileById(params.id);
  }
}

final class SaveProfileUseCaseImpl implements ISaveProfileUseCase {
  final IProfileRepository _repository;

  SaveProfileUseCaseImpl({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<ProfileResult> call(ProfileParams params) async {
    final existing = await _repository.getAllProfiles();

    final currentCount = existing.fold(
      onSuccess: (profiles) => profiles.length,
      onFailure: (_) => 0, // EmptyResultFailure = nenhum perfil ainda
    );

    if (currentCount >= kMaxProfilesPerAccount) {
      return Error(ProfileLimitReachedFailure());
    }

    await Future.delayed(const Duration(seconds: 1));
    return _repository.saveProfile(params.profile);
  }
}

final class UpdateProfileUseCaseImpl implements IUpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCaseImpl({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<ProfileResult> call(ProfileParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    return _repository.updateProfile(params.profile);
  }
}

final class DeleteProfileUseCaseImpl implements IDeleteProfileUseCase {
  final IProfileRepository _repository;

  DeleteProfileUseCaseImpl({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(ProfileIdParams params) async {
    await Future.delayed(const Duration(seconds: 1));
    return _repository.deleteProfile(params.id);
  }
}