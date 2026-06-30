import '../../../core/patterns/i_usecases.dart';
import '../../../core/typedefs/types_defs.dart';

abstract interface class ISignInUseCase
    implements IUseCase<AuthSessionResult, SignInParams> {}

abstract interface class ISignUpUseCase
    implements IUseCase<AuthSessionResult, SignUpParams> {}

abstract interface class ISignInWithGoogleUseCase
    implements IUseCase<AuthSessionResult, NoParams> {}

abstract interface class ISignOutUseCase
    implements IUseCase<VoidResult, NoParams> {}