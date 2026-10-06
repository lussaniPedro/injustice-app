import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../authentication/presentation/controllers/auth_viewmodel.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/profile_entity.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../controllers/profile_session_state.dart';
import '../../controllers/profiles_viewmodel.dart';
import '../../widgets/profile_avatar.dart';

class ProfileSelectionView extends StatefulWidget {
  const ProfileSelectionView({super.key});

  @override
  State<ProfileSelectionView> createState() => _ProfileSelectionViewState();
}

class _ProfileSelectionViewState extends State<ProfileSelectionView> {
  final _vmProfiles = injector.get<ProfilesViewModel>();
  final _profileSession = injector.get<ProfileSessionState>();
  final _vmAuth = injector.get<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    _vmProfiles.commands.fetchProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _SelectionAppBar(),
      body: Watch((_) {
        final isLoading = _vmProfiles.commands.getAllProfilesCommand.isExecuting.value;
        final profiles = _vmProfiles.profilesState.state.value;

        if (isLoading) {
          return const _LoadingState();
        }

        return _ProfileList(profiles: profiles);
      }),
    );
  }

  void _selectProfile(Profile profile) {
    _profileSession.setActiveProfile(profile);
    context.goNamed(AppRouteNames.home);
  }

  void _goToCreateProfile() {
    context.pushNamed(AppRouteNames.profileCreate);
  }

  void _goToEditProfile(Profile profile) {
    context.pushNamed(AppRouteNames.profileCreate, extra: profile);
  }

  Future<void> _logout() async {
    final confirm = await confirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Tem certeza que deseja sair?',
      confirmText: 'SAIR',
      icon: Icons.logout,
    );

    if (!confirm) return;

    await _vmAuth.commands.signOut();
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Selecionar Perfil'),
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair da conta',
          onPressed: () => context.findAncestorStateOfType<_ProfileSelectionViewState>()?._logout(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Carregando perfis...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileList extends StatelessWidget {
  const _ProfileList({required this.profiles});

  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasReachedLimit = profiles.length >= 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(profileCount: profiles.length),
          const SizedBox(height: AppSpacing.xl),
          ...profiles.map(
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ProfileTile(
                profile: profile,
                onTap: () => _selectProfile(context, profile),
                onEdit: () => _editProfile(context, profile),
              ),
            ),
          ),
          if (!hasReachedLimit) ...[
            const SizedBox(height: AppSpacing.sm),
            _AddProfileTile(
              onTap: () => _createProfile(context),
            ),
          ],
          if (hasReachedLimit) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'Limite de 4 perfis atingido',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectProfile(BuildContext context, Profile profile) {
    context.findAncestorStateOfType<_ProfileSelectionViewState>()?._selectProfile(profile);
  }

  void _editProfile(BuildContext context, Profile profile) {
    context.findAncestorStateOfType<_ProfileSelectionViewState>()?._goToEditProfile(profile);
  }

  void _createProfile(BuildContext context) {
    context.findAncestorStateOfType<_ProfileSelectionViewState>()?._goToCreateProfile();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profileCount});

  final int profileCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quem está jogando?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profileCount == 0
              ? 'Crie seu primeiro perfil para começar'
              : 'Selecione um perfil para continuar',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.onTap,
    required this.onEdit,
  });

  final Profile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: colorScheme.secondary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              ProfileAvatar(
                displayName: profile.displayName,
                size: 56,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nível ${profile.level}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                tooltip: 'Editar perfil',
                onPressed: onEdit,
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.secondary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: colorScheme.secondary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
            color: colorScheme.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.add,
                  color: colorScheme.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Adicionar Perfil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}