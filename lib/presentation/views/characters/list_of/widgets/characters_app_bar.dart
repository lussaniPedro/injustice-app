import 'package:flutter/material.dart';
import 'package:injustice_app/presentation/controllers/characters_commands_view_model.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../controllers/characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CharactersStateViewmodel state;
  final CharactersCommandsViewModel commands;

  const CharactersAppBar({super.key, required this.state, required this.commands});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Personagens'),
      actions: [
        _DeleteAllButton(state: state, commands: commands),
        _SortOrderButton(state: state),
        _SortByButton(state: state),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DeleteAllButton extends StatelessWidget {
  final CharactersStateViewmodel state;
  final CharactersCommandsViewModel commands;

  const _DeleteAllButton({required this.state, required this.commands});

  @override
  Widget build(BuildContext context){
    return Watch((context){
      return IconButton(
        icon: Icon(Icons.delete, color: Colors.red.shade400),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                title: Text(
                  'Confirmar exclusão',
                  style: context.textStyles.titleMedium?.bold,
                ),
                content: Text(
                  'Tem certeza que deseja deletar todos os personagens?',
                  style: context.textStyles.bodyMedium,
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Deletar',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();

                      final hasCharacters = state.state.isNotEmpty;

                      if(!hasCharacters){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Não há personagens para deletar',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        );

                        return;
                      }

                      commands.deleteAllCharactersCommand();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }
}

class _SortOrderButton extends StatelessWidget {
  final CharactersStateViewmodel state;

  const _SortOrderButton({required this.state});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final order = state.sortOrder.value;

      return IconButton(
        icon: Icon(
          order == SortOrder.ascending
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: state.toggleSortOrder,
        tooltip: order == SortOrder.ascending ? 'Ascendente' : 'Descendente',
      );
    });
  }
}

class _SortByButton extends StatelessWidget {
  final CharactersStateViewmodel state;

  const _SortByButton({required this.state});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final currentSort = state.sortBy.value;

      return PopupMenuButton<SortBy>(
        icon: Icon(Icons.sort, color: Theme.of(context).colorScheme.primary),
        tooltip: 'Ordenar',
        onSelected: state.setSortBy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: SortBy.name,
            child: Row(
              children: [
                Icon(
                  Icons.sort_by_alpha,
                  color: currentSort == SortBy.name 
                      ? Theme.of(context).colorScheme.secondary 
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Nome',
                  style: currentSort == SortBy.name
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: SortBy.level,
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: currentSort == SortBy.level 
                      ? Theme.of(context).colorScheme.secondary 
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Level',
                  style: currentSort == SortBy.level
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: SortBy.stars,
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: currentSort == SortBy.stars 
                      ? Theme.of(context).colorScheme.secondary 
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Estrelas',
                  style: currentSort == SortBy.stars
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}