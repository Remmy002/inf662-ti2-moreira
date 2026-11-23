import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rutina.dart';
import '../providers/rutina_provider.dart';
import '../providers/tema_provider.dart';
import '../widgets/dialogo_confirmar.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/rutina_card.dart';
import 'pantalla_detalle_rutina.dart';
import 'pantalla_formulario_rutina.dart';
import 'pantalla_resumen.dart';

class PantallaRutinas extends StatefulWidget {
  const PantallaRutinas({super.key});

  @override
  State<PantallaRutinas> createState() => _PantallaRutinasState();
}

class _PantallaRutinasState extends State<PantallaRutinas> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RutinaProvider>().cargar();
    });
  }

  Future<void> _eliminar(Rutina rutina) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar rutina',
      mensaje: 'Se eliminará "${rutina.nombre}" junto con todos sus ejercicios.',
    );
    if (!confirmado || !mounted) return;

    final error = await context.read<RutinaProvider>().eliminar(rutina.id!);
    if (!mounted) return;
    mostrarMensaje(context, error ?? 'Rutina eliminada');
  }

  void _abrirFormulario([Rutina? rutina]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormularioRutina(rutina: rutina),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Selector<RutinaProvider, int>(
          selector: (context, p) => p.rutinas.length,
          builder: (context, total, child) => Text('Mis rutinas ($total)'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Resumen',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaResumen()),
            ),
          ),
          IconButton(
            icon: Icon(
              context.watch<TemaProvider>().oscuro
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<TemaProvider>().alternar(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar rutina',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (texto) => context.read<RutinaProvider>().buscar(texto),
            ),
          ),
          Expanded(
            child: Consumer<RutinaProvider>(
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
                if (provider.rutinas.isEmpty) {
                  return const EstadoVacio(
                    icono: Icons.fitness_center,
                    mensaje: 'No hay rutinas. Toca + para crear una.',
                  );
                }
                return ListView.builder(
                  itemCount: provider.rutinas.length,
                  itemBuilder: (context, index) {
                    final rutina = provider.rutinas[index];
                    return RutinaCard(
                      rutina: rutina,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaDetalleRutina(rutina: rutina),
                        ),
                      ),
                      onEditar: () => _abrirFormulario(rutina),
                      onEliminar: () => _eliminar(rutina),
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
