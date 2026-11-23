/// Resultado de la consulta de agregación (JOIN + GROUP BY).
class ResumenRutina {
  final int rutinaId;
  final String nombre;
  final int totalEjercicios;
  final int totalSeries;
  final double volumen;

  const ResumenRutina({
    required this.rutinaId,
    required this.nombre,
    required this.totalEjercicios,
    required this.totalSeries,
    required this.volumen,
  });

  factory ResumenRutina.fromMap(Map<String, Object?> map) {
    return ResumenRutina(
      rutinaId: map['id'] as int,
      nombre: map['nombre'] as String,
      totalEjercicios: (map['total_ejercicios'] as num).toInt(),
      totalSeries: (map['total_series'] as num).toInt(),
      volumen: (map['volumen'] as num).toDouble(),
    );
  }
}
