import 'package:economia/core/routes/app_routes.dart';
import 'package:economia/core/services/preferences.dart';
import 'package:economia/ui/themes/main_theme.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EconoMía',
      routerConfig: AppRoutes.getGoRoutes(navigatorKey),
      theme: MainTheme.lightTheme,
    );
  }
}
