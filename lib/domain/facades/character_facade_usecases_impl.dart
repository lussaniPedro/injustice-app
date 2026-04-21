import '../../core/typedefs/types_defs.dart';
import '../usecases/character_usecases_interfaces.dart';
import 'character_facade_usecases_interface.dart';

/// implementacao do [ICharacterFacadeUseCases]
/// para chamar os usecases relacionados a Character

final class CharacterFacadeUseCasesImpl implements ICharacterFacadeUseCases {
  final IGetAllCharactersUseCase _getAllCharactersUseCase;
  final IGetCharacterByIdUseCase _getCharacterByIdUseCase;
  final ISaveCharacterUseCase _saveCharacterUseCase;
  final IUpdateCharacterUseCase _updateCharacterUseCase;
  final IDeleteCharacterUseCase _deleteCharacterUseCase;
  final IDeleteAllCharactersUseCase _deleteAllCharactersUseCase;

  CharacterFacadeUseCasesImpl({
    required IGetAllCharactersUseCase getAllCharactersUseCase,
    required IGetCharacterByIdUseCase getCharacterByIdUseCase,
    required ISaveCharacterUseCase saveCharacterUseCase,
    required IUpdateCharacterUseCase updateCharacterUseCase,
    required IDeleteCharacterUseCase deleteCharacterUseCase,
    required IDeleteAllCharactersUseCase deleteAllCharactersUseCase,
  }) : _getAllCharactersUseCase = getAllCharactersUseCase,
       _getCharacterByIdUseCase = getCharacterByIdUseCase,
       _saveCharacterUseCase = saveCharacterUseCase,
       _updateCharacterUseCase = updateCharacterUseCase,
       _deleteCharacterUseCase = deleteCharacterUseCase,
       _deleteAllCharactersUseCase = deleteAllCharactersUseCase;

  @override
  Future<ListCharacterResult> getAllCharacters(NoParams params){
    return _getAllCharactersUseCase(params);
  }

  @override
  Future<CharacterResult> getCharacterById(CharacterIdParams params){
    return _getCharacterByIdUseCase(params);
  }

  @override
  Future<CharacterResult> saveCharacter(CharacterParams params){
    return _saveCharacterUseCase(params);
  }

  @override
  Future<CharacterResult> updateCharacter(CharacterParams params){
    return _updateCharacterUseCase(params);
  }

  @override
  Future<CharacterResult> deleteCharacter(CharacterIdParams params){
    return _deleteCharacterUseCase(params);
  }

  @override
  Future<VoidResult> deleteAllCharacters(NoParams params){
    return _deleteAllCharactersUseCase(params);
  }
}
