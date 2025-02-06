// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/configs/routes.dart' as custom_route;
import 'package:vending_standalone/src/models/users/user_local_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatefulWidget {
  final UserLocal? userData;
  const App({super.key, required this.userData});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: widget.userData == null ? '/login' : '/home',
      routes: custom_route.Routes.getAll(),
      title: 'Vending Machine',
      theme: MaterialTheme.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
    );
  }
}
