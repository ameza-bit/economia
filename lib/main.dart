import 'package:economia/routes/app_routes.dart';
import 'package:economia/themes/main_theme.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sonofy',
      routerConfig: AppRoutes.getGoRoutes(navigatorKey),
      theme: MainTheme.lightTheme,
    );
  }
}
