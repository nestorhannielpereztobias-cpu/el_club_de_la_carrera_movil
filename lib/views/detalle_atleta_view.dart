import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/diagnostico_service.dart';
import 'consultar_entrenamientos_view.dart';

class DetalleAtletaView extends StatefulWidget {
  final UsuarioModel atleta;

  const DetalleAtletaView({super.key, required this.atleta});

  @override
  State<DetalleAtletaView> createState() => _DetalleAtletaViewState();
}

class _DetalleAtletaViewState extends State<DetalleAtletaView> {
  final DiagnosticoService _diagnosticoService = DiagnosticoService();
  late Future<Map<String, dynamic>?> _futureDiagnostico;

  @override
  void initState() {
    super.initState();
    _cargarDiagnostico();
  }

  void _cargarDiagnostico() {
    setState(() {
      _futureDiagnostico = _diagnosticoService.obtenerDiagnostico(widget.atleta.idUsuario);
    });
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No registrada';
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.atleta.nombre} ${widget.atleta.apellido}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarDiagnostico(),
        color: Colors.deepOrange,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildEncabezadoPerfil(),
            const SizedBox(height: 16),
            _buildCardDatosPersonales(),
            const SizedBox(height: 24),
            _buildBotonVerEntrenamientos(),
            const SizedBox(height: 24),
            const Text(
              'Diagnóstico Inicial del Atleta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSeccionDiagnostico(),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezadoPerfil() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.deepOrange,
            child: Text(
              widget.atleta.nombre.isNotEmpty ? widget.atleta.nombre[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.atleta.nombre} ${widget.atleta.apellido}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.atleta.correo,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDatosPersonales() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.badge_outlined, color: Colors.deepOrange, size: 20),
                SizedBox(width: 8),
                Text('Datos Personales', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            _buildFilaInfo('Correo', widget.atleta.correo, Icons.email_outlined),
            const SizedBox(height: 10),
            _buildFilaInfo('Fecha de Nacimiento', _formatearFecha(widget.atleta.fechaNacimiento), Icons.cake_outlined),
            const SizedBox(height: 10),
            _buildFilaInfo('Género', widget.atleta.genero ?? 'No especificado', Icons.person_outline),
            const SizedBox(height: 10),
            _buildFilaInfo('Rol', widget.atleta.rol.toUpperCase(), Icons.shield_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonVerEntrenamientos() {
    return Card(
      elevation: 2,
      color: Colors.deepOrange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.directions_run, color: Colors.white),
        ),
        title: const Text('Entrenamientos Realizados', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Revisar distancias, ritmos y sensaciones'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.deepOrange),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConsultarEntrenamientosView(idUsuario: widget.atleta.idUsuario),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeccionDiagnostico() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _futureDiagnostico,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error al consultar diagnóstico: ${snapshot.error}'),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este atleta aún no ha respondido el cuestionario diagnóstico.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final planMap = data['plan'] as Map<String, dynamic>?;
        final nombrePlan = planMap?['nombre'] ?? 'Plan ID: ${data['planasignado']}';
        final objetivo = data['pruebaobjetivo'] ?? 'No definido';

        return Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.teal.shade800, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Plan Sugerido por el Sistema',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(nombrePlan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Objetivo: $objetivo', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCardPregunta(
              'Pregunta 1: ¿Corre 5k en < 30 min?',
              data['respuesta_1']?.toString() ?? 'Sin respuesta',
            ),
            const SizedBox(height: 8),
            _buildCardPregunta(
              'Pregunta 2: ¿Corre 5k en < 25 min?',
              data['respuesta_2']?.toString() ?? 'No requerida',
            ),
            const SizedBox(height: 8),
            _buildCardPregunta(
              'Pregunta 3: Distancia objetivo',
              data['respuesta_3']?.toString() ?? 'No requerida',
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilaInfo(String label, String valor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardPregunta(String pregunta, String respuesta) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(pregunta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                respuesta,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}