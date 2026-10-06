import 'dart:convert';

import '../../authentication/data/services/remote/i_auth_service.dart';
import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import '../../presentation/controllers/profile_session_state.dart';
import 'character_local_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/patterns/result.dart';

final class CharacterSharedPreferencesService implements ICharacterLocalStorage {
  final IAuthService _authService;
  final ProfileSessionState _profileSession;

  CharacterSharedPreferencesService({
    required IAuthService authService,
    required ProfileSessionState profileSession,
  })  : _authService = authService,
        _profileSession = profileSession;

  String? get _storageKey {
    final uid = _authService.currentSession?.user.id;
    final profileId = _profileSession.activeProfile.value?.id;

    if (uid == null || profileId == null) {
      return null;
    }

    return 'characters_${uid}_$profileId';
  }

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final result = await getAllCharacters();

      return result.fold(
        onSuccess: (characters) async {
          final character = characters.firstWhere((c) => c.id == id);

          await _saveCharacters(characters.where((c) => c.id != id).toList());

          return Success(character);
        },
        onFailure: (err){
          return Error(err);
        }
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao deletar personagem: $e')
      );
    }
  }

  @override
  Future<VoidResult> deleteAllCharacters() async {
    try {
      final key = _storageKey;
      if (key == null) {
        return Error(DefaultFailure('Nenhum perfil ativo ou usuário autenticado.'));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);

      return Success(null);
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao deletar personagens: $e')
      );
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final key = _storageKey;
      if (key == null) {
        return Error(DefaultFailure('Nenhum perfil ativo ou usuário autenticado.'));
      }

      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(key);

      if(result == null || result.isEmpty){
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final result = await getAllCharacters();

      return result.fold(
        onSuccess: (characters){
          final character = characters.firstWhere(
            (c) => c.id == id,
            orElse: () => throw Exception('Personagem nao encontrado'),
          );

          return Success(character);
        },
        onFailure: (err){
          return Error(err);
        }
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if(failure is EmptyResultFailure){
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure());
        },
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      final result = await getAllCharacters();

      return await result.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((c) => c.id == character.id);

          if(index == -1){
            throw Exception('Personagem nao encontrado');
          }

          final updatedCharacters = [...characters];
          updatedCharacters[index] = character;

          await _saveCharacters(updatedCharacters);

          return Success(character);
        },
        onFailure: (err) => Error(err),
      );
    } catch(e){
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao editar personagem: $e'),
      );
    }
  }

  Future<void> _saveCharacters(List<Character> characters) async {
    final key = _storageKey;
    if (key == null) {
      throw ApiLocalFailure('Nenhum perfil ativo ou usuário autenticado.');
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );

      await prefs.setString(key, jsonString);
    } catch(e){
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}
