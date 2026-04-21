import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';
import '../controllers/account_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Drawer reutilizável para navegação entre páginas
class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final _vmAccount = injector.get<AccountViewModel>();

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
                  'Injustice 2 Mobile',
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
          ListTile(
            leading: Icon(
              Icons.person_add,
              color: currentRoute == AppPaths.accountCreate
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Watch(
              (_) => Text(
                _vmAccount.accountState.hasAccount.value
                    ? 'Editar Conta'
                    : 'Criar Conta',
                style: currentRoute == AppPaths.accountCreate
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
              ),
            ),
            selected: currentRoute == AppPaths.accountCreate,
            onTap: (){
              context.pop();
              if(currentRoute != AppPaths.accountCreate){
                context.goNamed(AppRouteNames.accountCreate);
              }
            },
          ),
          Watch((_){
            final hasAccount = _vmAccount.accountState.hasAccount.value;

            return ListTile(
              leading: Icon(
                Icons.people,
                color: !hasAccount
                    ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : currentRoute == AppPaths.characters
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Personagens',
                style: !hasAccount
                    ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))
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
              onTap: hasAccount
                  ? (){
                      context.pop();

                      Account account = _vmAccount.accountState.state.value!;

                      if(currentRoute != AppPaths.characters){
                        context.goNamed(
                          AppRouteNames.characters,
                          extra: account,
                        );
                      }
                    }
                  : null,
            );
          }),
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
        ],
      ),
    );
  }
}