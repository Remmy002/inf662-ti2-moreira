import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/ejercicio.dart';

class EjercicioProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instancia;

  List<Ejercicio> _ejercicios = [];
  int? _rutinaId;
  bool _cargando = false;
  String? _error;
  String _busqueda = '';

  List<Ejercicio> get ejercicios => List.unmodifiable(_ejercicios);
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarPorRutina(int rutinaId) async {
    if (_rutinaId != rutinaId) _busqueda = '';
    _rutinaId = rutinaId;
    await _recargar(mostrarCarga: true);
  }

  Future<void> buscar(String texto) async {
    _busqueda = texto.trim();
    await _recargar(mostrarCarga: false);
  }

  Future<void> _recargar({required bool mostrarCarga}) async {
    final id = _rutinaId;
    if (id == null) return;
    if (mostrarCarga) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      _ejercicios = await _db.obtenerEjercicios(id, busqueda: _busqueda);
      _error = null;
    } catch (e) {
      _error = 'No se pudieron cargar los ejercicios';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<String?> guardar(Ejercicio ejercicio) async {
    try {
      if (ejercicio.id == null) {
        await _db.insertarEjercicio(ejercicio);
      } else {
        await _db.actualizarEjercicio(ejercicio);
      }
      await _recargar(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo guardar el ejercicio';
    }
  }

  Future<String?> eliminar(int id) async {
    try {
      await _db.eliminarEjercicio(id);
      await _recargar(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo eliminar el ejercicio';
    }
  }
}
