import '../../../core/typedefs/types_defs.dart';

abstract interface class IAuthFacade {
  Future<AuthSessionResult> signIn(SignInParams params);
  Future<AuthSessionResult> signUp(SignUpParams params);
  Future<AuthSessionResult> signInWithGoogle(NoParams params);
  Future<VoidResult> signOut(NoParams params);
}