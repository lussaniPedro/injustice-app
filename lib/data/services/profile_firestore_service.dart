import 'package:cloud_firestore/cloud_firestore.dart';

import '../../authentication/data/services/remote/i_auth_service.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/profile_entity.dart';
import '../../domain/models/profile_mapper.dart';
import 'profile_local_storage_interface.dart';

final class ProfileFirestoreService implements IProfileLocalStorage {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;

  ProfileFirestoreService({
    FirebaseFirestore? firestore,
    required IAuthService authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  String? get _uid => _authService.currentSession?.user.id;

  CollectionReference<Map<String, dynamic>>? get _profilesCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('profiles');
  }

  @override
  Future<ListProfileResult> getAllProfiles() async {
    try {
      final collection = _profilesCollection;
      if (collection == null) return Error(DefaultFailure('Usuário não autenticado.'));

      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) return Error(EmptyResultFailure());

      final profiles = snapshot.docs
          .map((doc) => ProfileMapper.fromMap(doc.data()))
          .toList();

      return Success(profiles);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter perfis: $e'));
    }
  }

  @override
  Future<ProfileResult> getProfileById(String id) async {
    try {
      final collection = _profilesCollection;
      if (collection == null) return Error(DefaultFailure('Usuário não autenticado.'));

      final doc = await collection.doc(id).get();

      if (!doc.exists || doc.data() == null) return Error(EmptyResultFailure());

      return Success(ProfileMapper.fromMap(doc.data()!));
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao obter perfil: $e'));
    }
  }

  @override
  Future<ProfileResult> saveProfile(Profile profile) async {
    try {
      final collection = _profilesCollection;
      if (collection == null) return Error(DefaultFailure('Usuário não autenticado.'));

      await collection.doc(profile.id).set(ProfileMapper.toMap(profile));
      return Success(profile);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao salvar perfil: $e'));
    }
  }

  @override
  Future<ProfileResult> updateProfile(Profile profile) => saveProfile(profile);

  @override
  Future<VoidResult> deleteProfile(String id) async {
    try {
      final collection = _profilesCollection;
      if (collection == null) return Error(DefaultFailure('Usuário não autenticado.'));

      await collection.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('Firestore - Erro ao deletar perfil: $e'));
    }
  }
}