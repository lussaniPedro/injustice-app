import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/presentation/controllers/auth_viewmodel.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/profile_entity.dart';
import '../../controllers/profile_session_state.dart';
import '../../controllers/profiles_viewmodel.dart';
import '../../functions/ui_functions.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/theme_toggle_button.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ProfileSelectionView extends StatefulWidget {
  const ProfileSelectionView({super.key});

  @override
  State<ProfileSelectionView> createState() => _ProfileSelectionViewState();
}

class _ProfileSelectionViewState extends State<ProfileSelectionView> {
  late final ProfilesViewModel _vmProfiles;
  late final ProfileSessionState _profileSession;
  late final AuthViewModel _vmAuth;

  @override
  void initState() {
    super.initState();
    _vmProfiles = injector.get<ProfilesViewModel>();
    _profileSession = injector.get<ProfileSessionState>();
    _vmAuth = injector.get<AuthViewModel>();
    _vmProfiles.commands.fetchProfiles();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
            onPressed: _logout,
          ),
        ],
      ),
      body: Watch((context) {
        final isLoading =
            _vmProfiles.commands.getAllProfilesCommand.isExecuting.value;
        final profiles = _vmProfiles.profilesState.state.value;

        if (isLoading) {
          return const Center(
            child: LoadingIndicator(message: 'Carregando perfis...'),
          );
        }

        return SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quem está jogando?',
                style: context.textStyles.headlineSmall?.bold,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profiles.isEmpty
                    ? 'Crie seu primeiro perfil para começar'
                    : 'Selecione um perfil para continuar',
                style: context.textStyles.bodyMedium?.withColor(
                  colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              for (final profile in profiles) ...[
                _ProfileRow(
                  profile: profile,
                  onTap: () => _selectProfile(profile),
                  onEdit: () => _goToEditProfile(profile),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              if (profiles.length < 4) ...[
                const SizedBox(height: AppSpacing.sm),
                _AddProfileRow(onTap: _goToCreateProfile),
              ],

              if (profiles.length >= 4) ...[
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    'Limite de 4 perfis atingido',
                    style: context.textStyles.bodySmall?.withColor(
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ProfileRow({
    required this.profile,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorScheme.secondary, colorScheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: context.textStyles.titleMedium?.semiBold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nível ${profile.level}',
                      style: context.textStyles.bodySmall?.withColor(
                        colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant, size: 20),
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

class _AddProfileRow extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
              style: BorderStyle.solid,
            ),
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
                child: Icon(Icons.add, color: colorScheme.secondary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Adicionar Perfil',
                  style: context.textStyles.titleMedium?.semiBold.withColor(
                    colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}