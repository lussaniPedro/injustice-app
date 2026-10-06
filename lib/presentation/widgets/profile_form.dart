import 'package:flutter/material.dart';
import 'package:injustice_app/presentation/functions/ui_functions.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/validators/empty_str_validator.dart';
import '../../../domain/models/profile_entity.dart';
import 'date_wheel_picker.dart';
import 'input_text_field.dart';
import 'profile_attribute_card.dart';

class ProfileFormData {
  ProfileFormData({
    required this.name,
    required this.displayName,
    required this.createdAt,
    required this.level,
    required this.gold,
    required this.gems,
    required this.energy,
  });

  final String name;
  final String displayName;
  final DateTime createdAt;
  final int level;
  final int gold;
  final int gems;
  final int energy;
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    this.profile,
    required this.formKey,
    required this.onSave,
    required this.onDelete,
    required this.isEditing,
  });

  final Profile? profile;
  final GlobalKey<FormState> formKey;
  final Future<void> Function(ProfileFormData) onSave;
  final Future<void> Function() onDelete;
  final bool isEditing;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();

  DateTime _createdAt = DateTime.now();
  int _level = 1;
  int _gold = 0;
  int _gems = 0;
  int _energy = 1;

  final _nameFocus = FocusNode();
  final _displayNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _nameFocus.dispose();
    _displayNameFocus.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final profile = widget.profile;
    if (profile == null) return;

    _nameController.text = profile.name;
    _displayNameController.text = profile.displayName;
    _createdAt = profile.createdAt;
    _level = profile.level;
    _gold = profile.gold.toInt();
    _gems = profile.gems;
    _energy = profile.energy;
  }

  ProfileFormData get currentData => ProfileFormData(
        name: _nameController.text,
        displayName: _displayNameController.text,
        createdAt: _createdAt,
        level: _level,
        gold: _gold,
        gems: _gems,
        energy: _energy,
      );

  void _focusFirstError() {
    final fields = [
      (_nameController, _nameFocus),
      (_displayNameController, _displayNameFocus),
    ];

    for (final (controller, focus) in fields) {
      if (controller.text.isEmpty) {
        focus.requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InputTextField(
          controller: _nameController,
          focusNode: _nameFocus,
          prefixIcon: Icons.account_circle,
          label: 'Nome',
          hint: 'Digite seu nome',
          validator: (value) => validateField(value, [EmptyStrValidator()]),
          onFieldSubmitted: (_) => _displayNameFocus.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.md),
        InputTextField(
          controller: _displayNameController,
          focusNode: _displayNameFocus,
          prefixIcon: Icons.verified_user,
          label: 'Apelido',
          hint: 'Digite seu apelido',
          validator: (value) => validateField(value, [EmptyStrValidator()]),
          onFieldSubmitted: (_) => _focusFirstError(),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: DateWheelPicker(
            label: 'Data de Criação',
            selectedDate: _createdAt,
            onDateSelected: (date) => setState(() => _createdAt = date),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AttributeCard(
          icon: Icons.star,
          iconColor: colorScheme.secondary,
          label: 'Nível',
          hint: '[1, 80]',
          minValue: 1,
          maxValue: 80,
          value: _level,
          onChanged: (value) => setState(() => _level = value),
        ),
        const _CardDivider(),
        _AttributeCard(
          icon: Icons.monetization_on,
          iconColor: Colors.amber,
          label: 'Ouro',
          hint: 'Min: 0',
          minValue: 0,
          maxValue: 999999,
          value: _gold,
          onChanged: (value) => setState(() => _gold = value),
        ),
        const _CardDivider(),
        _AttributeCard(
          icon: Icons.diamond,
          iconColor: Colors.cyan,
          label: 'Gemas',
          hint: 'Min: 0',
          minValue: 0,
          maxValue: 999999,
          value: _gems,
          onChanged: (value) => setState(() => _gems = value),
        ),
        const _CardDivider(),
        _AttributeCard(
          icon: Icons.bolt,
          iconColor: Colors.orange,
          label: 'Energia',
          hint: 'Min: 1',
          minValue: 1,
          maxValue: 999999,
          value: _energy,
          onChanged: (value) => setState(() => _energy = value),
        ),
      ],
    );
  }
}

class _AttributeCard extends StatelessWidget {
  const _AttributeCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final int minValue;
  final int maxValue;
  final int value;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileAttributeCard(
      icon: icon,
      iconColor: iconColor,
      label: label,
      hint: hint,
      minValue: minValue,
      maxValue: maxValue,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 1);
  }
}