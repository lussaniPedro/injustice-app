import 'package:signals_flutter/signals_flutter.dart';
import '../../../domain/models/auth_entities.dart';

abstract interface class IAuthService {
  Signal<AuthSession?> get currentSessionSignal;

  AuthSession? get currentSession;

  Future<void> initSession();

  Future<AuthSession> signIn(String email, String password);
  Future<AuthSession> signUp({String? name, required String email, required String password});
  Future<AuthSession> signInWithGoogle();
  Future<void> signOut();
}