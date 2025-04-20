import 'package:economia/data/models/concept.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/ui/screens/cards/card_form_screen.dart';
import 'package:economia/ui/screens/cards/card_list_screen.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/screens/concepts/concept_list_screen.dart';
import 'package:economia/ui/screens/recurring_payments/recurring_payment_form_screen.dart';
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
            builder: (context, state) {
              final concept = _getArgument<Concept>(state, 'concept');
              final isEditing = concept != null;

              return ConceptFormScreen(concept: concept, isEditing: isEditing);
            },
          ),
          GoRoute(
            name: RecurringPaymentFormScreen.routeName,
            path: RecurringPaymentFormScreen.routeName,
            builder: (context, state) {
              final payment = _getArgument<RecurringPayment>(state, 'payment');
              final isEditing = payment != null;

              return RecurringPaymentFormScreen(
                payment: payment,
                isEditing: isEditing,
              );
            },
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
                  final card = _getArgument<FinancialCard>(state, 'card');
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

  static T? _getArgument<T>(GoRouterState state, String name) {
    final extra = state.extra;
    if (extra is Map && extra.containsKey(name)) {
      return extra[name] as T;
    }
    return null;
  }
}
