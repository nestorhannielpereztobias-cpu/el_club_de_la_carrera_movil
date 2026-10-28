class DiaPlanModel {
  final int idDiaPlan;
  final int numSemana;
  final int numDia;
  final String indicaciones;

  DiaPlanModel({
    required this.idDiaPlan,
    required this.numSemana,
    required this.numDia,
    required this.indicaciones,
  });

  factory DiaPlanModel.fromMap(Map<String, dynamic> map) {
    return DiaPlanModel(
      idDiaPlan: map['iddiaplan'] as int,
      numSemana: map['num_semana'] as int,
      numDia: map['num_dia'] as int,
      indicaciones: map['indicaciones'] as String? ?? '',
    );
  }
}

class PlanAsignadoModel {
  final int idAsignacion;
  final int idPlan;
  final String nombre;
  final int duracionSemanas;
  final int diasPorSemana;
  final String objetivo;
  final String? requisito;
  final String origen;
  final DateTime? fechaAsignacion;
  final List<DiaPlanModel> dias;

  PlanAsignadoModel({
    required this.idAsignacion,
    required this.idPlan,
    required this.nombre,
    required this.duracionSemanas,
    required this.diasPorSemana,
    required this.objetivo,
    this.requisito,
    required this.origen,
    this.fechaAsignacion,
    this.dias = const [],
  });

  factory PlanAsignadoModel.fromMap(
    Map<String, dynamic> asignacionMap,
    Map<String, dynamic> planMap,
    List<DiaPlanModel> dias,
  ) {
    return PlanAsignadoModel(
      idAsignacion: asignacionMap['idasignacion'] as int,
      idPlan: planMap['idplan'] as int,
      nombre: planMap['nombre'] as String? ?? 'Plan de entrenamiento',
      duracionSemanas: planMap['duracion_semanas'] as int? ?? 0,
      diasPorSemana: planMap['dias_por_semana'] as int? ?? 0,
      objetivo: planMap['objetivo'] as String? ?? '',
      requisito: planMap['requisito'] as String?,
      origen: asignacionMap['origen'] as String? ?? 'general',
      fechaAsignacion: asignacionMap['fecha_asignacion'] != null
          ? DateTime.tryParse(asignacionMap['fecha_asignacion'])
          : null,
      dias: dias,
    );
  }
}