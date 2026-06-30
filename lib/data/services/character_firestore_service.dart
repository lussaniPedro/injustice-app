import 'package:cloud_firestore/cloud_firestore.dart';

import '../../authentication/data/services/remote/i_auth_service.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import '../../presentation/controllers/profile_session_state.dart';
import 'character_local_storage_interface.dart';

final class CharacterFirestoreService implements ICharacterLocalStorage {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;
  final ProfileSessionState _profileSession;

  CharacterFirestoreService({
    FirebaseFirestore? firestore,
    required IAuthService authService,
    required ProfileSessionState profileSession,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService,
        _profileSession = profileSession;

  String? get _uid => _authService.currentSession?.user.id;
  String? get _profileId => _profileSession.activeProfile.value?.id;

  CollectionReference<Map<String, dynamic>>? get _charactersCollection {
    final uid = _uid;
    final profileId = _profileId;
    if (uid == null || profileId == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .collection('characters');
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final collection = _charactersCollection;
      if (collection == null) return Error(DefaultFailure('Nenhum perfil ativo.'));

      final snapshot = await collection.get();
      if (snapshot.docs.isEmpty) return Error(EmptyResultFailure());

      final characters = snapshot.docs
          .map((doc) => CharacterMapper.fromMap(doc.data()))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter personagens: $e'));
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final collection = _charactersCollection;
      if (collection == null) return Error(DefaultFailure('Nenhum perfil ativo.'));

      final doc = await collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return Error(EmptyResultFailure());

      return Success(CharacterMapper.fromMap(doc.data()!));
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final collection = _charactersCollection;
      if (collection == null) return Error(DefaultFailure('Nenhum perfil ativo.'));

      await collection.doc(character.id).set(CharacterMapper.toMap(character));
      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao salvar personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) => saveCharacter(character);

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final collection = _charactersCollection;
      if (collection == null) return Error(DefaultFailure('Nenhum perfil ativo.'));

      final doc = collection.doc(id);
      final snapshot = await doc.get();
      if (!snapshot.exists || snapshot.data() == null) return Error(EmptyResultFailure());

      final character = CharacterMapper.fromMap(snapshot.data()!);
      await doc.delete();

      return Success(character);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar personagem: $e'));
    }
  }

  @override
  Future<VoidResult> deleteAllCharacters() async {
    try {
      final collection = _charactersCollection;
      if (collection == null) return Error(DefaultFailure('Nenhum perfil ativo.'));

      final snapshot = await collection.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar personagens: $e'));
    }
  }
}