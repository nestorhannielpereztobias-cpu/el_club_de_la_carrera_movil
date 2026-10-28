import 'package:flutter/material.dart';
import '../models/entrenamiento_model.dart';
import '../services/entrenamiento_service.dart';

class ConsultarEntrenamientosView extends StatefulWidget {
  final String idUsuario;

  const ConsultarEntrenamientosView({super.key, required this.idUsuario});

  @override
  State<ConsultarEntrenamientosView> createState() => _ConsultarEntrenamientosViewState();
}

class _ConsultarEntrenamientosViewState extends State<ConsultarEntrenamientosView> {
  final EntrenamientoService _service = EntrenamientoService();
  late Future<List<EntrenamientoModel>> _futureEntrenamientos;

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientos();
  }

  void _cargarEntrenamientos() {
    setState(() {
      _futureEntrenamientos = _service.obtenerEntrenamientosPorAtleta(widget.idUsuario);
    });
  }

  Color _colorSensacion(String sensacion) {
    switch (sensacion.toLowerCase()) {
      case 'excelente':
        return Colors.green.shade600;
      case 'bueno':
        return Colors.teal;
      case 'regular':
        return Colors.amber.shade800;
      case 'pesado':
        return Colors.deepOrange;
      default:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Entrenamientos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarEntrenamientos(),
        color: Colors.deepOrange,
        child: FutureBuilder<List<EntrenamientoModel>>(
          future: _futureEntrenamientos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
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
                      Text('Error al cargar entrenamientos: ${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarEntrenamientos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final entrenamientos = snapshot.data ?? [];

            if (entrenamientos.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.directions_run_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Aún no has registrado ningún entrenamiento.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entrenamientos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = entrenamientos[index];
                final fechaFormateada =
                    "${item.fecha.day.toString().padLeft(2, '0')}/${item.fecha.month.toString().padLeft(2, '0')}/${item.fecha.year}";

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado: Fecha y Sensación
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  fechaFormateada,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _colorSensacion(item.sensacion).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.sensacion,
                                style: TextStyle(
                                  color: _colorSensacion(item.sensacion),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Actividad
                        Text(
                          item.actividad,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),

                        // Métricas: Distancia, Tiempo, Ritmo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetrica(
                              label: 'Distancia',
                              valor: item.distanciaKm != null ? '${item.distanciaKm} km' : '--',
                              icon: Icons.straighten,
                            ),
                            _buildMetrica(
                              label: 'Tiempo',
                              valor: item.tiempoMinutos != null ? '${item.tiempoMinutos} min' : '--',
                              icon: Icons.timer_outlined,
                            ),
                            _buildMetrica(
                              label: 'Ritmo',
                              valor: item.ritmoPromedio ?? '--',
                              icon: Icons.speed,
                            ),
                          ],
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
    );
  }

  Widget _buildMetrica({required String label, required String valor, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.deepOrange),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}