import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/profile_facade_usecases_interface.dart';
import '../../domain/models/profile_entity.dart';

final class GetAllProfilesCommand
    extends ParameterizedCommand<List<Profile>, Failure, NoParams> {
  final IProfileFacadeUseCases _facade;
  GetAllProfilesCommand(this._facade);

  @override
  Future<ListProfileResult> execute() => _facade.getAllProfiles(());
}

final class CreateProfileCommand
    extends ParameterizedCommand<Profile, Failure, ProfileParams> {
  final IProfileFacadeUseCases _facade;
  CreateProfileCommand(this._facade);

  @override
  Future<ProfileResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parâmetro nulo para criar perfil.'));
    }
    return _facade.saveProfile(parameter!);
  }
}

final class UpdateProfileCommand
    extends ParameterizedCommand<Profile, Failure, ProfileParams> {
  final IProfileFacadeUseCases _facade;
  UpdateProfileCommand(this._facade);

  @override
  Future<ProfileResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parâmetro nulo para atualizar perfil.'));
    }
    return _facade.updateProfile(parameter!);
  }
}

final class DeleteProfileCommand
    extends ParameterizedCommand<void, Failure, ProfileIdParams> {
  final IProfileFacadeUseCases _facade;
  DeleteProfileCommand(this._facade);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) {
      return Error(InputFailure('Parâmetro nulo para deletar perfil.'));
    }
    return _facade.deleteProfile(parameter!);
  }
}