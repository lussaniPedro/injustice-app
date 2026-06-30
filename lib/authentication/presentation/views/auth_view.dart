import 'package:flutter/material.dart';
import 'package:injustice_app/presentation/widgets/theme_toggle_button.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../../core/validators/email_str_validator.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../core/validators/passwor_full_validator.dart';
import '../../../presentation/functions/ui_functions.dart';
import '../../../presentation/widgets/input_text_field.dart';
import '../controllers/auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final AuthViewModel _vmAuth;
  late final void Function() _disposeErrorEffect;

  final _formKey = GlobalKey<FormState>();

  final _nameControl = _createField();
  final _emailControl = _createField();
  final _passwordControl = _createField();

  bool _isSignUpMode = false;

  static FormFieldControl _createField() => (
        key: GlobalKey<FormFieldState>(),
        focus: FocusNode(),
        controller: TextEditingController(),
      );

  @override
  void initState(){
    super.initState();
    _vmAuth = injector.get<AuthViewModel>();
    _vmAuth.session.clearMessage();

    _disposeErrorEffect = effect((){
      final msg = _vmAuth.session.message.value;

      if(msg != null && mounted){
        WidgetsBinding.instance.addPostFrameCallback((_){
          if(!mounted) return;
          showSnackBar(context, msg, backgroundColor: Colors.red);
          _vmAuth.session.clearMessage();
        });
      }
    });
  }

  @override
  void dispose(){
    _disposeErrorEffect();
    _nameControl.controller.dispose();
    _nameControl.focus.dispose();
    _emailControl.controller.dispose();
    _emailControl.focus.dispose();
    _passwordControl.controller.dispose();
    _passwordControl.focus.dispose();
    super.dispose();
  }

  void _toggleMode(){
    setState(() => _isSignUpMode = !_isSignUpMode);
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;

    final email = _emailControl.controller.text.trim();
    final password = _passwordControl.controller.text.trim();

    if(_isSignUpMode){
      final name = _nameControl.controller.text.trim();
      await _vmAuth.commands.signUp(name: name, email: email, password: password);
    } else {
      await _vmAuth.commands.signIn(email, password);
    }
    // O redirect do GoRouter cuida de navegar pra próxima tela
    // assim que a sessão ficar autenticada (ver Parte 3).
  }

  Future<void> _submitGoogle() async {
    await _vmAuth.commands.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: AppSpacing.paddingLg,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondary.withValues(alpha: 0.1),
                          colorScheme.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.videogame_asset, size: 64, color: colorScheme.secondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isSignUpMode ? 'Criar Conta' : 'Bem-vindo de volta',
                    style: context.textStyles.headlineSmall?.bold,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isSignUpMode
                        ? 'Preencha os dados para se cadastrar'
                        : 'Entre com sua conta para continuar',
                    style: context.textStyles.bodyMedium?.withColor(
                      colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if(_isSignUpMode) ...[
                    InputTextField(
                      fieldKey: _nameControl.key,
                      controller: _nameControl.controller,
                      focusNode: _nameControl.focus,
                      label: 'Nome',
                      prefixIcon: Icons.person,
                      validator: (v) => validateField(v, [EmptyStrValidator()]),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  InputTextField(
                    fieldKey: _emailControl.key,
                    controller: _emailControl.controller,
                    focusNode: _emailControl.focus,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => validateField(v, [
                      EmptyStrValidator(),
                      EmailStrValidator(),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  InputTextField(
                    fieldKey: _passwordControl.key,
                    controller: _passwordControl.controller,
                    focusNode: _passwordControl.focus,
                    label: 'Senha',
                    prefixIcon: Icons.lock,
                    validator: (v) => validateField(v, [PassworFullValidator()]),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Watch((_){
                    final isRunning =
                        _vmAuth.commands.signInCommand.isExecuting.value ||
                        _vmAuth.commands.signUpCommand.isExecuting.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isRunning ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: isRunning
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isSignUpMode ? 'CADASTRAR' : 'ENTRAR',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text('ou', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Watch((_){
                    final isRunning =
                        _vmAuth.commands.signInWithGoogleCommand.isExecuting.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isRunning ? null : _submitGoogle,
                        icon: isRunning
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Continuar com Google'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.lg),

                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      _isSignUpMode
                          ? 'Já tem conta? Entrar'
                          : 'Não tem conta? Cadastre-se',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}