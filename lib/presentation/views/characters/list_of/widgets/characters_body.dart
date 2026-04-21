import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/models/account_entity.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../../../../domain/models/extensions/character_ui.dart';
import '../../../../controllers/characters_state_viewmodel.dart';
import '../../../../controllers/characters_view_model.dart';
import '../../../../widgets/account_summary_card.dart';
import '../../../../widgets/empty_state.dart';
import '../../../../widgets/loading_indicator.dart';
import '../../../../widgets/star_rating.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersBody extends StatelessWidget {
  final CharactersViewModel viewModel;
  final Account account;

  const CharactersBody({
    super.key,
    required this.viewModel,
    required this.account,
  });

  @override
  Widget build(BuildContext context){
    return Watch((context){
      final isLoading =
          viewModel.commands.getAllCharactersCommand.isExecuting.value;
      final isDeleting =
        viewModel.commands.deleteCharacterCommand.isExecuting.value ||
        viewModel.commands.deleteAllCharactersCommand.isExecuting.value;

      final characters = viewModel.charactersState.sortedCharacters.value;

      return RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            /// Header
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: AccountSummaryCard(account: account),
              ),
            ),

            /// Filtros
            SliverToBoxAdapter(child: FilterPanel(viewModel: viewModel)),

            /// Conteúdo (loading | empty | lista)
            if(isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingIndicator(message: 'Carregando personagens...'),
              )
            else if(isDeleting)
              SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingIndicator(message: 'Deletando personagens...'),
              )
            else if(characters.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState.noCharacters(),
              )
            else
              SliverPadding(
                padding: AppSpacing.paddingMd,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index){
                    final character = characters[index];
                    return CharacterListItem(
                      character: character,
                      onDelete: () async {
                        await viewModel.commands.deleteCharacter(character.id);
                      },
                      onTap: (){
                        context.pushNamed(AppRouteNames.characterForm, extra: character);
                      },
                    );
                  }, childCount: characters.length),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Item da lista de personagens
class CharacterListItem extends StatelessWidget {
  final Character character;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CharacterListItem({
    super.key,
    required this.character,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return Dismissible(
      key: Key(character.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade700,
              Colors.red.shade900,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if(direction == DismissDirection.startToEnd){
          onTap();
          return false;
        } else {
          return await confirmDialog(
            context,
              title: 'Confirmar exclusão',
              message: 'Deseja realmente excluir ${character.name}?',
          );
        }
      },
      onDismissed: (direction){
        if(direction == DismissDirection.endToStart){
          onDelete();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  // Indicador de raridade
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: character.rarity.color,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: character.rarity.color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                character.name,
                                style: context.textStyles.titleMedium?.semiBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'Nv. ${character.level}',
                                style: context.textStyles.labelLarge?.withColor(
                                  Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              character.characterClass.icon,
                              size: 16,
                              color: character.characterClass.color,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              character.characterClass.displayName,
                              style: context.textStyles.bodySmall?.withColor(
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        StarRating(stars: character.stars, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final CharactersViewModel viewModel;

  const FilterPanel({super.key, required this.viewModel});

  CharactersStateViewmodel get state => viewModel.charactersState;

  @override
  Widget build(BuildContext context){
    return Watch((context){
      final filtersCount = state.activeFiltersCount.value;
      final isExpanded = state.isFilterPanelExpanded.value;

      return Container(
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.surfaceVariant,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabeçalho do painel
            InkWell(
              onTap: state.toggleFilterPanel,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Filtros',
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    if(filtersCount > 0) ...[
                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$filtersCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    if(filtersCount > 0)
                      TextButton.icon(
                        onPressed: state.clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Conteúdo do painel (expansível)
            if(isExpanded)
              SizedBox(
                width: double.infinity,
                child: _FiltersContent(state: state),
              ),
          ],
        ),
      );
    });
  }
}

class _FiltersContent extends StatelessWidget {
  const _FiltersContent({required this.state});

  final CharactersStateViewmodel state;

  @override
  Widget build(BuildContext context){
    return Watch((context){
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 RARIDADE
            _FilterSection(
              title: 'Raridade',
              sectionKey: 'rarity',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: CharacterRarity.values.map((rarity){
                  final isSelected = state.selectedRarities.value.contains(
                    rarity,
                  );

                  return FilterChip(
                    label: Text(
                      rarity.displayName,
                      style: TextStyle(
                        color: rarity.color,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => state.toggleRarity(rarity),
                    selectedColor: rarity.color.withValues(alpha: 0.2),
                    checkmarkColor: rarity.color,
                  );
                }).toList(),
              ),
            ),

            /// 🔹 CLASSE
            _FilterSection(
              title: 'Classe',
              sectionKey: 'class',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: CharacterClass.values.map((characterClass){
                  final isSelected = state.selectedClasses.value.contains(
                    characterClass,
                  );

                  return FilterChip(
                    label: Text(
                      characterClass.displayName,
                      style: TextStyle(
                        color: characterClass.color,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => state.toggleClass(characterClass),
                    selectedColor: characterClass.color.withValues(alpha: 0.2),
                    checkmarkColor: characterClass.color,
                  );
                }).toList(),
              ),
            ),

            /// 🔹 LEVEL
            _FilterSection(
              title: 'Level',
              sectionKey: 'level',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: LevelFilter.values.map((filter){
                  final isSelected = state.levelFilter.value == filter;
                  
                  return FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (_) => state.setLevelFilter(filter),
                    selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final String sectionKey;
  final CharactersStateViewmodel state;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.sectionKey,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context){
    return Watch((context){
      final isExpanded = state.isSectionExpanded(sectionKey);
      final selectedCount = switch (sectionKey){
        'rarity' => state.selectedRarities.value.length,
        'class' => state.selectedClasses.value.length,
        'alignment' => state.selectedAlignments.value.length,
        _ => 0,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => state.toggleSection(sectionKey),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    title,
                    style: context.textStyles.bodyMedium?.semiBold,
                  ),
                  if(selectedCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      );
    });
  }
}