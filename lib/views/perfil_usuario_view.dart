import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class PerfilUsuarioView extends StatelessWidget {
  final UsuarioModel usuario;

  const PerfilUsuarioView({super.key, required this.usuario});

  // Cálculo de edad
  int _calcularEdad(DateTime? fecha) {
    if (fecha == null) return 0;
    final hoy = DateTime.now();
    int edad = hoy.year - fecha.year;
    if (hoy.month < fecha.month ||
        (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad--;
    }
    return edad;
  }

  // Formato DD / MM / AAAA
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No registrado';
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia / $mes / $anio';
  }

  // Nombre legible del género
  String _obtenerGeneroTexto(String? g) {
    if (g == 'H') return 'Hombre';
    if (g == 'M') return 'Mujer';
    return g ?? 'No especificado';
  }

  // Cálculo de categoría atlética
  String _determinarCategoria(int edad, String? genero) {
    final sufijo = (genero == 'H') ? 'Varonil' : (genero == 'M' ? 'Femenil' : '');
    
    if (edad < 18) {
      return 'Juvenil $sufijo';
    } else if (edad <= 39) {
      return 'Libre $sufijo (18-39)';
    } else if (edad <= 49) {
      return 'Master $sufijo (40-49)';
    } else if (edad <= 59) {
      return 'Veteranos $sufijo (50-59)';
    } else {
      return 'Veteranos Plus $sufijo (60+)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final edad = _calcularEdad(usuario.fechaNacimiento);
    final categoria = _determinarCategoria(edad, usuario.genero);

    const colorAzulOscuro = Color(0xFF0D253F);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Botón Volver al Panel
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF0056B3)),
                  label: const Text(
                    'Volver al Panel',
                    style: TextStyle(
                      color: Color(0xFF0056B3),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Título Principal
              const Text(
                'MIS DATOS PERSONALES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: colorAzulOscuro,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta Blanca con Borde Superior
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      // Barra superior azul marino
                      Container(
                        height: 5,
                        color: colorAzulOscuro,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                        child: Column(
                          children: [
                            // Fila: Nombre y Apellido
                            Row(
                              children: [
                                Expanded(child: _buildDatoItem('NOMBRE', usuario.nombre)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDatoItem('APELLIDO', usuario.apellido)),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Fila: Correo Electrónico
                            Row(
                              children: [
                                Expanded(child: _buildDatoItem('CORREO ELECTRÓNICO', usuario.correo)),
                                const SizedBox(width: 16),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Fila: Fecha de Nacimiento y Género
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDatoItem(
                                    'FECHA DE NACIMIENTO',
                                    _formatearFecha(usuario.fechaNacimiento),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDatoItem(
                                    'GÉNERO',
                                    _obtenerGeneroTexto(usuario.genero),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE9ECEF), thickness: 1),
                            const SizedBox(height: 16),

                            // Fila: Edad y Categoría
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDatoItem(
                                    'EDAD',
                                    usuario.fechaNacimiento != null ? '$edad años' : 'N/A',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDatoItem('CATEGORÍA', categoria),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // Píldora "Información Verificada"
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFFDCE2E6)),
                              ),
                              child: const Text(
                                'Información Verificada',
                                style: TextStyle(
                                  color: Color(0xFF5A6E7F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para cada celda de dato
  Widget _buildDatoItem(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF55606E),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valor.isNotEmpty ? valor : '-',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: Color(0xFFE9ECEF), thickness: 1, height: 1),
      ],
    );
  }
}