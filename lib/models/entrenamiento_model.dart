class EntrenamientoModel {
  final int? idEntrenamiento;
  final String idUsuario;
  final DateTime fecha;
  final String actividad;
  final String sensacion;
  final double? distanciaKm;
  final int? tiempoMinutos;
  final String? ritmoPromedio;
  final DateTime? fechaRegistro;

  EntrenamientoModel({
    this.idEntrenamiento,
    required this.idUsuario,
    required this.fecha,
    required this.actividad,
    required this.sensacion,
    this.distanciaKm,
    this.tiempoMinutos,
    this.ritmoPromedio,
    this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'idusuario': idUsuario,
      'fecha': "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
      'actividad': actividad,
      'sensacion': sensacion,
      'distancia_km': distanciaKm,
      'tiempo_minutos': tiempoMinutos,
      'ritmo_promedio': ritmoPromedio,
    };
  }

  factory EntrenamientoModel.fromMap(Map<String, dynamic> map) {
    return EntrenamientoModel(
      idEntrenamiento: map['identrenamiento'] != null ? int.tryParse(map['identrenamiento'].toString()) : null,
      idUsuario: map['idusuario'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      actividad: map['actividad'] ?? '',
      sensacion: map['sensacion'] ?? '',
      distanciaKm: map['distancia_km'] != null ? double.tryParse(map['distancia_km'].toString()) : null,
      tiempoMinutos: map['tiempo_minutos'] != null ? int.tryParse(map['tiempo_minutos'].toString()) : null,
      ritmoPromedio: map['ritmo_promedio'],
      fechaRegistro: map['fecharegistro'] != null ? DateTime.tryParse(map['fecharegistro']) : null,
    );
  }
}