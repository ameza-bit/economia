import 'package:economia/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static RouterConfig<Object>? getGoRoutes(GlobalKey<NavigatorState> navigatorKey) {
    List<RouteBase> routes = [GoRoute(path: "/", builder: (context, state) => HomeScreen())];

    return GoRouter(
      navigatorKey: navigatorKey,
      routes: routes,
      errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString(), maxLines: 5))),
    );
  }
}
