import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../domain/models/auth_entities.dart';
import '../local/auth_local_session_manager.dart';
import 'i_auth_service.dart';

class FirebaseAuthService implements IAuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final AuthLocalSessionManager _localSession;

  final Signal<AuthSession?> _currentSessionSignal = Signal<AuthSession?>(null);

  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    required AuthLocalSessionManager localSession,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _localSession = localSession;

  @override
  Signal<AuthSession?> get currentSessionSignal => _currentSessionSignal;

  @override
  AuthSession? get currentSession => _currentSessionSignal.value;

  // Login com email/senha
  @override
  Future<AuthSession> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = credential.user;

    if(fbUser == null){
      throw Exception('Usuário não encontrado após login.');
    }

    return _buildAndPersistSession(fbUser, provider: AuthProvider.emailPassword);
  }

  // Cadastro com email/senha
  @override
  Future<AuthSession> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = credential.user;

    if(fbUser == null){
      throw Exception('Falha ao criar usuário.');
    }

    if(name != null && name.isNotEmpty){
      await fbUser.updateDisplayName(name);
    }

    return _buildAndPersistSession(
      fbUser,
      provider: AuthProvider.emailPassword,
      overrideName: name,
    );
  }

  // Login com Google
  @override
  Future<AuthSession> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: "990828640118-f915pof199fhtr103anm2428sgflpdq9.apps.googleusercontent.com"
    );
    final googleUser = await googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final fbUser = userCredential.user;

    if(fbUser == null){
      throw Exception('Falha ao autenticar com Google.');
    }

    return _buildAndPersistSession(fbUser, provider: AuthProvider.google);
  }

  // Logout
  @override
  Future<void> signOut() async {
    await _localSession.clear();
    await _firebaseAuth.signOut();
    _currentSessionSignal.value = null;
  }

  // Restaurar sessão salva ao abrir o app
  @override
  Future<void> initSession() async {
    // Certifica que o estado de autenticação do Firebase foi carregado.
    await _firebaseAuth.authStateChanges().first;

    final fb.User? fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return;

    final tokenStr = await fbUser.getIdToken() ?? '';
    final tokenExp = DateTime.now().add(const Duration(hours: 1));
    final localToken = await _localSession.getValidToken();

    final session = AuthSession(
      user: AuthUser(
        id: fbUser.uid,
        name: fbUser.displayName ?? localToken?.name ?? '',
        email: fbUser.email ?? localToken?.email ?? '',
      ),
      token: AuthToken(value: tokenStr, expiresAt: tokenExp),
    );

    _currentSessionSignal.value = session;
    await _localSession.setToken(SessionToken(
      uid: session.user.id,
      name: session.user.name,
      email: session.user.email,
      value: tokenStr,
      expiresAt: tokenExp,
      provider: localToken?.provider ?? AuthProvider.emailPassword,
    ));
  }

  // Helper interno: monta a AuthSession e já salva localmente
  Future<AuthSession> _buildAndPersistSession(
    fb.User fbUser, {
    required AuthProvider provider,
    String? overrideName,
  }) async {
    final tokenStr = await fbUser.getIdToken() ?? '';
    final tokenExp = DateTime.now().add(const Duration(hours: 1));

    final session = AuthSession(
      user: AuthUser(
        id: fbUser.uid,
        name: overrideName ?? fbUser.displayName ?? '',
        email: fbUser.email ?? '',
      ),
      token: AuthToken(value: tokenStr, expiresAt: tokenExp),
    );

    await _localSession.setToken(SessionToken(
      uid: session.user.id,
      name: session.user.name,
      email: session.user.email,
      value: tokenStr,
      expiresAt: tokenExp,
      provider: provider,
    ));

    _currentSessionSignal.value = session;
    return session;
  }
}