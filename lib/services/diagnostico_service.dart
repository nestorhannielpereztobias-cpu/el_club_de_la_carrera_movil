import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosticoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Verifica si el atleta ya tiene un diagnóstico previo
  Future<Map<String, dynamic>?> obtenerDiagnostico(String idUsuario) async {
    final response = await _supabase
        .from('diagnostico')
        .select()
        .eq('idusuario', idUsuario)
        .maybeSingle();
    return response;
  }

  // Guarda las respuestas y asigna el plan en una sola operación
  Future<void> registrarDiagnosticoYAsignarPlan({
    required String idUsuario,
    required String respuesta1,
    String? respuesta2,
    String? respuesta3,
    required String pruebaObjetivo,
    required int idPlanAsignado,
  }) async {
    // 1. Guardar o actualizar en la tabla diagnostico
    await _supabase.from('diagnostico').upsert({
      'idusuario': idUsuario,
      'respuesta_1': respuesta1,
      'respuesta_2': respuesta2,
      'respuesta_3': respuesta3,
      'pruebaobjetivo': pruebaObjetivo,
      'planasignado': idPlanAsignado,
      'fecha_respuesta': DateTime.now().toIso8601String(),
    });

    // 2. Desactivar cualquier plan activo anterior en asignacion_plan
    await _supabase
        .from('asignacion_plan')
        .update({'activo': false})
        .eq('idusuario', idUsuario);

    // 3. Crear la nueva asignación activa generada por el cuestionario
    await _supabase.from('asignacion_plan').insert({
      'idusuario': idUsuario,
      'idplan': idPlanAsignado,
      'origen': 'cuestionario',
      'activo': true,
      'fecha_asignacion': DateTime.now().toIso8601String(),
    });
  }
}