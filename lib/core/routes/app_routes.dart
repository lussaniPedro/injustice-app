import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../authentication/presentation/controllers/auth_viewmodel.dart';
import '../../authentication/presentation/views/auth_view.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/profile_entity.dart';
import '../../presentation/controllers/profile_session_state.dart';
import '../../presentation/views/about_view.dart';
import '../../presentation/views/characters/list_of/characters_form_view.dart';
import '../../presentation/views/characters/list_of/characters_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/profiles/profile_create_view.dart';
import '../../presentation/views/profiles/profile_selection_view.dart';
import '../di/dependency_injection.dart';


/// Route names for easier referencing
class AppRouteNames {
  static const login = 'login';
  static const home = 'home';
  static const about = 'about';
  static const profileSelection = 'profile_selection';
  static const profileCreate = 'profile_create';
  static const characters = 'characters';
  static const characterForm = 'character_form';
}

/// Paths to keep URL structure consistent
class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static const about = '/about';
  static const profileSelection = '/profile-selection';
  static const profileCreate = '/profile-create';
  static const characters = '/characters';
  static const characterForm = '/character-form';
}

class _RouterRefreshListenable extends ChangeNotifier {
  late final void Function() _disposeEffect;

  _RouterRefreshListenable(){
    _disposeEffect = effect((){
      injector.get<AuthViewModel>().session.status.value;
      injector.get<ProfileSessionState>().activeProfile.value;
      notifyListeners();
    });
  }

  @override
  void dispose(){
    _disposeEffect();
    super.dispose();
  }
}

/// app routers using go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.login,
    refreshListenable: _RouterRefreshListenable(),
    redirect: (context, state){
      final authVm = injector.get<AuthViewModel>();
      final profileSession = injector.get<ProfileSessionState>();

      final isAuthenticated = authVm.session.isAuthenticated;
      final hasActiveProfile = profileSession.hasActiveProfile.value;

      final isOnLogin = state.matchedLocation == AppPaths.login;
      final isOnProfileSelection = state.matchedLocation == AppPaths.profileSelection;
      final isOnProfileCreate = state.matchedLocation == AppPaths.profileCreate;

      if(!isAuthenticated){
        return isOnLogin ? null : AppPaths.login;
      }

      if(isOnLogin){
        return AppPaths.profileSelection;
      }

      if(!hasActiveProfile && !isOnProfileSelection && !isOnProfileCreate){
        return AppPaths.profileSelection;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppPaths.login,
        name: AppRouteNames.login,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AuthView()),
      ),
      GoRoute(
        path: AppPaths.profileSelection,
        name: AppRouteNames.profileSelection,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProfileSelectionView()),
      ),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeView()),
      ),
      GoRoute(
        path: AppPaths.profileCreate,
        name: AppRouteNames.profileCreate,
        pageBuilder: (context, state){
          final profile = state.extra as Profile?;
          return NoTransitionPage(child: ProfileCreateView(profile: profile));
        },
      ),
      GoRoute(
        path: AppPaths.characters,
        name: AppRouteNames.characters,
        pageBuilder: (context, state){
          final profile = state.extra as Profile;
          return NoTransitionPage(child: CharactersView(profile: profile));
        },
      ),
      GoRoute(
        path: AppPaths.characterForm,
        name: AppRouteNames.characterForm,
        pageBuilder: (context, state){
          final character = state.extra as Character?;
          return NoTransitionPage(child: CharacterFormView(character: character));
        },
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRouteNames.about,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AboutView()),
      ),
    ],
  );
}
