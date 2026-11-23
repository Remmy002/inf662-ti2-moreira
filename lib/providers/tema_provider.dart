import 'package:flutter/material.dart';

class TemaProvider extends ChangeNotifier {
  bool _oscuro = false;

  bool get oscuro => _oscuro;
  ThemeMode get modo => _oscuro ? ThemeMode.dark : ThemeMode.light;

  void alternar() {
    _oscuro = !_oscuro;
    notifyListeners();
  }
}
