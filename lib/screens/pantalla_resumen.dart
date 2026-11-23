import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rutina_provider.dart';
import '../widgets/estado_vacio.dart';

class PantallaResumen extends StatefulWidget {
  const PantallaResumen({super.key});

  @override
  State<PantallaResumen> createState() => _PantallaResumenState();
}

class _PantallaResumenState extends State<PantallaResumen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RutinaProvider>().cargarResumen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen por rutina')),
      body: Consumer<RutinaProvider>(
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
          if (provider.resumen.isEmpty) {
            return const EstadoVacio(mensaje: 'Aún no hay datos para resumir.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.resumen.length,
            itemBuilder: (context, index) {
              final r = provider.resumen[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.insights)),
                  title: Text(r.nombre),
                  subtitle: Text(
                    '${r.totalEjercicios} ejercicios · ${r.totalSeries} series',
                  ),
                  trailing: Text(
                    '${r.volumen.toStringAsFixed(0)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
