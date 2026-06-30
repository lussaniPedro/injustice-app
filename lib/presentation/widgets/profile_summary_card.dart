import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/profile_entity.dart';

class ProfileSummaryCard extends StatelessWidget {
  final Profile profile;

  const ProfileSummaryCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context){
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.secondary, colors.primary],
          ),
        ),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.displayName,
                      style: context.textStyles.headlineSmall
                          ?.bold
                          .withColor(colors.onSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Lv. ${profile.level}',
                      style: context.textStyles.labelLarge
                          ?.bold
                          .withColor(colors.onSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.bolt,
                    label: 'Energia',
                    value: profile.energy.toString(),
                    color: Colors.greenAccent,
                  ),
                  _StatItem(
                    icon: Icons.diamond,
                    label: 'Gemas',
                    value: profile.gems.toString(),
                    color: Colors.cyanAccent,
                  ),
                  _StatItem(
                    icon: Icons.attach_money,
                    label: 'Gold',
                    value: profile.gold.toStringAsFixed(0),
                    color: Colors.amberAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context){
    final textColor = Theme.of(context).colorScheme.onSecondary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textStyles.titleMedium?.semiBold.withColor(textColor),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall?.withColor(textColor.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}