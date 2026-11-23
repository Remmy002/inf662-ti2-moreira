import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ejercicio.dart';
import '../models/resumen_rutina.dart';
import '../models/rutina.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instancia = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), 'gimnasio.db');
    return openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crear,
    );
  }

  Future<void> _crear(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rutinas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        dia TEXT NOT NULL,
        descripcion TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE ejercicios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rutina_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        series INTEGER NOT NULL,
        repeticiones INTEGER NOT NULL,
        peso REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (rutina_id) REFERENCES rutinas(id) ON DELETE CASCADE
      )
    ''');
    await _semilla(db);
  }

  Future<void> _semilla(Database db) async {
    final pecho = await db.insert('rutinas', {
      'nombre': 'Pecho y tríceps',
      'dia': 'Lunes',
      'descripcion': 'Fuerza de empuje',
    });
    final espalda = await db.insert('rutinas', {
      'nombre': 'Espalda y bíceps',
      'dia': 'Miércoles',
      'descripcion': 'Fuerza de tracción',
    });
    final pierna = await db.insert('rutinas', {
      'nombre': 'Pierna',
      'dia': 'Viernes',
      'descripcion': 'Tren inferior',
    });

    final ejercicios = [
      [pecho, 'Press de banca', 4, 10, 60.0],
      [pecho, 'Fondos', 3, 12, 0.0],
      [espalda, 'Dominadas', 4, 8, 0.0],
      [espalda, 'Remo con barra', 4, 10, 50.0],
      [pierna, 'Sentadilla', 5, 5, 80.0],
      [pierna, 'Prensa', 4, 12, 120.0],
    ];
    for (final e in ejercicios) {
      await db.insert('ejercicios', {
        'rutina_id': e[0],
        'nombre': e[1],
        'series': e[2],
        'repeticiones': e[3],
        'peso': e[4],
      });
    }
  }

  // ---------- RUTINAS ----------
  Future<List<Rutina>> obtenerRutinas({String busqueda = ''}) async {
    final db = await database;
    final filas = await db.query(
      'rutinas',
      where: busqueda.isEmpty ? null : 'nombre LIKE ?',
      whereArgs: busqueda.isEmpty ? null : ['%$busqueda%'],
      orderBy: 'nombre ASC',
    );
    return filas.map(Rutina.fromMap).toList();
  }

  Future<int> insertarRutina(Rutina rutina) async {
    final db = await database;
    return db.insert('rutinas', rutina.toMap());
  }

  Future<int> actualizarRutina(Rutina rutina) async {
    final db = await database;
    return db.update(
      'rutinas',
      rutina.toMap(),
      where: 'id = ?',
      whereArgs: [rutina.id],
    );
  }

  Future<int> eliminarRutina(int id) async {
    final db = await database;
    return db.delete('rutinas', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- EJERCICIOS ----------
  Future<List<Ejercicio>> obtenerEjercicios(
    int rutinaId, {
    String busqueda = '',
  }) async {
    final db = await database;
    final filas = await db.query(
      'ejercicios',
      where: busqueda.isEmpty
          ? 'rutina_id = ?'
          : 'rutina_id = ? AND nombre LIKE ?',
      whereArgs: busqueda.isEmpty ? [rutinaId] : [rutinaId, '%$busqueda%'],
      orderBy: 'id ASC',
    );
    return filas.map(Ejercicio.fromMap).toList();
  }

  Future<int> insertarEjercicio(Ejercicio ejercicio) async {
    final db = await database;
    return db.insert('ejercicios', ejercicio.toMap());
  }

  Future<int> actualizarEjercicio(Ejercicio ejercicio) async {
    final db = await database;
    return db.update(
      'ejercicios',
      ejercicio.toMap(),
      where: 'id = ?',
      whereArgs: [ejercicio.id],
    );
  }

  Future<int> eliminarEjercicio(int id) async {
    final db = await database;
    return db.delete('ejercicios', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- RESUMEN (agregación) ----------
  Future<List<ResumenRutina>> obtenerResumen() async {
    final db = await database;
    final filas = await db.rawQuery('''
      SELECT r.id, r.nombre,
             COUNT(e.id) AS total_ejercicios,
             COALESCE(SUM(e.series), 0) AS total_series,
             COALESCE(SUM(e.series * e.repeticiones * e.peso), 0) AS volumen
      FROM rutinas r
      LEFT JOIN ejercicios e ON e.rutina_id = r.id
      GROUP BY r.id, r.nombre
      ORDER BY volumen DESC
    ''');
    return filas.map(ResumenRutina.fromMap).toList();
  }
}
