import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/entrenador_service.dart';
import 'detalle_atleta_view.dart';

class ListaAtletasView extends StatefulWidget {
  const ListaAtletasView({super.key});

  @override
  State<ListaAtletasView> createState() => _ListaAtletasViewState();
}

class _ListaAtletasViewState extends State<ListaAtletasView> {
  final EntrenadorService _service = EntrenadorService();
  late Future<List<UsuarioModel>> _futureAtletas;
  List<UsuarioModel> _atletasCache = [];
  List<UsuarioModel> _atletasFiltrados = [];
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarAtletas();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _cargarAtletas() {
    setState(() {
      _futureAtletas = _service.obtenerAtletas().then((lista) {
        _atletasCache = lista;
        _atletasFiltrados = lista;
        return lista;
      });
    });
  }

  void _filtrarAtletas(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _atletasFiltrados = _atletasCache.where((a) {
        final nombreCompleto = "${a.nombre} ${a.apellido}".toLowerCase();
        return nombreCompleto.contains(lower) || a.correo.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Atletas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarAtletas(),
        color: Colors.deepOrange,
        child: FutureBuilder<List<UsuarioModel>>(
          future: _futureAtletas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error al cargar atletas: ${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _cargarAtletas, child: const Text('Reintentar')),
                    ],
                  ),
                ),
              );
            }

            if (_atletasCache.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.group_off_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(child: Text('No hay atletas registrados aún.', style: TextStyle(fontSize: 16, color: Colors.grey))),
                ],
              );
            }

            return Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar atleta por nombre o correo...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                      suffixIcon: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _busquedaController.clear();
                                _filtrarAtletas('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: _filtrarAtletas,
                  ),
                ),
                // Lista de tarjetas
                Expanded(
                  child: _atletasFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron atletas.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _atletasFiltrados.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final atleta = _atletasFiltrados[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepOrange,
                                  child: Text(
                                    atleta.nombre.isNotEmpty ? atleta.nombre[0].toUpperCase() : 'A',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  '${atleta.nombre} ${atleta.apellido}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(atleta.correo, style: const TextStyle(fontSize: 12)),
                                trailing: const Icon(Icons.chevron_right, color: Colors.deepOrange),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetalleAtletaView(atleta: atleta),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}