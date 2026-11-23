class Ejercicio {
  final int? id;
  final int rutinaId;
  final String nombre;
  final int series;
  final int repeticiones;
  final double peso;

  const Ejercicio({
    this.id,
    required this.rutinaId,
    required this.nombre,
    required this.series,
    required this.repeticiones,
    required this.peso,
  });

  double get volumen => series * repeticiones * peso;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'rutina_id': rutinaId,
      'nombre': nombre,
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
    };
  }

  factory Ejercicio.fromMap(Map<String, Object?> map) {
    return Ejercicio(
      id: map['id'] as int?,
      rutinaId: map['rutina_id'] as int,
      nombre: map['nombre'] as String,
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int,
      peso: (map['peso'] as num).toDouble(),
    );
  }

  Ejercicio copyWith({
    int? id,
    int? rutinaId,
    String? nombre,
    int? series,
    int? repeticiones,
    double? peso,
  }) {
    return Ejercicio(
      id: id ?? this.id,
      rutinaId: rutinaId ?? this.rutinaId,
      nombre: nombre ?? this.nombre,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      peso: peso ?? this.peso,
    );
  }
}
