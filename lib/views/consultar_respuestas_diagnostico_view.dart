import 'package:flutter/material.dart';
import '../services/diagnostico_service.dart';
import 'cuestionario_diagnostico_view.dart';

class ConsultarRespuestasDiagnosticoView extends StatefulWidget {
  final String idUsuario;

  const ConsultarRespuestasDiagnosticoView({super.key, required this.idUsuario});

  @override
  State<ConsultarRespuestasDiagnosticoView> createState() =>
      _ConsultarRespuestasDiagnosticoViewState();
}

class _ConsultarRespuestasDiagnosticoViewState
    extends State<ConsultarRespuestasDiagnosticoView> {
  final DiagnosticoService _service = DiagnosticoService();
  late Future<Map<String, dynamic>?> _futureDiagnostico;

  @override
  void initState() {
    super.initState();
    _cargarDiagnostico();
  }

  void _cargarDiagnostico() {
    setState(() {
      _futureDiagnostico = _service.obtenerDiagnostico(widget.idUsuario);
    });
  }

  String _formatearFecha(dynamic rawFecha) {
    if (rawFecha == null) return '--/--/----';
    final fecha = DateTime.tryParse(rawFecha.toString());
    if (fecha == null) return rawFecha.toString();
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diagnóstico', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarDiagnostico(),
        color: Colors.deepOrange,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _futureDiagnostico,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar el diagnóstico: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDiagnostico,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;

            if (data == null) {
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.assignment_late_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Aún no has completado tu cuestionario de diagnóstico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Realizar Cuestionario'),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CuestionarioDiagnosticoView(
                              idUsuario: widget.idUsuario,
                            ),
                          ),
                        );
                        _cargarDiagnostico();
                      },
                    ),
                  ),
                ],
              );
            }

            final planMap = data['plan'] as Map<String, dynamic>?;
            final nombrePlan = planMap?['nombre'] ?? 'Plan asignado #${data['planasignado'] ?? '--'}';
            final objetivo = data['pruebaobjetivo'] ?? 'No especificado';
            final fecha = _formatearFecha(data['fecha_respuesta']);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Resumen del resultado asignado
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: Colors.deepOrange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.deepOrange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Resultado Asignado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              fecha,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nombrePlan,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Objetivo: $objetivo',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Tus Respuestas Registradas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Pregunta 1
                _buildCardRespuesta(
                  numero: 'Pregunta 1',
                  pregunta: '¿Puedes correr 5 km en menos de 30 minutos?',
                  respuesta: data['respuesta_1']?.toString() ?? 'Sin responder',
                  icono: Icons.timer_outlined,
                ),
                const SizedBox(height: 10),

                // Pregunta 2 (si aplica según el flujo)
                _buildCardRespuesta(
                  numero: 'Pregunta 2',
                  pregunta: '¿Puedes correr 5 km en menos de 25 minutos?',
                  respuesta: data['respuesta_2']?.toString() ?? 'No fue necesaria para tu nivel',
                  icono: Icons.speed_outlined,
                  omitida: data['respuesta_2'] == null,
                ),
                const SizedBox(height: 10),

                // Pregunta 3 (si aplica según el flujo)
                _buildCardRespuesta(
                  numero: 'Pregunta 3',
                  pregunta: '¿En qué distancia buscas competir o enfocarte?',
                  respuesta: data['respuesta_3']?.toString() ?? 'No fue necesaria para tu nivel',
                  icono: Icons.flag_circle_outlined,
                  omitida: data['respuesta_3'] == null,
                ),
                const SizedBox(height: 24),

                // Opción para repetir el diagnóstico
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepOrange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.deepOrange),
                  label: const Text(
                    'Volver a realizar diagnóstico',
                    style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CuestionarioDiagnosticoView(
                          idUsuario: widget.idUsuario,
                        ),
                      ),
                    );
                    _cargarDiagnostico();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardRespuesta({
    required String numero,
    required String pregunta,
    required String respuesta,
    required IconData icono,
    bool omitida = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: omitida ? Colors.grey : Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  numero,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: omitida ? Colors.grey : Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pregunta,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: omitida ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Text(
                  'Tu respuesta: ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  respuesta,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: omitida ? Colors.grey : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}