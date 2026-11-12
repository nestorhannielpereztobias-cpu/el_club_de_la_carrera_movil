// diagnostico_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosticoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Verifica y obtiene el diagnóstico previo junto con los datos del plan
  Future<Map<String, dynamic>?> obtenerDiagnostico(String idUsuario) async {
    final response = await _supabase
        .from('diagnostico')
        .select('*, plan(*)')
        .eq('idusuario', idUsuario)
        .maybeSingle();
    return response;
  }

  Future<void> registrarDiagnosticoYAsignarPlan({
    required String idUsuario,
    required String respuesta1,
    String? respuesta2,
    String? respuesta3,
    required String pruebaObjetivo,
    required int idPlanAsignado,
  }) async {
    await _supabase.from('diagnostico').upsert({
      'idusuario': idUsuario,
      'respuesta_1': respuesta1,
      'respuesta_2': respuesta2,
      'respuesta_3': respuesta3,
      'pruebaobjetivo': pruebaObjetivo,
      'planasignado': idPlanAsignado,
      'fecha_respuesta': DateTime.now().toIso8601String(),
    });

    await _supabase
        .from('asignacion_plan')
        .update({'activo': false})
        .eq('idusuario', idUsuario);

    await _supabase.from('asignacion_plan').insert({
      'idusuario': idUsuario,
      'idplan': idPlanAsignado,
      'origen': 'cuestionario',
      'activo': true,
      'fecha_asignacion': DateTime.now().toIso8601String(),
    });
  }
}