import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../controllers/profile_session_state.dart';

import '../../authentication/presentation/controllers/auth_viewmodel.dart';
// ...resto dos imports já existentes...

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final _profileSession = injector.get<ProfileSessionState>();
  final _vmAuth = injector.get<AuthViewModel>(); // NOVO

  @override
  Widget build(BuildContext context){
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ...DrawerHeader, Início, Editar Perfil, Personagens (inalterados)...

          ListTile(
            leading: Icon(
              Icons.switch_account,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Trocar de Perfil',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: (){
              context.pop();
              _profileSession.clearActiveProfile();
              context.goNamed(AppRouteNames.profileSelection);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'Sair da Conta',
              style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w500),
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

              if(!confirm) return;

              await _vmAuth.commands.signOut();
              // o redirect do GoRouter cuida de levar pro login automaticamente
            },
          ),

          ListTile(
            leading: Icon(
              Icons.info,
              color: currentRoute == AppPaths.about
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text('Sobre', /* ...inalterado... */),
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