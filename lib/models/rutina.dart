class Rutina {
  final int? id;
  final String nombre;
  final String dia;
  final String descripcion;

  const Rutina({
    this.id,
    required this.nombre,
    required this.dia,
    this.descripcion = '',
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'dia': dia,
      'descripcion': descripcion,
    };
  }

  factory Rutina.fromMap(Map<String, Object?> map) {
    return Rutina(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      dia: map['dia'] as String,
      descripcion: (map['descripcion'] as String?) ?? '',
    );
  }

  Rutina copyWith({int? id, String? nombre, String? dia, String? descripcion}) {
    return Rutina(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dia: dia ?? this.dia,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
