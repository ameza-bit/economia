import 'package:economia/core/observers/simple_bloc_observer.dart';
import 'package:economia/core/routes/app_routes.dart';
import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/ui/themes/main_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  Bloc.observer = SimpleBlocObserver();

  initializeDateFormatting('es_MX', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CardBloc>(
          create:
              (context) =>
                  CardBloc(repository: CardRepository())..add(LoadCardEvent()),
        ),
        BlocProvider<ConceptBloc>(
          create:
              (context) =>
                  ConceptBloc(repository: ConceptRepository())
                    ..add(LoadConceptEvent()),
        ),
        BlocProvider<RecurringPaymentBloc>(
          create:
              (context) =>
                  RecurringPaymentBloc(repository: RecurringPaymentRepository())
                    ..add(LoadRecurringPaymentEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'EconoMía',
        routerConfig: AppRoutes.getGoRoutes(navigatorKey),
        theme: MainTheme.lightTheme,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('es', 'MX'), const Locale('en', 'US')],
        locale: const Locale('es', 'MX'),
      ),
    );
  }
}
