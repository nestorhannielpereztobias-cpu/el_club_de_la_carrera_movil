import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/ubicacion_service.dart';

class MapaUbicacionView extends StatefulWidget {
  const MapaUbicacionView({super.key});

  @override
  State<MapaUbicacionView> createState() => _MapaUbicacionViewState();
}

class _MapaUbicacionViewState extends State<MapaUbicacionView> {
  final UbicacionService _ubicacionService = UbicacionService();
  final MapController _mapController = MapController();
  
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _guardando = false;

  // Coordenadas iniciales (por defecto centro de México o punto de referencia)
  LatLng _puntoSeleccionado = const LatLng(22.1565, -100.9855);

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarPunto() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el punto de entrenamiento')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await _ubicacionService.registrarPuntoUbicacion(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        latitud: _puntoSeleccionado.latitude,
        longitud: _puntoSeleccionado.longitude,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Punto de entrenamiento guardado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar ubicación: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Mapa interactivo
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _puntoSeleccionado,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _puntoSeleccionado = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.elclubdelacarrera.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _puntoSeleccionado,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        size: 45,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Formulario de registro de ubicación
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Coordenadas: ${_puntoSeleccionado.latitude.toStringAsFixed(4)}, ${_puntoSeleccionado.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Punto de Encuentro *',
                      hintText: 'Ej. Pista de Atletismo / Parque Principal',
                      prefixIcon: const Icon(Icons.place, color: Colors.deepOrange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción o Referencias',
                      hintText: 'Ej. Nos vemos junto a la entrada principal',
                      prefixIcon: const Icon(Icons.description, color: Colors.deepOrange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _guardando ? null : _guardarPunto,
                    child: _guardando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Guardar Punto de Ubicación',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}