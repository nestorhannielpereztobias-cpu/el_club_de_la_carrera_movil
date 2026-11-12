
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan_model.dart';

class PlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener plan activo del atleta
  Future<PlanAsignadoModel?> obtenerPlanActivo(String idUsuario) async {
    final asignacion = await _supabase
        .from('asignacion_plan')
        .select('*, plan(*)')
        .eq('idusuario', idUsuario)
        .eq('activo', true)
        .maybeSingle();

    if (asignacion == null || asignacion['plan'] == null) {
      return null;
    }

    final planMap = asignacion['plan'] as Map<String, dynamic>;
    final int idPlan = planMap['idplan'] as int;

    final diasResp = await _supabase
        .from('dia_plan')
        .select()
        .eq('idplan', idPlan)
        .order('num_semana', ascending: true)
        .order('num_dia', ascending: true);

    final List<DiaPlanModel> listaDias = (diasResp as List<dynamic>)
        .map((d) => DiaPlanModel.fromMap(d as Map<String, dynamic>))
        .toList();

    return PlanAsignadoModel.fromMap(
      asignacion,
      planMap,
      listaDias,
    );
  }

  // Obtener todos los planes disponibles para asignar
  Future<List<Map<String, dynamic>>> obtenerPlanesDisponibles() async {
    final response = await _supabase
        .from('plan')
        .select()
        .order('nombre');

    return List<Map<String, dynamic>>.from(response);
  }

  // Asignar un plan a un atleta por parte del entrenador
  Future<void> asignarPlanAAtleta({
    required String idAtleta,
    required int idPlan,
    required String idEntrenador,
  }) async {

    // 1. Desactivar planes anteriores activos del atleta
    await _supabase
        .from('asignacion_plan')
        .update({'activo': false})
        .eq('idusuario', idAtleta)
        .eq('activo', true);

    // 2. Insertar la nueva asignación
    await _supabase.from('asignacion_plan').insert({
      'idusuario': idAtleta,
      'idplan': idPlan,
      'origen': 'entrenador',
      'asignado_por': idEntrenador,
      'activo': true,
      'fecha_asignacion': DateTime.now().toIso8601String(),
    });
  }
}
