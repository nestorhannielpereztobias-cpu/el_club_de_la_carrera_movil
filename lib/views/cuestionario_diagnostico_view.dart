import 'package:flutter/material.dart';
import '../services/diagnostico_service.dart';

class CuestionarioDiagnosticoView extends StatefulWidget {
  final String idUsuario;

  const CuestionarioDiagnosticoView({super.key, required this.idUsuario});

  @override
  State<CuestionarioDiagnosticoView> createState() =>
      _CuestionarioDiagnosticoViewState();
}

class _CuestionarioDiagnosticoViewState
    extends State<CuestionarioDiagnosticoView> {
  final DiagnosticoService _service = DiagnosticoService();

  int _pasoActual = 1;
  String? _resp1;
  String? _resp2;
  String? _resp3;
  bool _enviando = false;

  void _responderPregunta1(bool puedeSub30) {
    if (!puedeSub30) {
      _finalizarCuestionario(
        resp1: 'No',
        resp2: null,
        resp3: null,
        pruebaObjetivo: 'Correr 30 minutos continuos',
        idPlan: 1,
        nombrePlan: 'Plan 1: Introducción al Running (30 min continuos)',
      );
    } else {
      setState(() {
        _resp1 = 'Sí';
        _pasoActual = 2;
      });
    }
  }

  void _responderPregunta2(bool puedeSub25) {
    if (!puedeSub25) {
      _finalizarCuestionario(
        resp1: _resp1!,
        resp2: 'No',
        resp3: null,
        pruebaObjetivo: '5K sub 25 minutos',
        idPlan: 2,
        nombrePlan: 'Plan 2: Consolidación 5K (Sub 25 min)',
      );
    } else {
      setState(() {
        _resp2 = 'Sí';
        _pasoActual = 3;
      });
    }
  }

  void _responderPregunta3(String distancia) {
    if (distancia == '5K') {
      _finalizarCuestionario(
        resp1: _resp1!,
        resp2: _resp2!,
        resp3: '5 km',
        pruebaObjetivo: '5K sub 24 minutos',
        idPlan: 3,
        nombrePlan: 'Plan 3: Rendimiento 5K (Sub 24 min)',
      );
    } else {
      _finalizarCuestionario(
        resp1: _resp1!,
        resp2: _resp2!,
        resp3: '10 km',
        pruebaObjetivo: '10K sub 50 minutos',
        idPlan: 4,
        nombrePlan: 'Plan 4: Fondo 10K (Sub 50 min)',
      );
    }
  }

  Future<void> _finalizarCuestionario({
    required String resp1,
    required String? resp2,
    required String? resp3,
    required String pruebaObjetivo,
    required int idPlan,
    required String nombrePlan,
  }) async {
    setState(() => _enviando = true);
    try {
      await _service.registrarDiagnosticoYAsignarPlan(
        idUsuario: widget.idUsuario,
        respuesta1: resp1,
        respuesta2: resp2,
        respuesta3: resp3,
        pruebaObjetivo: pruebaObjetivo,
        idPlanAsignado: idPlan,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('¡Plan Asignado!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Con base en tus respuestas hemos configurado tu entrenamiento:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombrePlan,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 4),
                    Text('Objetivo: $pruebaObjetivo', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () {
                Navigator.pop(context); // Cierra dialog
                Navigator.pop(context); // Regresa al Home
              },
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico de Nivel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _enviando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepOrange),
                  SizedBox(height: 16),
                  Text('Asignando tu plan de entrenamiento...'),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: _pasoActual / 3,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 32),
                    Expanded(child: _buildPasoActual()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPasoActual() {
    switch (_pasoActual) {
      case 1:
        return _buildPregunta(
          numero: 'Pregunta 1 de 3',
          pregunta: '¿Puedes correr 5 km en menos de 30 minutos?',
          icono: Icons.timer,
          opcionA: 'Sí, puedo hacerlo',
          onTapA: () => _responderPregunta1(true),
          opcionB: 'No, aún no puedo',
          onTapB: () => _responderPregunta1(false),
        );
      case 2:
        return _buildPregunta(
          numero: 'Pregunta 2 de 3',
          pregunta: '¿Puedes correr 5 km en menos de 25 minutos?',
          icono: Icons.speed,
          opcionA: 'Sí, supero esa marca',
          onTapA: () => _responderPregunta2(true),
          opcionB: 'No, rondo los 25-30 minutos',
          onTapB: () => _responderPregunta2(false),
        );
      case 3:
        return _buildPregunta(
          numero: 'Pregunta 3 de 3',
          pregunta: '¿En qué distancia buscas competir o enfocarte?',
          icono: Icons.flag_circle_outlined,
          opcionA: '5 Kilómetros',
          onTapA: () => _responderPregunta3('5K'),
          opcionB: '10 Kilómetros',
          onTapB: () => _responderPregunta3('10K'),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPregunta({
    required String numero,
    required String pregunta,
    required IconData icono,
    required String opcionA,
    required VoidCallback onTapA,
    required String opcionB,
    required VoidCallback onTapB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(numero, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Colors.deepOrange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pregunta,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onTapA,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(opcionA, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: onTapB,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepOrange, width: 1.5),
            foregroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(opcionB, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}