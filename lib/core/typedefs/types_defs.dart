import 'package:flutter/material.dart';
import '../failure/failure.dart';
import '../../authentication/domain/models/auth_entities.dart';
import '../../domain/models/profile_entity.dart';
import '../../domain/models/character_entity.dart';

import '../patterns/result.dart';

// typedefs de sessão
typedef AuthSessionResult = Result<AuthSession, Failure>;
typedef SignInParams = ({String email, String password});
typedef SignUpParams = ({String? name, String email, String password});

// typedefs para tipo Result
typedef VoidResult = Result<void, Failure>;
typedef ListProfileResult = Result<List<Profile>, Failure>;
typedef ProfileResult = Result<Profile, Failure>;
typedef CharacterResult = Result<Character,Failure>;
typedef ListCharacterResult = Result<List<Character>, Failure>;

// typedfs para parâmetros
typedef ProfileIdParams = ({String id});
typedef ProfileParams = ({Profile profile});

/// tipos usadoos Conta de Usuario
typedef NoParams = ();
typedef ProfileNameParams = ({String profileName});
/// tipos usados para Personagem
typedef CharacterIdParams = ({String id});
typedef CharacterParams = ({Character character});

/// typedefs para ser usados em componentes de UI
typedef FormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});
