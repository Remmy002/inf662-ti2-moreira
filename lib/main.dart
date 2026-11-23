import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ejercicio_provider.dart';
import 'providers/rutina_provider.dart';
import 'providers/tema_provider.dart';
import 'screens/pantalla_rutinas.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RutinaProvider()),
        ChangeNotifierProvider(create: (_) => EjercicioProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()),
      ],
      child: const GymApp(),
    ),
  );
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modo = context.watch<TemaProvider>().modo;
    return MaterialApp(
      title: 'Gym Rutinas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: modo,
      home: const PantallaRutinas(),
    );
  }
}
