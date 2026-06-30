import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/character_entity.dart';
import '../commands/character_commands.dart';
import 'characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersCommandsViewModel {
  final CharactersStateViewmodel state;
  final GetAllCharactersCommand _getProfileCommand;
  final CreateCharacterCommand _createCharacterCommand;
  final UpdateCharacterCommand _updateCharacterCommand;
  final DeleteCharacterCommand _deleteCharacterCommand;
  final DeleteAllCharactersCommand _deleteAllCharactersCommand;

  CharactersCommandsViewModel({
    required this.state,
    required GetAllCharactersCommand getProfileCommand,
    required CreateCharacterCommand createCharacterCommand,
    required UpdateCharacterCommand updateCharacterCommand,
    required DeleteCharacterCommand deleteCharacterCommand,
    required DeleteAllCharactersCommand deleteAllCharactersCommand,
  }) : _getProfileCommand = getProfileCommand,
       _createCharacterCommand = createCharacterCommand,
       _updateCharacterCommand = updateCharacterCommand,
       _deleteCharacterCommand = deleteCharacterCommand,
       _deleteAllCharactersCommand = deleteAllCharactersCommand {
    // Observers para cada comando
    _observeGetAllCharacters();
    _observeCreateCharacter();
    _observeUpdateCharacter();
    _observeDeleteCharacter();
    _observeDeleteAllCharacters();
  }

  // ========================================================
  //   GETTERS PARA WIDGETS USAREM DIRETAMENTE OS COMANDOS
  // ========================================================
  GetAllCharactersCommand get getAllCharactersCommand => _getProfileCommand;
  CreateCharacterCommand get createCharacterCommand => _createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => _updateCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand => _deleteCharacterCommand;
  DeleteAllCharactersCommand get deleteAllCharactersCommand => _deleteAllCharactersCommand;

  // ========================================================
  //   MÉTODO GENÉRICO DE OBSERVAÇÃO DE COMANDOS
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }){
    effect((){
      // 1) Ignora enquanto está executando
      if (command.isExecuting.value) return;

      // 2) Ignora até existir um resultado
      final result = command.result.value;
      if (result == null) return;

      // 3) Sucesso ou falha
      result.fold(
        onSuccess: (data){
          state.clearMessage(); // sempre limpa erros em sucesso
          onSuccess(data); // ação específica para esse comando
          command.clear();
        },
        onFailure: (err){
          state.setMessage(err.msg); // registra o erro no estado
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS ESPECÍFICOS
  // ========================================================

  /// Buscar todos os personagens
  void _observeGetAllCharacters(){
    _observeCommand<List<Character>>(
      _getProfileCommand,
      onSuccess: (characters){
        state.clearMessage(); // Limpa mensagens anteriores
        state.state.value = characters;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }
  /// Criar um novo personagem
  void _observeCreateCharacter(){  
    _observeCommand<Character>(
      _createCharacterCommand,
      onSuccess: (newCharacter){
        final currentList = state.state.value;
        final newlist = [...currentList, newCharacter]; // Adiciona o novo personagem à lista

        state.state.value = newlist;

        state.successEvent.value = CharacterSuccessEvent.created;
        state.clearMessage();
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  void _observeUpdateCharacter(){
    _observeCommand<Character>(
      _updateCharacterCommand,
      onSuccess: (updatedCharacter){
        final currentList = state.state.value;

        final index = currentList.indexWhere((c) => c.id == updatedCharacter.id);

        if(index == -1){
          state.setMessage('Personagem não encontrado na lista');
          return;
        }

        final updatedList = [...currentList];
        updatedList[index] = updatedCharacter;

        state.state.value = updatedList;

        state.successEvent.value = CharacterSuccessEvent.updated;
        state.clearMessage();
      },
      onFailure: (err) => state.setMessage(err.msg),
    );
  }

  void _observeDeleteCharacter(){
    _observeCommand<Character>(
      _deleteCharacterCommand,
      onSuccess: (character){
        final currentList = state.state.value;

        final updatedList = currentList.where((c) => c.id != character.id).toList();

        state.state.value = updatedList;

        state.successEvent.value = CharacterSuccessEvent.deleted;
        state.clearMessage();
      },
      onFailure: (err) => state.setMessage(err.msg),
    );
  }

  void _observeDeleteAllCharacters(){
    _observeCommand<void>(
      _deleteAllCharactersCommand,
      onSuccess: (_){
        state.state.value = [];

        state.successEvent.value = CharacterSuccessEvent.deleted;
        state.clearMessage();
      },
      onFailure: (err) =>
        state.setMessage(err.msg),
    );
  }

  // ========================================================
  //   MÉTODOS PÚBLICOS (CHAMADOS PELOS WIDGETS)
  //   que disparam os commands
  // ========================================================
  /// buscca personagens e atualiza o estado
  Future<void> fetchCharacters() async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _getProfileCommand.executeWith(());
  }

  /// adiciona personagem e atualiza o estado
  Future<void> addCharacter(Character character) async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _createCharacterCommand.executeWith((character: character));
  }

  Future<void> updateCharacter(Character character) async {
    state.clearMessage();
    await _updateCharacterCommand.executeWith((character: character));
  }

  Future<void> deleteCharacter(String id) async {
    state.clearMessage();
    await _deleteCharacterCommand.executeWith((id: id));
  }
}
