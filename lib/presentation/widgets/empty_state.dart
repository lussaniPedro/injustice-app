import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  /// Presets

  const EmptyState.noCharacters({super.key})
      : icon = Icons.people_outline,
        title = 'Nenhum personagem encontrado',
        description = 'Adicione seu primeiro personagem usando o botão +',
        action = null;

  factory EmptyState.error({VoidCallback? onRetry}){
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Algo deu errado',
      description: 'Tente novamente mais tarde',
      action: onRetry != null
          ? ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(onRetry as BuildContext).colorScheme.secondary,
              ),
              child: const Text('Tentar novamente'),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 72, color: colorScheme.secondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.withColor(
                colorScheme.onSurfaceVariant,
              ),
            ),
            if(action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}