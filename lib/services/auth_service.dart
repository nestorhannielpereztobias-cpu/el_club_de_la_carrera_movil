import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Iniciar sesión
  Future<UsuarioModel?> iniciarSesion(String correo, String contrasena) async {
    try {
      final response = await _client
          .from('usuario')
          .select()
          .eq('correo', correo.trim().toLowerCase())
          .eq('contrasena', contrasena)
          .maybeSingle();

      if (response == null) {
        throw Exception('Correo o contraseña incorrectos.');
      }

      return UsuarioModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Registrar nuevo atleta
  Future<UsuarioModel> registrarAtleta({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required DateTime fechaNacimiento,
    required String genero,
  }) async {
    try {
      final existe = await _client
          .from('usuario')
          .select('idusuario')
          .eq('correo', correo.trim().toLowerCase())
          .maybeSingle();

      if (existe != null) {
        throw Exception('Este correo ya está registrado.');
      }

      final dataInsert = {
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'correo': correo.trim().toLowerCase(),
        'contrasena': contrasena,
        'fechanacimiento': fechaNacimiento.toIso8601String().split('T').first,
        'genero': genero,
        'rol': 'atleta',
      };

      final response = await _client
          .from('usuario')
          .insert(dataInsert)
          .select()
          .single();

      return UsuarioModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }
}