import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/typedefs/types_defs.dart';
import '../../../../core/validators/email_str_validator.dart';
import '../../../../core/validators/empty_str_validator.dart';
import '../../../../domain/models/profile_entity.dart';
import '../../controllers/profiles_state_viewmodel.dart';
import '../../controllers/profiles_viewmodel.dart';
import '../../functions/ui_functions.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/date_wheel_picker.dart';
import '../../widgets/input_text_field.dart';
import '../../widgets/profile_attribute_card.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Página de criação/edição de perfil
class ProfileCreateView extends StatefulWidget {
  final Profile? profile;

  const ProfileCreateView({super.key, required this.profile});

  @override
  State<ProfileCreateView> createState() => _ProfileCreateViewState();
}

class _ProfileCreateViewState extends State<ProfileCreateView> {
  late final ProfilesViewModel _vmProfiles;
  late final void Function() _disposeErrorEffect;
  late final void Function() _disposeSuccessEffect;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final ProfileFormFieldsController _formFields;

  bool get _isEditing => widget.profile != null;

  DateTime _createdAt = DateTime.now();
  int _level = 1;
  double _gold = 0;
  int _gems = 0;
  int _energy = 1;

  @override
  void initState(){
    super.initState();
    _formFields = ProfileFormFieldsController();

    _vmProfiles = injector.get<ProfilesViewModel>();
    _vmProfiles.profilesState.clearMessage();
    _vmProfiles.profilesState.clearSuccessEvent();

    if(_isEditing){
      _preencherCampos(widget.profile!);
    }

    _disposeErrorEffect = effect((){
      final errorMessage = _vmProfiles.profilesState.message.value;

      if(errorMessage != null && mounted){
        WidgetsBinding.instance.addPostFrameCallback((_){
          if(!mounted) return;

          showSnackBar(context, errorMessage, backgroundColor: Colors.red);

          _vmProfiles.profilesState.clearMessage();
        });
      }
    });

    _disposeSuccessEffect = effect((){
      final event = _vmProfiles.profilesState.successEvent.value;

      if(event != null && mounted){
        WidgetsBinding.instance.addPostFrameCallback((_){
          if(!mounted) return;

          String message;
          Color color;

          switch (event){
            case ProfileSuccessEvent.created:
              message = 'Perfil criado com sucesso!';
              color = Colors.green;

            case ProfileSuccessEvent.updated:
              message = 'Perfil atualizado com sucesso!';
              color = Colors.green;

            case ProfileSuccessEvent.deleted:
              message = 'Perfil excluído com sucesso!';
              color = Colors.red.shade400;
          }

          showSnackBar(context, message, backgroundColor: color);

          _vmProfiles.profilesState.clearSuccessEvent();

          if(mounted) context.pop();
        });
      }
    });
  }

  @override
  void dispose(){
    _disposeErrorEffect();
    _disposeSuccessEffect();

    _scrollController.dispose();
    _formFields.dispose();

    super.dispose();
  }

  void _preencherCampos(Profile profile){
    _formFields.email.controller.text = profile.email;
    _formFields.name.controller.text = profile.name;
    _formFields.displayName.controller.text = profile.displayName;

    _createdAt = profile.createdAt;
    _level = profile.level;
    _gold = profile.gold;
    _gems = profile.gems;
    _energy = profile.energy;
  }

  void _resetFormView(){
    FocusScope.of(context).unfocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _focusFirstError(){
    for(final field in _formFields.fields){
      final state = field.key.currentState;

      if(state != null && !state.isValid){
        field.focus.requestFocus();

        Scrollable.ensureVisible(
          field.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        break;
      }
    }
  }

  bool _validateForm(){
    final valid = _formKey.currentState!.validate();

    if(!valid){
      _focusFirstError();
    }

    return valid;
  }

  Future<void> _salvarPerfil() async {
    if(!_validateForm()) return;

    final now = DateTime.now();

    final newProfile = Profile(
      id: _isEditing ? widget.profile!.id : const Uuid().v4(),
      email: _formFields.email.controller.text.trim(),
      name: _formFields.name.controller.text.trim(),
      displayName: _formFields.displayName.controller.text.trim(),
      createdAt: _isEditing ? widget.profile!.createdAt : _createdAt,
      updatedAt: now,
      level: _level,
      gold: _gold,
      gems: _gems,
      energy: _energy,
    );

    if(_isEditing){
      await _vmProfiles.commands.updateProfile(newProfile);
    } else {
      await _vmProfiles.commands.createProfile(newProfile);
    }

    _resetFormView();
  }

  Future<void> _excluirPerfil() async {
    if(!_isEditing) return;

    final confirm = await confirmDialog(
      context,
      title: 'Excluir perfil',
      message:
          'Tem certeza que deseja excluir o perfil "${widget.profile!.displayName}"?\n\n'
          'Esta ação não poderá ser desfeita.',
      confirmText: 'EXCLUIR',
    );

    if(!confirm) return;

    await _vmProfiles.commands.deleteProfile(widget.profile!.id);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Perfil' : 'Criar Perfil'),
      ),
      drawer: AppDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _isEditing
                      ? 'Atualize os dados do perfil'
                      : 'Preencha os dados abaixo para criar seu perfil',
                  style: context.textStyles.bodyMedium?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                InputTextField(
                  fieldKey: _formFields.email.key,
                  controller: _formFields.email.controller,
                  focusNode: _formFields.email.focus,
                  label: 'Email',
                  hint: 'Digite seu e-mail',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validateField(value, [
                    EmptyStrValidator(),
                    EmailStrValidator(),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),

                InputTextField(
                  fieldKey: _formFields.name.key,
                  controller: _formFields.name.controller,
                  focusNode: _formFields.name.focus,
                  prefixIcon: Icons.account_circle,
                  label: 'Nome',
                  hint: 'Digite seu nome',
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
                ),
                const SizedBox(height: AppSpacing.md),

                InputTextField(
                  label: 'Apelido',
                  fieldKey: _formFields.displayName.key,
                  controller: _formFields.displayName.controller,
                  focusNode: _formFields.displayName.focus,
                  prefixIcon: Icons.verified_user,
                  hint: 'Digite seu apelido',
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
                ),
                const SizedBox(height: AppSpacing.md),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DateWheelPicker(
                    label: 'Data de Criação',
                    selectedDate: _createdAt,
                    onDateSelected: (date) => setState(() => _createdAt = date),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                ProfileAttributeCard(
                  icon: Icons.star,
                  iconColor: Theme.of(context).colorScheme.secondary,
                  label: 'Nível',
                  hint: '[1, 80]',
                  minValue: 1,
                  maxValue: 80,
                  value: _level,
                  onChanged: (value) => setState(() => _level = value),
                ),
                const SizedBox(height: 1),

                ProfileAttributeCard(
                  icon: Icons.monetization_on,
                  iconColor: Colors.amber,
                  label: 'Ouro',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _gold.toInt(),
                  onChanged: (value) =>
                      setState(() => _gold = value.toDouble()),
                ),
                const SizedBox(height: 1),

                ProfileAttributeCard(
                  icon: Icons.diamond,
                  iconColor: Colors.cyan,
                  label: 'Gemas',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _gems,
                  onChanged: (value) => setState(() => _gems = value),
                ),
                const SizedBox(height: 1),

                ProfileAttributeCard(
                  icon: Icons.bolt,
                  iconColor: Colors.orange,
                  label: 'Energia',
                  hint: 'Min: 1',
                  minValue: 1,
                  maxValue: 999999,
                  value: _energy,
                  onChanged: (value) => setState(() => _energy = value),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: Watch((context){
                        final isRunning =
                            _vmProfiles.commands.createProfileCommand.isExecuting.value ||
                            _vmProfiles.commands.updateProfileCommand.isExecuting.value;

                        return ElevatedButton(
                          onPressed: isRunning ? null : _salvarPerfil,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: isRunning
                                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: isRunning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isEditing ? 'SALVAR' : 'CRIAR',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      }),
                    ),

                    if(_isEditing) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Watch((_){
                          final isDeleting =
                              _vmProfiles.commands.deleteProfileCommand.isExecuting.value;
                          final isSaving =
                              _vmProfiles.commands.createProfileCommand.isExecuting.value;
                          final isUpdating =
                              _vmProfiles.commands.updateProfileCommand.isExecuting.value;

                          final isBusy = isDeleting || isSaving || isUpdating;

                          return ElevatedButton(
                            onPressed: isBusy ? null : _excluirPerfil,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: isDeleting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'EXCLUIR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileFormFieldsController {
  final FormFieldControl email = _createField();
  final FormFieldControl name = _createField();
  final FormFieldControl displayName = _createField();

  List<FormFieldControl> get fields => [email, name, displayName];

  static FormFieldControl _createField(){
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void dispose(){
    for(final field in fields){
      field.focus.dispose();
      field.controller.dispose();
    }
  }
}