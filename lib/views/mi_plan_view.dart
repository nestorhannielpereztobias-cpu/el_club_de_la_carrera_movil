import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/plan_service.dart';
import 'cuestionario_diagnostico_view.dart';

class MiPlanView extends StatefulWidget {
  final String idUsuario;

  const MiPlanView({super.key, required this.idUsuario});

  @override
  State<MiPlanView> createState() => _MiPlanViewState();
}

class _MiPlanViewState extends State<MiPlanView> {
  final PlanService _planService = PlanService();
  late Future<PlanAsignadoModel?> _futurePlan;

  @override
  void initState() {
    super.initState();
    _cargarPlan();
  }

  void _cargarPlan() {
    setState(() {
      _futurePlan = _planService.obtenerPlanActivo(widget.idUsuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Plan de Entrenamiento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarPlan(),
        color: Colors.deepOrange,
        child: FutureBuilder<PlanAsignadoModel?>(
          future: _futurePlan,
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarPlan,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final plan = snapshot.data;

            if (plan == null) {
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.assignment_late_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes un plan asignado activo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Responde el cuestionario diagnóstico para que el sistema configure tu entrenamiento automáticamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CuestionarioDiagnosticoView(idUsuario: widget.idUsuario),
                        ),
                      );
                      _cargarPlan();
                    },
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('Realizar Cuestionario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Tarjeta Principal del Plan
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.deepOrange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan.origen.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Text(
                              'ACTIVO',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plan.nombre,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Objetivo: ${plan.objetivo}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              icon: Icons.calendar_month,
                              titulo: '${plan.duracionSemanas} semanas',
                              subtitulo: 'Duración',
                            ),
                            _buildInfoItem(
                              icon: Icons.repeat,
                              titulo: '${plan.diasPorSemana} días/sem',
                              subtitulo: 'Frecuencia',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lista de sesiones o días
                const Text(
                  'Sesiones Programadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (plan.dias.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aún no hay desglose de sesiones cargado para este plan en dia_plan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...plan.dias.map(
                    (dia) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange.withValues(alpha: 0.15),
                          child: Text(
                            'D${dia.numDia}',
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Semana ${dia.numSemana} • Día ${dia.numDia}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(dia.indicaciones),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 22),
        const SizedBox(height: 4),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}