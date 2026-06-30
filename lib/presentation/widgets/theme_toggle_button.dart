import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context){
    final themeController = injector.get<ThemeController>();

    return Watch((context){
      return IconButton(
        icon: Icon(
          themeController.isLightMode.value ? Icons.dark_mode : Icons.light_mode,
        ),
        onPressed: themeController.toggleTheme,
        tooltip: themeController.isLightMode.value ? 'Modo Escuro' : 'Modo Claro',
      );
    });
  }
}