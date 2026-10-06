// lib/features/about/presentation/pages/about_page.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Jogo'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroIcon(),
            const SizedBox(height: AppSpacing.xl),
            _InfoCard(
              title: 'Descrição',
              content:
                  'Um jogo épico de RPG onde você controla heróis poderosos, '
                  'explora mundos fantásticos e enfrenta desafios emocionantes. '
                  'Personalize seus personagens, desenvolva habilidades únicas e '
                  'embarque em uma jornada inesquecível.',
              icon: Icons.description,
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(
              title: 'Recursos',
              content:
                  '• Sistema de combate estratégico\n'
                  '• Mais de 50 personagens únicos\n'
                  '• Mundos vastos para explorar\n'
                  '• Sistema de progressão profundo\n'
                  '• Modo multiplayer cooperativo\n'
                  '• Eventos semanais exclusivos',
              icon: Icons.featured_play_list,
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(
              title: 'Versão',
              content: '1.0.0',
              icon: Icons.code,
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(
              title: 'Desenvolvedores',
              content: 'Team Prof. Roberto',
              icon: Icons.people_alt,
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SupportButton(),
          ],
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.secondary.withValues(alpha: 0.15),
              colorScheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.videogame_asset,
          size: 80,
          color: colorScheme.secondary,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: FilledButton.icon(
        onPressed: () => _showSupportSnackbar(context),
        icon: const Icon(Icons.help_outline),
        label: const Text('Ajuda e Suporte'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }

  void _showSupportSnackbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Função em desenvolvimento'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: colorScheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}