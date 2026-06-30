import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/auth_entities.dart';
import 'i_local_session_store.dart';

class SharedPrefLocalSessionService implements ILocalSessionStore {
  static const _key = 'injustice.auth.session.v1';

  @override
  Future<void> save(SessionToken? token) async {
    final prefs = await SharedPreferences.getInstance();

    if(token == null){
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, jsonEncode(token.toJson()));
    }
  }

  @override
  Future<SessionToken?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if(raw == null) return null;

    try {
      return SessionToken.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch(_){
      return null;
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}