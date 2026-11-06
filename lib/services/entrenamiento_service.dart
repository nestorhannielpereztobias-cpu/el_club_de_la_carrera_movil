import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entrenamiento_model.dart';
import '../models/usuario_model.dart';

class EntrenamientoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Registrar entrenamiento
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

  // Obtener lista de atletas para el entrenador
  Future<List<UsuarioModel>> obtenerAtletas() async {
    final response = await _supabase
        .from('usuario')
        .select()
        .eq('rol', 'atleta')
        .order('nombre', ascending: true);

    final lista = response as List<dynamic>;
    return lista.map((map) => UsuarioModel.fromMap(map as Map<String, dynamic>)).toList();
  }
}