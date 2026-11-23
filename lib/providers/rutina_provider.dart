import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/resumen_rutina.dart';
import '../models/rutina.dart';

class RutinaProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instancia;

  List<Rutina> _rutinas = [];
  List<ResumenRutina> _resumen = [];
  bool _cargando = false;
  String? _error;
  String _busqueda = '';

  List<Rutina> get rutinas => List.unmodifiable(_rutinas);
  List<ResumenRutina> get resumen => List.unmodifiable(_resumen);
  bool get cargando => _cargando;
  String? get error => _error;
  String get busqueda => _busqueda;

  Future<void> cargar({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      _rutinas = await _db.obtenerRutinas(busqueda: _busqueda);
      _error = null;
    } catch (e) {
      _error = 'No se pudieron cargar las rutinas';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> buscar(String texto) async {
    _busqueda = texto.trim();
    await cargar(mostrarCarga: false);
  }

  Future<void> cargarResumen() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _resumen = await _db.obtenerResumen();
    } catch (e) {
      _error = 'No se pudo cargar el resumen';
    }
    _cargando = false;
    notifyListeners();
  }

  /// Devuelve null si todo salió bien, o el mensaje de error.
  Future<String?> guardar(Rutina rutina) async {
    try {
      if (rutina.id == null) {
        await _db.insertarRutina(rutina);
      } else {
        await _db.actualizarRutina(rutina);
      }
      await cargar(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo guardar la rutina';
    }
  }

  Future<String?> eliminar(int id) async {
    try {
      await _db.eliminarRutina(id);
      await cargar(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo eliminar la rutina';
    }
  }
}
