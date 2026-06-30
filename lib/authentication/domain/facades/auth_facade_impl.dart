import '../../../core/typedefs/types_defs.dart';
import '../usecases/i_auth_usecases.dart';
import 'i_auth_facade.dart';

class AuthFacadeImpl implements IAuthFacade {
  final ISignInUseCase _signIn;
  final ISignUpUseCase _signUp;
  final ISignInWithGoogleUseCase _signInWithGoogle;
  final ISignOutUseCase _signOut;

  AuthFacadeImpl({
    required ISignInUseCase signInUseCase,
    required ISignUpUseCase signUpUseCase,
    required ISignInWithGoogleUseCase signInWithGoogleUseCase,
    required ISignOutUseCase signOutUseCase,
  })  : _signIn = signInUseCase,
        _signUp = signUpUseCase,
        _signInWithGoogle = signInWithGoogleUseCase,
        _signOut = signOutUseCase;

  @override
  Future<AuthSessionResult> signIn(SignInParams params) => _signIn(params);

  @override
  Future<AuthSessionResult> signUp(SignUpParams params) => _signUp(params);

  @override
  Future<AuthSessionResult> signInWithGoogle(NoParams params) => _signInWithGoogle(params);

  @override
  Future<VoidResult> signOut(NoParams params) => _signOut(params);
}