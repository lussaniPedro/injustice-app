import '../../../domain/models/auth_entities.dart';
import 'i_local_session_store.dart';

class AuthLocalSessionManager {
  final ILocalSessionStore store;
  AuthLocalSessionManager(this.store);

  Future<void> setToken(SessionToken? token) => store.save(token);

  Future<SessionToken?> getValidToken() async {
    final token = await store.read();

    if (token == null) return null;
    if (token.isExpired) return null;

    return token;
  }

  Future<void> clear() => store.clear();
}