import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class EntrenadorService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtiene todos los usuarios registrados con rol 'atleta'
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