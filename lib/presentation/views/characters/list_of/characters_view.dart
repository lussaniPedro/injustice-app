import 'package:flutter/material.dart';
import 'widgets/characters_app_bar.dart';
import 'widgets/characters_body.dart';
import 'widgets/characters_floating_button.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/models/profile_entity.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../widgets/app_drawer.dart';

/// Página de listagem de personagens
class CharactersView extends StatefulWidget {
  final Profile profile;

  const CharactersView({super.key, required this.profile});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  late final CharactersViewModel _viewModel;
  Profile get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchCharacters();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CharactersAppBar(state: _viewModel.charactersState, commands: _viewModel.commands,),
      drawer: AppDrawer(),
      body: CharactersBody(profile: profile, viewModel: _viewModel),
      floatingActionButton: CharactersFab(viewModel: _viewModel),
    );
  }
}