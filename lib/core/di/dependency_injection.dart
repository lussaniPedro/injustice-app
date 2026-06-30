import 'package:auto_injector/auto_injector.dart';

// Imports novos no topo do arquivo
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/account_repository_interface.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../data/repositories/character_repository_interface.dart';
import '../../data/services/account_local_storage_interface.dart';
import '../../data/services/account_shared_preferences_impl.dart';
import '../../data/services/character_local_storage_interface.dart';
import '../../data/services/character_shared_preferences_impl.dart';
import '../../domain/facades/account_facade_usecases_impl.dart';
import '../../domain/facades/account_facade_usecases_interface.dart';
import '../../domain/facades/character_facade_usecases_impl.dart';
import '../../domain/facades/character_facade_usecases_interface.dart';
import '../../domain/usecases/account_usecases_impl.dart';
import '../../domain/usecases/account_usecases_interfaces.dart';
import '../../domain/usecases/character_usecases_impl.dart';
import '../../domain/usecases/character_usecases_interfaces.dart';
import '../../presentation/controllers/account_viewmodel.dart';
import '../../presentation/controllers/characters_view_model.dart';
import '../theme/theme_controller.dart';
import '../../authentication/data/repositories/auth_repository_impl.dart';
import '../../authentication/data/repositories/i_auth_repository.dart';
import '../../authentication/data/services/local/auth_local_session_manager.dart';
import '../../authentication/data/services/local/i_local_session_store.dart';
import '../../authentication/data/services/local/shared_pref_local_session_service.dart';
import '../../authentication/data/services/remote/firebase_auth_service.dart';
import '../../authentication/data/services/remote/i_auth_service.dart';
import '../../authentication/domain/facades/auth_facade_impl.dart';
import '../../authentication/domain/facades/i_auth_facade.dart';
import '../../authentication/domain/usecases/auth_usecases_impl.dart';
import '../../authentication/domain/usecases/i_auth_usecases.dart';
import '../../authentication/presentation/controllers/auth_viewmodel.dart';

final injector = AutoInjector();
void setupDependencyInjection() {

  // Regristração de dependências do Core
  injector.addSingleton<ThemeController>(ThemeController.new);

  // Regristração de dependências para Account
  // Repositories e servicos
  injector.addSingleton<IAccountLocalStorage>(AccountSharedPreferencesService.new);
  injector.addSingleton<IAccountRepository>(AccountRepositoryImpl.new);
  // Use Cases e Facades
  injector.addSingleton<IAccountFacadeUseCases>(AccountFacadeUsecasesImpl.new);
  injector.addSingleton<IGetAccountUseCase>(GetAccountUseCaseImpl.new);
  injector.addSingleton<ISaveAccountUseCase>(SaveAccountUseCaseImpl.new);
  injector.addSingleton<IDeleteAccountUseCase>(DeleteAccountUseCaseImpl.new);
  injector.addSingleton<IUpdateAccountUseCase>(UpdateAccountUseCaseImpl.new);
  
  // Regristração de dependências para Character
  // Repositories e serviços
  injector.addSingleton<ICharacterLocalStorage>(CharacterSharedPreferencesService.new);
  injector.addSingleton<ICharacterRepository>(CharacterRepositoryImpl.new);
  // Use Cases e Facades
  injector.addSingleton<ICharacterFacadeUseCases>(CharacterFacadeUseCasesImpl.new);
  injector.addSingleton<IGetAllCharactersUseCase>(GetAllCharactersUseCaseImpl.new);
  injector.addSingleton<IGetCharacterByIdUseCase>(GetCharacterByIdUseCaseImpl.new);
  injector.addSingleton<ISaveCharacterUseCase>(SaveCharacterUseCaseImpl.new);
  injector.addSingleton<IUpdateCharacterUseCase>(UpdateCharacterUseCaseImpl.new);
  injector.addSingleton<IDeleteCharacterUseCase>(DeleteCharacterUseCaseImpl.new);
  injector.addSingleton<IDeleteAllCharactersUseCase>(DeleteAllCharactersUseCaseImpl.new);
  

  // viewmodes
  // Account viewmodes
  injector.addSingleton<AccountViewModel>(AccountViewModel.new);
  // Character List viewmodel
  injector.addSingleton<CharactersViewModel>(CharactersViewModel.new);

  // Sessão
  injector.addSingleton<ILocalSessionStore>(SharedPrefLocalSessionService.new);
  injector.addSingleton<AuthLocalSessionManager>(AuthLocalSessionManager.new);
  injector.addSingleton<IAuthService>(FirebaseAuthService.new);
  injector.addSingleton<IAuthRepository>(AuthRepositoryImpl.new);

  injector.addSingleton<ISignInUseCase>(SignInUseCase.new);
  injector.addSingleton<ISignUpUseCase>(SignUpUseCase.new);
  injector.addSingleton<ISignInWithGoogleUseCase>(SignInWithGoogleUseCase.new);
  injector.addSingleton<ISignOutUseCase>(SignOutUseCase.new);
  injector.addSingleton<IAuthFacade>(AuthFacadeImpl.new);

  injector.addSingleton<AuthViewModel>(AuthViewModel.new);

  injector.commit();
}