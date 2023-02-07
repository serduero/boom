import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:buscaminas/2clases/visualizacion.dart';
import 'package:buscaminas/5providers/zproviders.dart';
import 'package:buscaminas/9screens/zscreens.dart';

void main() async {
  // Cargamos variables de entorno antes de lanzar la App
  WidgetsFlutterBinding.ensureInitialized();
  await variablesEntorno.loadPrefs(); // Ejecuta init  + loadprefs

  runApp(const BuscaminasApp());
}

class BuscaminasApp extends StatelessWidget {
  const BuscaminasApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateManager = ManejadorApp();
    final buscaminas = BuscaminasProv();
    final multiminasProv = MultiminasProv();
    final contadorProv = ContadorProv();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (final _) => appStateManager),
        ChangeNotifierProvider(create: (final _) => variablesEntorno),
        ChangeNotifierProvider(create: (final _) => buscaminas),
        ChangeNotifierProvider(create: (final _) => multiminasProv),
        ChangeNotifierProvider(create: (final _) => contadorProv),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        theme: BuscamTheme.tema(),
        builder: (final context, final child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!),
        supportedLocales: const [
          Locale('es'), // Castellano
          Locale('ca'), // Catalán
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: variablesEntorno.getEntornoApp.idioma == 0
            ? const Locale('ca')
            : const Locale('es'),
      ),
    );
  }
}
