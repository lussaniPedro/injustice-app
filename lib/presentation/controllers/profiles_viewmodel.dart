import '../../domain/facades/profile_facade_usecases_interface.dart';
import '../commands/profile_commands.dart';
import 'profiles_commands_viewmodel.dart';
import 'profiles_state_viewmodel.dart';

class ProfilesViewModel {
  late final ProfilesStateViewModel _state;
  ProfilesStateViewModel get profilesState => _state;

  late final ProfilesCommandsViewModel commands;

  ProfilesViewModel(IProfileFacadeUseCases facade) {
    _state = ProfilesStateViewModel();
    commands = ProfilesCommandsViewModel(
      state: _state,
      getAllProfilesCommand: GetAllProfilesCommand(facade),
      createProfileCommand: CreateProfileCommand(facade),
      updateProfileCommand: UpdateProfileCommand(facade),
      deleteProfileCommand: DeleteProfileCommand(facade),
    );
  }
}