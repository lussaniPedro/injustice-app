import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/failure/failure.dart';
import '../../../core/patterns/result.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../domain/models/auth_entities.dart';
import '../services/remote/i_auth_service.dart';
import 'i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _authService;
  AuthRepositoryImpl(this._authService);

  @override
  AuthSession? get currentSession => _authService.currentSession;

  @override
  Signal<AuthSession?> get sessionSignal => _authService.currentSessionSignal;

  @override
  Future<AuthSessionResult> signIn(String email, String password) async {
    try {
      return Success(await _authService.signIn(email, password));
    } on fb.FirebaseAuthException catch(e){
      return Error(DefaultFailure(_mapFirebaseError(e.code)));
    } catch(e){
      return Error(DefaultFailure(e.toString()));
    }
  }

  @override
  Future<AuthSessionResult> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      return Success(await _authService.signUp(name: name, email: email, password: password));
    } on fb.FirebaseAuthException catch(e){
      return Error(DefaultFailure(_mapFirebaseError(e.code)));
    } catch(e){
      return Error(DefaultFailure(e.toString()));
    }
  }

  @override
  Future<AuthSessionResult> signInWithGoogle() async {
    try {
      return Success(await _authService.signInWithGoogle());
    } catch(e){
      return Error(DefaultFailure('Falha ao autenticar com Google: $e'));
    }
  }

  @override
  Future<VoidResult> signOut() async {
    try {
      await _authService.signOut();
      return const Success(null);
    } catch(e){
      return Error(DefaultFailure(e.toString()));
    }
  }

  String _mapFirebaseError(String code){
    switch(code){
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }
}