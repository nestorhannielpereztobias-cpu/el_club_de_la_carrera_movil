
import 'package:supabase_flutter/supabase_flutter.dart';

class UbicacionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Registrar un punto de ubicación en el mapa
  Future<void> registrarPuntoUbicacion({
    required String nombre,
    required String descripcion,
    required double latitud,
    required double longitud,
  }) async {
    await _supabase.from('puntos_ubicacion').insert({
      'nombre': nombre,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
    });
  }
  

  // Obtener puntos registrados
  Future<List<Map<String, dynamic>>> obtenerPuntosUbicacion() async {
    final response = await _supabase
        .from('puntos_ubicacion')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
