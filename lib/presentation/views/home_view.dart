import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/profile_entity.dart';
import '../controllers/profile_session_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/theme_toggle_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ProfileSessionState _profileSession;

  @override
  void initState(){
    super.initState();
    _profileSession = injector.get<ProfileSessionState>();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Injustice Mobile'),
        actions: const [ThemeToggleButton()],
      ),
      drawer: AppDrawer(),
      body: Watch((context){
        final profile = _profileSession.activeProfile.value;

        if(profile == null){
          return const Center(child: CircularProgressIndicator());
        }

        return _profileHeaderCard(context, profile);
      }),
    );
  }

  Widget _profileHeaderCard(BuildContext context, Profile profile){
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile, colorScheme),
          const SizedBox(height: AppSpacing.xl),

          _buildResourcesSection(profile, colorScheme),
          const SizedBox(height: AppSpacing.xl),

          _buildProfileInfoSection(profile, colorScheme),
          const SizedBox(height: AppSpacing.xl),

          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.goNamed(
                AppRouteNames.characters,
                extra: profile,
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
    );
  }

  Widget _buildProfileHeader(Profile profile, ColorScheme colorScheme){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondary, colorScheme.primary],
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
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    profile.displayName[0].toUpperCase(),
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
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
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
                  'Nível ${profile.level}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(Profile profile, ColorScheme colorScheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recursos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ResourceCard(
                icon: Icons.diamond,
                label: 'Gemas',
                value: profile.gems.toString(),
                color: Colors.cyanAccent,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ResourceCard(
                icon: Icons.flash_on,
                label: 'Energia',
                value: profile.energy.toString(),
                color: Colors.greenAccent,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ResourceCard(
          icon: Icons.monetization_on,
          label: 'Gold',
          value: NumberFormat.currency(
            locale: 'pt_BR',
            symbol: r'$ ',
            decimalDigits: 2,
          ).format(profile.gold),
          color: Colors.amberAccent,
          isGoldCard: true,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection(Profile profile, ColorScheme colorScheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informações do Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.calendar_today, color: colorScheme.secondary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data de Criação',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(profile.createdAt),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isGoldCard;
  final ColorScheme colorScheme;

  const _ResourceCard({
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
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 2, spreadRadius: 1)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: isGoldCard ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          if(isGoldCard)
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.md),
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            )
          else
            Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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