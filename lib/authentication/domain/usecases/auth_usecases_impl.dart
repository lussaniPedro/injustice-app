import '../../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import 'i_auth_usecases.dart';

final class SignInUseCase implements ISignInUseCase {
  final IAuthRepository _repository;
  SignInUseCase({required IAuthRepository authRepository}) : _repository = authRepository;

  @override
  Future<AuthSessionResult> call(SignInParams params) {
    return _repository.signIn(params.email, params.password);
  }
}

final class SignUpUseCase implements ISignUpUseCase {
  final IAuthRepository _repository;
  SignUpUseCase({required IAuthRepository authRepository}) : _repository = authRepository;

  @override
  Future<AuthSessionResult> call(SignUpParams params) {
    return _repository.signUp(name: params.name, email: params.email, password: params.password);
  }
}

final class SignInWithGoogleUseCase implements ISignInWithGoogleUseCase {
  final IAuthRepository _repository;
  SignInWithGoogleUseCase({required IAuthRepository authRepository}) : _repository = authRepository;

  @override
  Future<AuthSessionResult> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}

final class SignOutUseCase implements ISignOutUseCase {
  final IAuthRepository _repository;
  SignOutUseCase({required IAuthRepository authRepository}) : _repository = authRepository;

  @override
  Future<VoidResult> call(NoParams params) {
    return _repository.signOut();
  }
}