import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'authentication/data/services/remote/i_auth_service.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart' as AppTheme;
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupDependencyInjection();

  final authService = injector.get<IAuthService>();
  await authService.initSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    final themeController = injector.get<ThemeController>();
    
    return Watch((context){
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Injustice App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        routerConfig: AppRouter.router,
        themeAnimationDuration: Duration.zero,
      );
    });
  }
}