import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../controllers/account_viewmodel.dart';
import '../widgets/app_drawer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AccountViewModel _vmAccount;
  late final ThemeController _themeController;

  @override
  void initState(){
    super.initState();
    _vmAccount = injector.get<AccountViewModel>();
    _themeController = injector.get<ThemeController>();
    _vmAccount.commands.fetchAccount();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inj2 Mobile - Player Acc'),
        actions: [
          Watch((context){
            return IconButton(
              icon: Icon(
                _themeController.isLightMode.value
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: (){
                _themeController.toggleTheme();
              },
              tooltip: _themeController.isLightMode.value
                  ? 'Modo Escuro'
                  : 'Modo Claro',
            );
          }),
        ],
      ),
      drawer: AppDrawer(),
      body: Watch((context){
       
        if(_vmAccount.commands.getAccountCommand.isExecuting.value){
          return const Center(child: CircularProgressIndicator());
        }
       
        if(!_vmAccount.accountState.hasAccount.value){
          return _buildAboutContent(context);
        }

        return _accountHeaderCard(context);
      }),
    );
  }

  Widget _buildAboutContent(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videogame_asset,
                size: 80,
                color: colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Bem-vindo ao\nInj2 Mobile',
              style: context.textStyles.headlineMedium?.bold,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'Sua aventura épica em RPG está prestes a começar.',
              style: context.textStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoSection(
            titulo: 'Descrição',
            conteudo:
                'Um jogo épico de RPG onde você controla heróis poderosos, '
                'explora mundos fantásticos e enfrenta desafios emocionantes. '
                'Personalize seus personagens, desenvolva habilidades únicas e '
                'embarque em uma jornada inesquecível.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoSection(
            titulo: 'Recursos',
            conteudo:
                '• Sistema de combate estratégico\n'
                '• Mais de 50 personagens únicos\n'
                '• Mundos vastos para explorar\n'
                '• Sistema de progressão profundo\n'
                '• Modo multiplayer cooperativo\n'
                '• Eventos semanais exclusivos',
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.accountCreate),
              icon: const Icon(Icons.person_add),
              label: const Text('Criar Conta Agora'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountHeaderCard(BuildContext context){
    final account = _vmAccount.accountState.state.value!;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => await _vmAccount.commands.fetchAccount(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(account, colorScheme),
            const SizedBox(height: AppSpacing.xl),

            _buildResourcesSection(account, colorScheme),
            const SizedBox(height: AppSpacing.xl),

            _buildAccountInfoSection(account, colorScheme),
            const SizedBox(height: AppSpacing.xl),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.goNamed(
                  AppRouteNames.characters,
                  extra: account,
                ),
                icon: const Icon(Icons.people),
                label: const Text('Ver Meus Personagens'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic account, ColorScheme colorScheme){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary,
            colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    account.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
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
                      account.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Nível ${account.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(dynamic account, ColorScheme colorScheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recursos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModernResourceCard(
                icon: Icons.diamond,
                label: 'Gemas',
                value: account.gems.toString(),
                color: Colors.cyanAccent,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModernResourceCard(
                icon: Icons.flash_on,
                label: 'Energia',
                value: account.energy.toString(),
                color: Colors.greenAccent,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ModernResourceCard(
          icon: Icons.monetization_on,
          label: 'Gold',
          value: NumberFormat.currency(
            locale: 'pt_BR',
            symbol: r'$ ',
            decimalDigits: 2,
          ).format(account.gold),
          color: Colors.amberAccent,
          isGoldCard: true,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildAccountInfoSection(dynamic account, ColorScheme colorScheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações da Conta',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        _ModernInfoCard(
          icon: Icons.calendar_today,
          label: 'Data de Criação',
          value: DateFormat('dd/MM/yyyy').format(account.createdAt),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _ModernResourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isGoldCard;
  final ColorScheme colorScheme;

  const _ModernResourceCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isGoldCard = false,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isGoldCard ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isGoldCard ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          if(isGoldCard)
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGoldCard ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _ModernInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const _InfoSection({required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            conteudo,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}