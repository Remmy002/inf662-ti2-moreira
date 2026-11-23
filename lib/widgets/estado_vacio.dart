import 'package:flutter/material.dart';

class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const EstadoVacio({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
