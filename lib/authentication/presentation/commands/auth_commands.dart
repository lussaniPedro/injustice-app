import '../../../core/failure/failure.dart';
import '../../../core/patterns/command.dart';
import '../../../core/patterns/result.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_auth_facade.dart';
import '../../domain/models/auth_entities.dart';

final class SignInCommand extends ParameterizedCommand<AuthSession, Failure, SignInParams> {
  final IAuthFacade _facade;
  SignInCommand(this._facade);

  @override
  Future<AuthSessionResult> execute() async {
    if (parameter == null || parameter!.email.isEmpty || parameter!.password.isEmpty) {
      return Error(InputFailure('Informe e-mail e senha.'));
    }
    return _facade.signIn(parameter!);
  }
}

final class SignUpCommand extends ParameterizedCommand<AuthSession, Failure, SignUpParams> {
  final IAuthFacade _facade;
  SignUpCommand(this._facade);

  @override
  Future<AuthSessionResult> execute() async {
    if (parameter == null || parameter!.email.isEmpty || parameter!.password.isEmpty) {
      return Error(InputFailure('Informe e-mail e senha.'));
    }
    return _facade.signUp(parameter!);
  }
}

final class SignInWithGoogleCommand extends ParameterizedCommand<AuthSession, Failure, NoParams> {
  final IAuthFacade _facade;
  SignInWithGoogleCommand(this._facade);

  @override
  Future<AuthSessionResult> execute() => _facade.signInWithGoogle(());
}

final class SignOutCommand extends ParameterizedCommand<void, Failure, NoParams> {
  final IAuthFacade _facade;
  SignOutCommand(this._facade);

  @override
  Future<VoidResult> execute() => _facade.signOut(());
}