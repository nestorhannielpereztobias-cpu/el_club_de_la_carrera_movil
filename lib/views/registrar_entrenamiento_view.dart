import 'package:flutter/material.dart';
import '../models/entrenamiento_model.dart';
import '../services/entrenamiento_service.dart';

class RegistrarEntrenamientoView extends StatefulWidget {
  final String idUsuario;

  const RegistrarEntrenamientoView({super.key, required this.idUsuario});

  @override
  State<RegistrarEntrenamientoView> createState() => _RegistrarEntrenamientoViewState();
}

class _RegistrarEntrenamientoViewState extends State<RegistrarEntrenamientoView> {
  final _formKey = GlobalKey<FormState>();
  final _actividadController = TextEditingController();
  final _distanciaController = TextEditingController();
  final _tiempoController = TextEditingController();
  final _ritmoController = TextEditingController();
  final EntrenamientoService _service = EntrenamientoService();

  DateTime _fechaSeleccionada = DateTime.now();
  String _sensacionSeleccionada = 'Bueno';
  bool _isLoading = false;

  final List<String> _opcionesSensacion = [
    'Excelente',
    'Bueno',
    'Regular',
    'Pesado',
    'Agotado/Fatiga',
  ];

  @override
  void dispose() {
    _actividadController.dispose();
    _distanciaController.dispose();
    _tiempoController.dispose();
    _ritmoController.dispose();
    super.dispose();
  }

  void _calcularRitmo() {
    final dist = double.tryParse(_distanciaController.text.trim());
    final min = double.tryParse(_tiempoController.text.trim());

    if (dist != null && min != null && dist > 0 && min > 0) {
      final ritmoTotalMin = min / dist;
      final int m = ritmoTotalMin.floor();
      final int s = ((ritmoTotalMin - m) * 60).round();
      setState(() {
        _ritmoController.text = "$m:${s.toString().padLeft(2, '0')} min/km";
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF05023),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _guardarEntrenamiento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nuevoEntrenamiento = EntrenamientoModel(
        idUsuario: widget.idUsuario,
        fecha: _fechaSeleccionada,
        actividad: _actividadController.text.trim(),
        sensacion: _sensacionSeleccionada,
        distanciaKm: double.tryParse(_distanciaController.text.trim()),
        tiempoMinutos: int.tryParse(_tiempoController.text.trim()),
        ritmoPromedio: _ritmoController.text.trim().isNotEmpty ? _ritmoController.text.trim() : null,
      );

      await _service.registrarEntrenamiento(nuevoEntrenamiento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Entrenamiento registrado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Entrenamiento', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFF05023),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _seleccionarFecha(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fecha: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFFF05023)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _actividadController,
                decoration: InputDecoration(
                  labelText: 'Actividad o Descripción *',
                  hintText: 'Ej. Rodaje suave 8k, Series 5x1000m',
                  prefixIcon: const Icon(Icons.directions_run),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la actividad realizada' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sensacionSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Sensación *',
                  prefixIcon: const Icon(Icons.mood),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _opcionesSensacion.map((sens) {
                  return DropdownMenuItem(value: sens, child: Text(sens));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _sensacionSeleccionada = val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _distanciaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Distancia (km)',
                        hintText: 'Ej. 10.0',
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (_) => _calcularRitmo(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tiempoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tiempo (min)',
                        hintText: 'Ej. 45',
                        prefixIcon: const Icon(Icons.timer_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (_) => _calcularRitmo(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ritmoController,
                decoration: InputDecoration(
                  labelText: 'Ritmo Promedio',
                  hintText: 'Ej. 4:30 min/km',
                  prefixIcon: const Icon(Icons.speed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarEntrenamiento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05023),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar Entrenamiento', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
