import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ejercicio.dart';
import '../models/rutina.dart';
import '../providers/ejercicio_provider.dart';
import '../widgets/dialogo_confirmar.dart';
import '../widgets/estado_vacio.dart';
import 'pantalla_formulario_ejercicio.dart';

class PantallaDetalleRutina extends StatefulWidget {
  final Rutina rutina;

  const PantallaDetalleRutina({super.key, required this.rutina});

  @override
  State<PantallaDetalleRutina> createState() => _PantallaDetalleRutinaState();
}

class _PantallaDetalleRutinaState extends State<PantallaDetalleRutina> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EjercicioProvider>().cargarPorRutina(widget.rutina.id!);
    });
  }

  Future<void> _eliminar(Ejercicio ejercicio) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar ejercicio',
      mensaje: 'Se eliminará "${ejercicio.nombre}".',
    );
    if (!confirmado || !mounted) return;

    final error = await context.read<EjercicioProvider>().eliminar(
      ejercicio.id!,
    );
    if (!mounted) return;
    mostrarMensaje(context, error ?? 'Ejercicio eliminado');
  }

  void _abrirFormulario([Ejercicio? ejercicio]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormularioEjercicio(
          rutinaId: widget.rutina.id!,
          ejercicio: ejercicio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rutina = widget.rutina;
    return Scaffold(
      appBar: AppBar(title: Text(rutina.nombre)),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(rutina.dia),
            subtitle: rutina.descripcion.isEmpty
                ? null
                : Text(rutina.descripcion),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar ejercicio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (texto) =>
                  context.read<EjercicioProvider>().buscar(texto),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<EjercicioProvider>(
              builder: (context, provider, child) {
                if (provider.cargando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return EstadoVacio(
                    icono: Icons.error_outline,
                    mensaje: provider.error!,
                  );
                }
                if (provider.ejercicios.isEmpty) {
                  return const EstadoVacio(
                    mensaje: 'Esta rutina no tiene ejercicios. Toca + para agregar.',
                  );
                }
                return ListView.builder(
                  itemCount: provider.ejercicios.length,
                  itemBuilder: (context, index) {
                    final e = provider.ejercicios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(e.nombre),
                        subtitle: Text(
                          '${e.series} x ${e.repeticiones} · '
                          '${e.peso.toStringAsFixed(1)} kg · '
                          'Volumen ${e.volumen.toStringAsFixed(0)}',
                        ),
                        onTap: () => _abrirFormulario(e),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _abrirFormulario(e),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminar(e),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}