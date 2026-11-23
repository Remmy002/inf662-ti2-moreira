import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rutina.dart';
import '../providers/rutina_provider.dart';
import '../widgets/dialogo_confirmar.dart';

const _dias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class PantallaFormularioRutina extends StatefulWidget {
  final Rutina? rutina;

  const PantallaFormularioRutina({super.key, this.rutina});

  @override
  State<PantallaFormularioRutina> createState() =>
      _PantallaFormularioRutinaState();
}

class _PantallaFormularioRutinaState extends State<PantallaFormularioRutina> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  String? _dia;
  bool _guardando = false;

  bool get _esEdicion => widget.rutina != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.rutina?.nombre ?? '');
    _descripcionCtrl = TextEditingController(
      text: widget.rutina?.descripcion ?? '',
    );
    _dia = widget.rutina?.dia;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final rutina = Rutina(
      id: widget.rutina?.id,
      nombre: _nombreCtrl.text.trim(),
      dia: _dia!,
      descripcion: _descripcionCtrl.text.trim(),
    );
    final error = await context.read<RutinaProvider>().guardar(rutina);
    if (!mounted) return;

    setState(() => _guardando = false);
    mostrarMensaje(
      context,
      error ?? (_esEdicion ? 'Rutina actualizada' : 'Rutina creada'),
    );
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar rutina' : 'Nueva rutina')),
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
              DropdownButtonFormField<String>(
                initialValue: _dia,
                decoration: const InputDecoration(
                  labelText: 'Día',
                  border: OutlineInputBorder(),
                ),
                items: _dias
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (valor) => setState(() => _dia = valor),
                validator: (v) => v == null ? 'Seleccione un día' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
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
