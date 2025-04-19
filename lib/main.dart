import 'package:economia/core/observers/simple_bloc_observer.dart';
import 'package:economia/core/routes/app_routes.dart';
import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/ui/themes/main_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  Bloc.observer = SimpleBlocObserver();

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
      ],
      child: MaterialApp.router(
        title: 'EconoMía',
        routerConfig: AppRoutes.getGoRoutes(navigatorKey),
        theme: MainTheme.lightTheme,
      ),
    );
  }
}
