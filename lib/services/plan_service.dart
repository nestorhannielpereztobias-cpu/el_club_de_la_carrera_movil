import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plan_model.dart';

class PlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<PlanAsignadoModel?> obtenerPlanActivo(String idUsuario) async {
    // 1. Obtener la asignación activa con la información del plan vinculado
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

    // 2. Consultar los días configurados en dia_plan para este plan
    final diasResp = await _supabase
        .from('dia_plan')
        .select()
        .eq('idplan', idPlan)
        .order('num_semana', ascending: true)
        .order('num_dia', ascending: true);

    final List<DiaPlanModel> listaDias = (diasResp as List<dynamic>)
        .map((d) => DiaPlanModel.fromMap(d as Map<String, dynamic>))
        .toList();

    return PlanAsignadoModel.fromMap(asignacion, planMap, listaDias);
  }
}