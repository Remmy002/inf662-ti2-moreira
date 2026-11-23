import 'package:flutter/material.dart';

import '../models/rutina.dart';

class RutinaCard extends StatelessWidget {
  final Rutina rutina;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const RutinaCard({
    super.key,
    required this.rutina,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(rutina.nombre),
        subtitle: Text(
          rutina.descripcion.isEmpty
              ? rutina.dia
              : '${rutina.dia} · ${rutina.descripcion}',
        ),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEditar),
            IconButton(icon: const Icon(Icons.delete), onPressed: onEliminar),
          ],
        ),
      ),
    );
  }
}
