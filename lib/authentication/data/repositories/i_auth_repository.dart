import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../domain/models/auth_entities.dart';

abstract interface class IAuthRepository {
  AuthSession? get currentSession;
  Signal<AuthSession?> get sessionSignal;

  Future<AuthSessionResult> signIn(String email, String password);
  Future<AuthSessionResult> signUp({String? name, required String email, required String password});
  Future<AuthSessionResult> signInWithGoogle();
  Future<VoidResult> signOut();
}