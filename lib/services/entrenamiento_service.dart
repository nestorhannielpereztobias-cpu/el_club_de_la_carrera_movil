import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entrenamiento_model.dart';

class EntrenamientoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Registrar entrenamiento (el que ya tienes)
  Future<void> registrarEntrenamiento(EntrenamientoModel entrenamiento) async {
    await _supabase.from('entrenamiento').insert(entrenamiento.toMap());
  }

  // Consultar historial de entrenamientos del atleta
  Future<List<EntrenamientoModel>> obtenerEntrenamientosPorAtleta(String idUsuario) async {
    final response = await _supabase
        .from('entrenamiento')
        .select()
        .eq('idusuario', idUsuario)
        .order('fecha', ascending: false);

    final lista = response as List<dynamic>;
    return lista.map((map) => EntrenamientoModel.fromMap(map as Map<String, dynamic>)).toList();
  }
}