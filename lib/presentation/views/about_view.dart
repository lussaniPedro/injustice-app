import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// Página de informações sobre o jogo
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Jogo')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.1),
                      colorScheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videogame_asset,
                  size: 80,
                  color: colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            InfoSection(
              titulo: 'Descrição',
              conteudo:
                  'Um jogo épico de RPG onde você controla heróis poderosos, '
                  'explora mundos fantásticos e enfrenta desafios emocionantes. '
                  'Personalize seus personagens, desenvolva habilidades únicas e '
                  'embarque em uma jornada inesquecível.',
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(
              titulo: 'Recursos',
              conteudo:
                  '• Sistema de combate estratégico\n'
                  '• Mais de 50 personagens únicos\n'
                  '• Mundos vastos para explorar\n'
                  '• Sistema de progressão profundo\n'
                  '• Modo multiplayer cooperativo\n'
                  '• Eventos semanais exclusivos',
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(titulo: 'Versão', conteudo: '1.0.0'),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(
              titulo: 'Desenvolvedores',
              conteudo: 'Team Prof. Roberto',
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Função em desenvolvimento'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      backgroundColor: colorScheme.secondary,
                    ),
                  );
                },
                icon: Icon(
                  Icons.help_outline,
                  color: colorScheme.secondary,
                ),
                label: Text(
                  'Ajuda e Suporte',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  side: BorderSide(color: colorScheme.secondary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const InfoSection({super.key, required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: context.textStyles.titleLarge?.semiBold.withColor(
            colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            conteudo,
            style: context.textStyles.bodyMedium?.withColor(
              colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}