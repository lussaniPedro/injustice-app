import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../../core/validators/email_str_validator.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../core/validators/passwor_full_validator.dart';
import '../../../presentation/functions/ui_functions.dart';
import '../../../presentation/widgets/input_text_field.dart';
import '../../../presentation/widgets/theme_toggle_button.dart';
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
  void initState() {
    super.initState();
    _vmAuth = injector.get<AuthViewModel>();
    _vmAuth.session.clearMessage();

    _disposeErrorEffect = effect(() {
      final msg = _vmAuth.session.message.value;

      if (msg != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSnackBar(context, msg, backgroundColor: Colors.red);
          _vmAuth.session.clearMessage();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeErrorEffect();
    _nameControl.controller.dispose();
    _nameControl.focus.dispose();
    _emailControl.controller.dispose();
    _emailControl.focus.dispose();
    _passwordControl.controller.dispose();
    _passwordControl.focus.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isSignUpMode = !_isSignUpMode);
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailControl.controller.text.trim();
    final password = _passwordControl.controller.text.trim();

    if (_isSignUpMode) {
      final name = _nameControl.controller.text.trim();
      await _vmAuth.commands.signUp(name: name, email: email, password: password);
    } else {
      await _vmAuth.commands.signIn(email, password);
    }
  }

  Future<void> _submitGoogle() async {
    await _vmAuth.commands.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Logo(colorScheme: colorScheme),
                  const SizedBox(height: AppSpacing.lg),
                  _Title(isSignUpMode: _isSignUpMode),
                  const SizedBox(height: AppSpacing.sm),
                  _Subtitle(isSignUpMode: _isSignUpMode, colorScheme: colorScheme),
                  const SizedBox(height: AppSpacing.xl),

                  if (_isSignUpMode) ...[
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

                  _SubmitButton(
                    isSignUpMode: _isSignUpMode,
                    vmAuth: _vmAuth,
                    onSubmit: _submit,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _DividerWithText(colorScheme: colorScheme),

                  const SizedBox(height: AppSpacing.md),

                  _GoogleButton(
                    vmAuth: _vmAuth,
                    onSubmit: _submitGoogle,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _ToggleModeButton(
                    isSignUpMode: _isSignUpMode,
                    onToggle: _toggleMode,
                    colorScheme: colorScheme,
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

class _Logo extends StatelessWidget {
  const _Logo({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(
        Icons.videogame_asset,
        size: 64,
        color: colorScheme.secondary,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.isSignUpMode});

  final bool isSignUpMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      isSignUpMode ? 'Criar Conta' : 'Bem-vindo de volta',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.isSignUpMode,
    required this.colorScheme,
  });

  final bool isSignUpMode;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      isSignUpMode
          ? 'Preencha os dados para se cadastrar'
          : 'Entre com sua conta para continuar',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isSignUpMode,
    required this.vmAuth,
    required this.onSubmit,
    required this.colorScheme,
  });

  final bool isSignUpMode;
  final AuthViewModel vmAuth;
  final VoidCallback onSubmit;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final isRunning = vmAuth.commands.signInCommand.isExecuting.value ||
          vmAuth.commands.signUpCommand.isExecuting.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isRunning ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 2,
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
                  isSignUpMode ? 'CADASTRAR' : 'ENTRAR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outline.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'ou',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outline.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.vmAuth,
    required this.onSubmit,
    required this.colorScheme,
  });

  final AuthViewModel vmAuth;
  final VoidCallback onSubmit;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final isRunning = vmAuth.commands.signInWithGoogleCommand.isExecuting.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: isRunning ? null : onSubmit,
          icon: isRunning
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.g_mobiledata, size: 28),
          label: const Text(
            'Continuar com Google',
            style: TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            foregroundColor: colorScheme.onSurface,
          ),
        ),
      );
    });
  }
}

class _ToggleModeButton extends StatelessWidget {
  const _ToggleModeButton({
    required this.isSignUpMode,
    required this.onToggle,
    required this.colorScheme,
  });

  final bool isSignUpMode;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onToggle,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.secondary,
      ),
      child: Text(
        isSignUpMode
            ? 'Já tem conta? Entrar'
            : 'Não tem conta? Cadastre-se',
        style: TextStyle(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }
}