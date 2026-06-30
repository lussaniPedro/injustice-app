import '../../../domain/models/auth_entities.dart';

abstract interface class ILocalSessionStore {
  Future<void> save(SessionToken? token);
  Future<SessionToken?> read();
  Future<void> clear();
}