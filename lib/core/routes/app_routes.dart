import 'package:economia/data/models/financial_card.dart';
import 'package:economia/ui/screens/cards/card_form_screen.dart';
import 'package:economia/ui/screens/cards/card_list_screen.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/screens/concepts/concept_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static RouterConfig<Object>? getGoRoutes(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    List<RouteBase> routes = [
      GoRoute(
        path: "/",
        builder: (context, state) => const ConceptListScreen(),
        routes: [
          GoRoute(
            name: ConceptFormScreen.routeName,
            path: ConceptFormScreen.routeName,
            builder: (context, state) => const ConceptFormScreen(),
          ),
          GoRoute(
            name: CardListScreen.routeName,
            path: CardListScreen.routeName,
            builder: (context, state) => const CardListScreen(),
            routes: [
              GoRoute(
                name: CardFormScreen.routeName,
                path: CardFormScreen.routeName,
                builder: (context, state) {
                  // Obtener parámetros para edición si están presentes
                  final card =
                      state.extra is Map
                          ? (state.extra as Map)['card'] as FinancialCard?
                          : null;
                  final isEditing = card != null;

                  return CardFormScreen(card: card, isEditing: isEditing);
                },
              ),
            ],
          ),
        ],
      ),
    ];

    return GoRouter(
      navigatorKey: navigatorKey,
      routes: routes,
      errorBuilder:
          (context, state) => Scaffold(
            body: Center(child: Text(state.error.toString(), maxLines: 5)),
          ),
    );
  }
}
