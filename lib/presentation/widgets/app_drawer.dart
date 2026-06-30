import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/authentication/presentation/controllers/auth_viewmodel.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/profile_session_state.dart';

/// Drawer reutilizável para navegação entre páginas
class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final _profileSession = injector.get<ProfileSessionState>();
  final _vmAuth = injector.get<AuthViewModel>();

  @override
  Widget build(BuildContext context){
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.videogame_asset,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'InjusticeApp Mobile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: currentRoute == AppPaths.home
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Início',
              style: currentRoute == AppPaths.home
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            ),
            selected: currentRoute == AppPaths.home,
            onTap: (){
              context.pop();
              if(currentRoute != AppPaths.home){
                context.goNamed(AppRouteNames.home);
              }
            },
          ),
          Watch((_){
            return ListTile(
              leading: Icon(
                Icons.person_add,
                color: currentRoute == AppPaths.profileCreate
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Editar Perfil',
                style: currentRoute == AppPaths.profileCreate
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
              ),
              selected: currentRoute == AppPaths.profileCreate,
              onTap: (){
                context.pop();

                if(currentRoute != AppPaths.profileCreate){
                  context.goNamed(AppRouteNames.profileCreate);
                }
              },
            );
          }),
          Watch((_){
            final profile = _profileSession.activeProfile.value;
            final hasProfile = profile != null;

            return ListTile(
              leading: Icon(
                Icons.people,
                color: !hasProfile
                    ? Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5)
                    : currentRoute == AppPaths.characters
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Personagens',
                style: !hasProfile
                    ? TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5),
                      )
                    : currentRoute == AppPaths.characters
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                        : TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
              ),
              selected: currentRoute == AppPaths.characters,
              onTap: hasProfile
                  ? (){
                      context.pop();

                      if(currentRoute != AppPaths.characters){
                        context.goNamed(
                          AppRouteNames.characters,
                          extra: profile,
                        );
                      }
                    }
                  : null,
            );
          }),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.info,
              color: currentRoute == AppPaths.about
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Sobre',
              style: currentRoute == AppPaths.about
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            ),
            selected: currentRoute == AppPaths.about,
            onTap: (){
              context.pop();
              if(currentRoute != AppPaths.about){
                context.goNamed(AppRouteNames.about);
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.switch_account,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Trocar de Perfil',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () {
              context.pop();
              _profileSession.clearActiveProfile();
              context.goNamed(AppRouteNames.profileSelection);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red.shade400,
            ),
            title: Text(
              'Sair da Conta',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              context.pop();

              final confirm = await confirmDialog(
                context,
                title: 'Sair da conta',
                message: 'Tem certeza que deseja sair?',
                confirmText: 'SAIR',
                icon: Icons.logout,
              );

              if (!confirm) return;

              await _vmAuth.commands.signOut();
            },
          ),
        ],
      ),
    );
  }
}