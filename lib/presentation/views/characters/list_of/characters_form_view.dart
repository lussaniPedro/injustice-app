import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/presentation/widgets/app_drawer.dart';
import 'package:injustice_app/presentation/widgets/character_attribute_card.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/typedefs/types_defs.dart';
import '../../../../core/validators/empty_str_validator.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../../domain/models/extensions/character_ui.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../functions/ui_functions.dart';
import '../../../widgets/input_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharacterFormView extends StatefulWidget {
  final Character? character;

  const CharacterFormView({super.key, this.character});

  @override
  State<CharacterFormView> createState() => _CharacterFormViewState();
}

class _CharacterFormViewState extends State<CharacterFormView> {
  late final CharactersViewModel _vmCharacter;
  late final void Function() _disposeErrorEffect;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final CharacterFormFieldsController _fields;

  CharacterClass _class = CharacterClass.poderoso;
  CharacterRarity _rarity = CharacterRarity.prata;
  CharacterAlignment _alignment = CharacterAlignment.heroi;

  int _level = 1;
  int _stars = 1;
  int _attack = 0;
  int _health = 0;
  int _threat = 0;

  @override
  void initState(){
    super.initState();

    _fields = CharacterFormFieldsController();
    _vmCharacter = injector.get<CharactersViewModel>();

    _vmCharacter.charactersState.clearMessage();

    if(widget.character != null){
      _fill(widget.character!);
    }

    _disposeErrorEffect = effect((){
      final msg = _vmCharacter.charactersState.message.value;

      if(msg != null && mounted){
        WidgetsBinding.instance.addPostFrameCallback((_){
          showSnackBar(context, msg, backgroundColor: Colors.red);
          _vmCharacter.charactersState.clearMessage();
        });
      }
    });
  }

  void _fill(Character c){
    _fields.name.controller.text = c.name;
    _class = c.characterClass;
    _rarity = c.rarity;
    _alignment = c.alignment;
    _level = c.level;
    _stars = c.stars;
    _attack = c.attack;
    _health = c.health;
    _threat = c.threat;
  }

  @override
  void dispose(){
    _disposeErrorEffect();
    _scrollController.dispose();
    _fields.dispose();
    super.dispose();
  }

  bool _validate(){
    final valid = _formKey.currentState!.validate();

    if(!valid){
      _fields.name.focus.requestFocus();
    }

    return valid;
  }

  Future<void> _save() async {
    if(!_validate()) return;

    final now = DateTime.now();

    final character = Character(
      id: widget.character?.id ?? now.toIso8601String(),
      name: _fields.name.controller.text.trim(),
      characterClass: _class,
      rarity: _rarity,
      level: _level,
      threat: _threat,
      attack: _attack,
      health: _health,
      stars: _stars,
      alignment: _alignment,
      createdAt: widget.character?.createdAt ?? now,
      updatedAt: now,
    );

    if(widget.character == null){
      await _vmCharacter.commands.addCharacter(character);
    } else {
      await _vmCharacter.commands.updateCharacter(character);
    }

    if(mounted) context.pop();
  }

  Future<void> _delete() async {
    if(widget.character == null) return;

    final confirm = await confirmDialog(
      context,
      title: 'Excluir personagem',
      message: 'Deseja realmente excluir ${widget.character!.name}?',
      confirmText: 'EXCLUIR',
    );

    if(!confirm) return;

    await _vmCharacter.commands.deleteCharacter(widget.character!.id);

    if(mounted) context.pop();
  }

  @override
  Widget build(BuildContext context){
    final isEdit = widget.character != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Personagem' : 'Criar Personagem'),
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
                  child: Icon(
                    Icons.person_add_alt_1,
                    size: 64,
                    color: colorScheme.secondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                InputTextField(
                  fieldKey: _fields.name.key,
                  controller: _fields.name.controller,
                  focusNode: _fields.name.focus,
                  label: 'Nome',
                  validator: (v) =>
                      validateField(v, [EmptyStrValidator()]),
                ),

                const SizedBox(height: AppSpacing.md),

                DropdownMenu<CharacterClass>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _class,
                  label: const Text('Classe'),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  onSelected: (value){
                    if(value != null){
                      setState(() => _class = value);
                    }
                  },
                  dropdownMenuEntries: CharacterClass.values
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e.displayName,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: e.color,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                DropdownMenu<CharacterRarity>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _rarity,
                  label: const Text('Raridade'),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  onSelected: (value){
                    if(value != null){
                      setState(() => _rarity = value);
                    }
                  },
                  dropdownMenuEntries: CharacterRarity.values
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e.displayName,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: e.color,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                DropdownMenu<CharacterAlignment>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _alignment,
                  label: const Text('Alinhamento'),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  onSelected: (value){
                    if(value != null){
                      setState(() => _alignment = value);
                    }
                  },
                  dropdownMenuEntries: CharacterAlignment.values
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e.displayName,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                CharacterAttributeCard(
                  icon: Icons.trending_up,
                  iconColor: Colors.blue,
                  label: 'Level',
                  hint: '[1 - 80]',
                  value: _level,
                  minValue: 1,
                  maxValue: 80,
                  onChanged: (v) => setState(() => _level = v),
                ),

                CharacterAttributeCard(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  label: 'Stars',
                  hint: '[1 - 14]',
                  value: _stars,
                  minValue: 1,
                  maxValue: 14,
                  onChanged: (v) => setState(() => _stars = v),
                ),

                CharacterAttributeCard(
                  icon: Icons.flash_on,
                  iconColor: Colors.red,
                  label: 'Attack',
                  hint: 'Min: 0',
                  value: _attack,
                  minValue: 0,
                  maxValue: 99999,
                  onChanged: (v) => setState(() => _attack = v),
                ),

                CharacterAttributeCard(
                  icon: Icons.favorite,
                  iconColor: Colors.green,
                  label: 'Health',
                  hint: 'Min: 0',
                  value: _health,
                  minValue: 0,
                  maxValue: 99999,
                  onChanged: (v) => setState(() => _health = v),
                ),

                CharacterAttributeCard(
                  icon: Icons.warning,
                  iconColor: colorScheme.secondary,
                  label: 'Threat',
                  hint: 'Min: 0',
                  value: _threat,
                  minValue: 0,
                  maxValue: 99999,
                  onChanged: (v) => setState(() => _threat = v),
                ),

                const SizedBox(height: AppSpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: Watch((_){
                        final isRunning =
                            _vmCharacter.commands.createCharacterCommand.isExecuting.value ||
                            _vmCharacter.commands.updateCharacterCommand.isExecuting.value;

                        return SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isRunning ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: isRunning
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isEdit ? 'ATUALIZAR' : 'CRIAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    if(isEdit)
                      Expanded(
                        child: Watch((_){
                          final isDeleting = _vmCharacter
                              .commands
                              .deleteCharacterCommand
                              .isExecuting
                              .value;
                                                  
                          return SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isDeleting ? null : _delete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: isDeleting
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                    'EXCLUIR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          );
                        }),
                      )
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CharacterFormFieldsController {
  final FormFieldControl name = _create();

  List<FormFieldControl> get fields => [name];

  static FormFieldControl _create(){
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void dispose(){
    for(final f in fields){
      f.focus.dispose();
      f.controller.dispose();
    }
  }
}