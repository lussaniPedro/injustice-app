import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/presentation/controllers/auth_viewmodel.dart';
import '../controllers/profile_session_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DrawerHeader(),
          _NavigationTile(
            route: AppPaths.home,
            currentRoute: currentRoute,
            icon: Icons.home,
            label: 'Início',
            onTap: () => _navigateTo(context, AppPaths.home, currentRoute),
          ),
          _ProfileCreateTile(currentRoute: currentRoute),
          _CharactersTile(currentRoute: currentRoute),
          const Divider(),
          _NavigationTile(
            route: AppPaths.about,
            currentRoute: currentRoute,
            icon: Icons.info,
            label: 'Sobre',
            onTap: () => _navigateTo(context, AppPaths.about, currentRoute),
          ),
          _SwitchProfileTile(),
          _LogoutTile(),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route, String currentRoute) {
    if (route == currentRoute) return;
    context.pop();
    context.goNamed(_routeName(route));
  }

  String _routeName(String path) {
    return switch (path) {
      AppPaths.home => AppRouteNames.home,
      AppPaths.profileCreate => AppRouteNames.profileCreate,
      AppPaths.characters => AppRouteNames.characters,
      AppPaths.about => AppRouteNames.about,
      _ => AppRouteNames.home,
    };
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
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
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.route,
    required this.currentRoute,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String route;
  final String currentRoute;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = route == currentRoute;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.secondary : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

class _ProfileCreateTile extends StatelessWidget {
  const _ProfileCreateTile({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final isSelected = currentRoute == AppPaths.profileCreate;
      final colorScheme = Theme.of(context).colorScheme;

      return ListTile(
        leading: Icon(
          Icons.person_add,
          color: isSelected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.secondary : colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onTap: () {
          if (isSelected) return;
          context.pop();
          final profile = injector.get<ProfileSessionState>().activeProfile.value;
          context.goNamed(AppRouteNames.profileCreate, extra: profile);
        },
      );
    });
  }
}

class _CharactersTile extends StatelessWidget {
  const _CharactersTile({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final profile = injector.get<ProfileSessionState>().activeProfile.value;
      final hasProfile = profile != null;
      final isSelected = currentRoute == AppPaths.characters;
      final colorScheme = Theme.of(context).colorScheme;

      return ListTile(
        leading: Icon(
          Icons.people,
          color: !hasProfile
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
              : isSelected
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          'Personagens',
          style: !hasProfile
              ? TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5))
              : TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.secondary : colorScheme.onSurface,
                ),
        ),
        selected: isSelected && hasProfile,
        onTap: hasProfile
            ? () {
                if (isSelected) return;
                context.pop();
                context.goNamed(
                  AppRouteNames.characters,
                  extra: profile,
                );
              }
            : null,
      );
    });
  }
}

class _SwitchProfileTile extends StatelessWidget {
  const _SwitchProfileTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.switch_account,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        'Trocar de Perfil',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      onTap: () {
        context.pop();
        injector.get<ProfileSessionState>().clearActiveProfile();
        context.goNamed(AppRouteNames.profileSelection);
      },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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

        await injector.get<AuthViewModel>().commands.signOut();
      },
    );
  }
}