class UsuarioModel {
  final String idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String rol;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.fechaNacimiento,
    this.genero,
    required this.rol,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      idUsuario: map['idusuario'] ?? map['idUsuario'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      fechaNacimiento: map['fechanacimiento'] != null 
          ? DateTime.tryParse(map['fechanacimiento']) 
          : null,
      genero: map['genero'],
      rol: map['rol'] ?? 'atleta',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'fechaNacimiento': fechaNacimiento?.toIso8601String().split('T').first,
      'genero': genero,
      'rol': rol,
    };
  }
}