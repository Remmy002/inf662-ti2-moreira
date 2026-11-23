import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ejercicio.dart';
import '../providers/ejercicio_provider.dart';
import '../widgets/dialogo_confirmar.dart';

class PantallaFormularioEjercicio extends StatefulWidget {
  final int rutinaId;
  final Ejercicio? ejercicio;

  const PantallaFormularioEjercicio({
    super.key,
    required this.rutinaId,
    this.ejercicio,
  });

  @override
  State<PantallaFormularioEjercicio> createState() =>
      _PantallaFormularioEjercicioState();
}

class _PantallaFormularioEjercicioState
    extends State<PantallaFormularioEjercicio> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _seriesCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _pesoCtrl;
  bool _guardando = false;

  bool get _esEdicion => widget.ejercicio != null;

  @override
  void initState() {
    super.initState();
    final e = widget.ejercicio;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _seriesCtrl = TextEditingController(text: e?.series.toString() ?? '');
    _repsCtrl = TextEditingController(text: e?.repeticiones.toString() ?? '');
    _pesoCtrl = TextEditingController(text: e?.peso.toString() ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  String? _validarEntero(String? v, String campo) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return '$campo debe ser un entero mayor a 0';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final ejercicio = Ejercicio(
      id: widget.ejercicio?.id,
      rutinaId: widget.rutinaId,
      nombre: _nombreCtrl.text.trim(),
      series: int.parse(_seriesCtrl.text.trim()),
      repeticiones: int.parse(_repsCtrl.text.trim()),
      peso: double.parse(_pesoCtrl.text.trim().replaceAll(',', '.')),
    );
    final error = await context.read<EjercicioProvider>().guardar(ejercicio);
    if (!mounted) return;

    setState(() => _guardando = false);
    mostrarMensaje(
      context,
      error ?? (_esEdicion ? 'Ejercicio actualizado' : 'Ejercicio agregado'),
    );
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar ejercicio' : 'Nuevo ejercicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese un nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seriesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Series',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validarEntero(v, 'Series'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validarEntero(v, 'Repeticiones'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  if (n == null || n < 0) return 'Ingrese un peso válido (0 o más)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
