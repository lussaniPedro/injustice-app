import 'package:equatable/equatable.dart';

/// Usuário autenticado
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

/// Token de acesso  e validade
class AuthToken extends Equatable {
  final String value;
  final DateTime expiresAt;

  const AuthToken({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [value, expiresAt];
}

/// Sessão completa: Usuário + token
class AuthSession extends Equatable {
  final AuthUser user;
  final AuthToken token;

  const AuthSession({required this.user, required this.token});

  bool get isValid => !token.isExpired;

  @override
  List<Object?> get props => [user, token];
}

/// Origem do login: email/senha ou Google
enum AuthProvider {
  emailPassword,
  google;

  String get name => toString().split('.').last;

  static AuthProvider fromString(String value){
    return AuthProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuthProvider.emailPassword,
    );
  }
}

class SessionToken extends Equatable {
  final String uid;
  final String value;
  final String? name;
  final String? email;
  final DateTime expiresAt;
  final AuthProvider provider;

  const SessionToken({
    required this.uid,
    required this.value,
    required this.expiresAt,
    required this.provider,
    this.name,
    this.email,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'value': value,
        'name': name,
        'email': email,
        'expiresAt': expiresAt.toIso8601String(),
        'provider': provider.name,
      };

  factory SessionToken.fromJson(Map<String, dynamic> json) => SessionToken(
        uid: json['uid'] as String,
        value: json['value'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        provider: AuthProvider.fromString(json['provider'] as String? ?? 'emailPassword'),
      );

  @override
  List<Object?> get props => [uid, value, expiresAt, provider];
}