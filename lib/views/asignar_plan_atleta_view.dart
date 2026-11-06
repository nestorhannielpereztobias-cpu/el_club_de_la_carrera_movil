
import 'package:flutter/material.dart';
import '../services/plan_service.dart';
import 'mapa_ubicacion_view.dart';

class AsignarPlanAtletaView extends StatefulWidget {
  final String idAtleta;
  final String idEntrenador;

  const AsignarPlanAtletaView({
    super.key,
    required this.idAtleta,
    required this.idEntrenador,
  });

  @override
  State<AsignarPlanAtletaView> createState() =>
      _AsignarPlanAtletaViewState();
}

class _AsignarPlanAtletaViewState
    extends State<AsignarPlanAtletaView> {

  final PlanService _planService = PlanService();

  late Future<List<Map<String, dynamic>>> _futurePlanes;

  int? _idPlanSeleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _futurePlanes = _planService.obtenerPlanesDisponibles();
  }

  Future<void> _guardarAsignacion() async {
    if (_idPlanSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un plan de entrenamiento'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _planService.asignarPlanAAtleta(
        idAtleta: widget.idAtleta,
        idPlan: _idPlanSeleccionado!,
        idEntrenador: widget.idEntrenador,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Plan asignado exitosamente al atleta!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asignar plan: $e'),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asignar Plan de Entrenamiento',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Selecciona el Plan de Entrenamiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futurePlanes,

                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final planes = snapshot.data ?? [];

                  if (planes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay planes creados en el sistema.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: planes.length,

                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),

                    itemBuilder: (context, index) {
                      final plan = planes[index];

                      final idPlan = int.tryParse(
                        plan['idplan'].toString(),
                      );

                      if (idPlan == null) {
                        return const SizedBox.shrink();
                      }

                      final nombre =
                          plan['nombre']?.toString() ?? 'Sin nombre';

                      final objetivo =
                          plan['objetivo']?.toString() ?? '';

                      final semanas =
                          plan['duracion_semanas']?.toString() ?? '0';

                      final seleccionado =
                          _idPlanSeleccionado == idPlan;

                      return Card(
                        elevation: seleccionado ? 3 : 1,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),

                          side: BorderSide(
                            color: seleccionado
                                ? Colors.deepOrange
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),

                        child: ListTile(
                          title: Text(
                            nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            '$objetivo\nDuración: $semanas semanas',
                          ),

                          isThreeLine: true,

                          trailing: Icon(
                            seleccionado
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: seleccionado
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),

                          onTap: () {
                            setState(() {
                              _idPlanSeleccionado = idPlan;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.deepOrange,
                ),

                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              icon: const Icon(
                Icons.map_outlined,
                color: Colors.deepOrange,
              ),

              label: const Text(
                'Marcar Punto de Encuentro / Ruta (Mapa)',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapaUbicacionView()),
                );
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,

                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: _guardando
                  ? null
                  : _guardarAsignacion,

              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )

                  : const Text(
                      'Guardar Asignación',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
