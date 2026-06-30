import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/failure/failure.dart';
import '../../../core/patterns/command.dart';
import '../commands/auth_commands.dart';
import '../../domain/models/auth_entities.dart';
import 'auth_session_state_viewmodel.dart';

class AuthSessionCommands {
  final AuthSessionState state;
  final SignInCommand _signIn;
  final SignUpCommand _signUp;
  final SignInWithGoogleCommand _signInWithGoogle;
  final SignOutCommand _signOut;

  AuthSessionCommands({
    required this.state,
    required SignInCommand signInCommand,
    required SignUpCommand signUpCommand,
    required SignInWithGoogleCommand signInWithGoogleCommand,
    required SignOutCommand signOutCommand,
  })  : _signIn = signInCommand,
        _signUp = signUpCommand,
        _signInWithGoogle = signInWithGoogleCommand,
        _signOut = signOutCommand {
    _observeSignIn();
    _observeSignUp();
    _observeSignInWithGoogle();
    _observeSignOut();
  }

  SignInCommand get signInCommand => _signIn;
  SignUpCommand get signUpCommand => _signUp;
  SignInWithGoogleCommand get signInWithGoogleCommand => _signInWithGoogle;
  SignOutCommand get signOutCommand => _signOut;

  Future<void> signIn(String email, String password) async {
    state.clearMessage();
    await _signIn.executeWith((email: email, password: password));
  }

  Future<void> signUp({String? name, required String email, required String password}) async {
    state.clearMessage();
    await _signUp.executeWith((name: name, email: email, password: password));
  }

  Future<void> signInWithGoogle() async {
    state.clearMessage();
    await _signInWithGoogle.executeWith(());
  }

  Future<void> signOut() async {
    state.clearMessage();
    await _signOut.executeWith(());
  }

  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }){
    effect((){
      if (command.isExecuting.value) return;
      final result = command.result.value;
      if (result == null) return;
      result.fold(
        onSuccess: (data){
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

  void _observeSignIn(){
    _observeCommand<AuthSession>(_signIn, onSuccess: state.setAuthenticated);
  }

  void _observeSignUp(){
    _observeCommand<AuthSession>(_signUp, onSuccess: state.setAuthenticated);
  }

  void _observeSignInWithGoogle(){
    _observeCommand<AuthSession>(_signInWithGoogle, onSuccess: state.setAuthenticated);
  }

  void _observeSignOut(){
    _observeCommand<void>(_signOut, onSuccess: (_) => state.setUnauthenticated());
  }
}