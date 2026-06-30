import 'package:signals_flutter/signals_flutter.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/profile_entity.dart';
import '../commands/profile_commands.dart';
import 'profiles_state_viewmodel.dart';

class ProfilesCommandsViewModel {
  final ProfilesStateViewModel state;
  final GetAllProfilesCommand _getAllProfilesCommand;
  final CreateProfileCommand _createProfileCommand;
  final UpdateProfileCommand _updateProfileCommand;
  final DeleteProfileCommand _deleteProfileCommand;

  ProfilesCommandsViewModel({
    required this.state,
    required GetAllProfilesCommand getAllProfilesCommand,
    required CreateProfileCommand createProfileCommand,
    required UpdateProfileCommand updateProfileCommand,
    required DeleteProfileCommand deleteProfileCommand,
  })  : _getAllProfilesCommand = getAllProfilesCommand,
        _createProfileCommand = createProfileCommand,
        _updateProfileCommand = updateProfileCommand,
        _deleteProfileCommand = deleteProfileCommand {
    _observeGetAllProfiles();
    _observeCreateProfile();
    _observeUpdateProfile();
    _observeDeleteProfile();
  }

  GetAllProfilesCommand get getAllProfilesCommand => _getAllProfilesCommand;
  CreateProfileCommand get createProfileCommand => _createProfileCommand;
  UpdateProfileCommand get updateProfileCommand => _updateProfileCommand;
  DeleteProfileCommand get deleteProfileCommand => _deleteProfileCommand;

  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }){
    effect((){
      if(command.isExecuting.value) return;
      final result = command.result.value;
      if(result == null) return;

      result.fold(
        onSuccess: (data){
          state.clearMessage();
          onSuccess(data);
          command.clear();
        },
        onFailure: (err){
          state.setMessage(err.msg);
          onFailure?.call(err);
          command.clear();
        },
      );
    });
  }

  void _observeGetAllProfiles(){
    _observeCommand<List<Profile>>(
      _getAllProfilesCommand,
      onSuccess: (profiles) => state.state.value = profiles,
      onFailure: (err){
        // EmptyResultFailure aqui é esperado (conta nova sem perfis ainda)
        if(err is! EmptyResultFailure){
          state.setMessage(err.msg);
        }
        state.state.value = [];
      },
    );
  }

  void _observeCreateProfile(){
    _observeCommand<Profile>(
      _createProfileCommand,
      onSuccess: (newProfile){
        state.state.value = [...state.state.value, newProfile];
        state.successEvent.value = ProfileSuccessEvent.created;
      },
    );
  }

  void _observeUpdateProfile(){
    _observeCommand<Profile>(
      _updateProfileCommand,
      onSuccess: (updated){
        final list = [...state.state.value];
        final index = list.indexWhere((p) => p.id == updated.id);
        if(index != -1) list[index] = updated;
        state.state.value = list;
        state.successEvent.value = ProfileSuccessEvent.updated;
      },
    );
  }

  void _observeDeleteProfile(){
    _observeCommand<void>(
      _deleteProfileCommand,
      onSuccess: (_){
        final deletedId = _deleteProfileCommand.parameter?.id;
        state.state.value =
            state.state.value.where((p) => p.id != deletedId).toList();
        state.successEvent.value = ProfileSuccessEvent.deleted;
      },
    );
  }

  Future<void> fetchProfiles() async {
    state.clearMessage();
    await _getAllProfilesCommand.executeWith(());
  }

  Future<void> createProfile(Profile profile) async {
    state.clearMessage();
    await _createProfileCommand.executeWith((profile: profile));
  }

  Future<void> updateProfile(Profile profile) async {
    state.clearMessage();
    await _updateProfileCommand.executeWith((profile: profile));
  }

  Future<void> deleteProfile(String id) async {
    state.clearMessage();
    await _deleteProfileCommand.executeWith((id: id));
  }
}