
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/plan_model.dart';
import '../services/plan_service.dart';

class MiPlanView extends StatefulWidget {
  final String idUsuario;

  const MiPlanView({
    super.key,
    required this.idUsuario,
  });

  @override
  State<MiPlanView> createState() => _MiPlanViewState();
}

class _MiPlanViewState extends State<MiPlanView> {
  final PlanService _planService = PlanService();

  late Future<PlanAsignadoModel?> _futurePlanActivo;

  @override
  void initState() {
    super.initState();

    _futurePlanActivo =
        _planService.obtenerPlanActivo(widget.idUsuario);
  }

  // Recargar el plan
  void _cargarPlan() {
    setState(() {
      _futurePlanActivo =
          _planService.obtenerPlanActivo(widget.idUsuario);
    });
  }

  // Actualizar mediante RefreshIndicator
  Future<void> _refrescarPlan() async {
    setState(() {
      _futurePlanActivo =
          _planService.obtenerPlanActivo(widget.idUsuario);
    });

    try {
      await _futurePlanActivo;
    } catch (_) {
      // El FutureBuilder mostrará el error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Plan de Entrenamiento',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _refrescarPlan,
        color: Colors.deepOrange,

        child: FutureBuilder<PlanAsignadoModel?>(
          future: _futurePlanActivo,

          builder: (context, snapshot) {

            // Cargando
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                ),
              );
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Error al cargar tu plan: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),

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

            // Sin plan activo
            if (plan == null) {
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const SizedBox(height: 100),

                  const Icon(
                    Icons.fitness_center_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      'No tienes ningún plan de entrenamiento activo en este momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Agrupar los días por semana
            final Map<int, List<DiaPlanModel>> diasPorSemana = {};

            for (var dia in plan.dias) {
              diasPorSemana
                  .putIfAbsent(dia.numSemana, () => [])
                  .add(dia);
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),

              children: [

                // CABECERA DEL PLAN
                Card(
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),

                  color: Colors.deepOrange.shade50,

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        // Origen
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.deepOrange,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              'Origen: ${plan.origen.toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Nombre del plan
                        Text(
                          plan.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Objetivo
                        Text(
                          'Objetivo: ${plan.objetivo}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const Divider(height: 20),

                        // Duración y frecuencia
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [
                            _buildInfoMini(
                              'Duración',
                              '${plan.duracionSemanas} semanas',
                              Icons.calendar_today,
                            ),

                            _buildInfoMini(
                              'Frecuencia',
                              '${plan.diasPorSemana} días/sem',
                              Icons.repeat,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // PROGRESO DEL PLAN
                        const Text(
                          'Progreso del entrenamiento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),

                          child: LinearPercentIndicator(
                            percent: 0.65,
                            lineHeight: 12.0,
                            backgroundColor:
                                Colors.deepOrange.shade100,
                            progressColor: Colors.deepOrange,
                            barRadius: const Radius.circular(6),
                            animation: true,

                            trailing: const Text(
                              '65%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CALENDARIO
                const Text(
                  'Calendario de Actividades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // SEMANAS Y DÍAS
                ...diasPorSemana.entries.map((entry) {
                  final semanaNum = entry.key;
                  final dias = entry.value;

                  return ExpansionTile(
                    initiallyExpanded: semanaNum == 1,

                    title: Text(
                      'Semana $semanaNum',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      child: Icon(
                        Icons.date_range,
                        size: 20,
                      ),
                    ),

                    children: dias.map((dia) {

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        elevation: 1,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: ListTile(

                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.deepOrange.shade100,

                            child: Text(
                              'D${dia.numDia}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.deepOrange.shade900,
                              ),
                            ),
                          ),

                          title: Text(
                            'Día ${dia.numDia}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                            ),

                            child: Text(
                              dia.indicaciones.isNotEmpty
                                  ? dia.indicaciones
                                  : 'Sin indicaciones específicas.',

                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget para mostrar información resumida
  Widget _buildInfoMini(
    String label,
    String valor,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.deepOrange,
        ),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),

            Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
