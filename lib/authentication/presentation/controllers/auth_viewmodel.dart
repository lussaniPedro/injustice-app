import '../../domain/facades/i_auth_facade.dart';
import '../commands/auth_commands.dart';
import 'auth_session_commands_viewmodel.dart';
import 'auth_session_state_viewmodel.dart';

class AuthViewModel {
  late final AuthSessionState _session;
  late final AuthSessionCommands _commands;

  AuthSessionState get session => _session;
  AuthSessionCommands get commands => _commands;

  AuthViewModel(IAuthFacade facade) {
    _session = AuthSessionState();
    _commands = AuthSessionCommands(
      state: _session,
      signInCommand: SignInCommand(facade),
      signUpCommand: SignUpCommand(facade),
      signInWithGoogleCommand: SignInWithGoogleCommand(facade),
      signOutCommand: SignOutCommand(facade),
    );
  }
}