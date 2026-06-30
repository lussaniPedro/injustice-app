import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IGetAllProfilesUseCase
    implements IUseCase<ListProfileResult, NoParams> {}

abstract interface class IGetProfileByIdUseCase
    implements IUseCase<ProfileResult, ProfileIdParams> {}

abstract interface class ISaveProfileUseCase
    implements IUseCase<ProfileResult, ProfileParams> {}

abstract interface class IUpdateProfileUseCase
    implements IUseCase<ProfileResult, ProfileParams> {}

abstract interface class IDeleteProfileUseCase
    implements IUseCase<VoidResult, ProfileIdParams> {}