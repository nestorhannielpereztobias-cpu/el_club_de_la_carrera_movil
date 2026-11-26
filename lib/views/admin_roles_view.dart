import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import 'login_view.dart';

const List<String> kRoles = ['atleta', 'entrenador', 'administrador'];

class AdminRolesService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final data = await _db
        .from('usuario')
        .select('idusuario, nombre, apellido, correo, rol')
        .order('nombre');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> cambiarRol(String idusuario, String nuevoRol) async {
    await _db
        .from('usuario')
        .update({'rol': nuevoRol}).eq('idusuario', idusuario);
  }
}

class AdminRolesView extends StatefulWidget {
  final UsuarioModel usuario;
  const AdminRolesView({super.key, required this.usuario});

  @override
  State<AdminRolesView> createState() => _AdminRolesViewState();
}

class _AdminRolesViewState extends State<AdminRolesView> {
  final _service = AdminRolesService();
  final _busquedaCtrl = TextEditingController();
  List<Map<String, dynamic>> _usuarios = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final u = await _service.listarUsuarios();
      if (mounted) setState(() => _usuarios = u);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo cargar la lista: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarRol(Map<String, dynamic> u, String nuevoRol) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cambio de rol'),
        content: Text(
            '¿Cambiar a ${u['nombre']} ${u['apellido']} de "${u['rol']}" a "$nuevoRol"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.cambiarRol(u['idusuario'] as String, nuevoRol);
      if (!mounted) return;
      setState(() => u['rol'] = nuevoRol);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Rol actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtro = _busquedaCtrl.text.toLowerCase();
    final visibles = _usuarios.where((u) {
      final texto =
          '${u['nombre']} ${u['apellido']} ${u['correo']}'.toLowerCase();
      return texto.contains(filtro);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar roles'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _cerrarSesion, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por nombre o correo',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : ListView.separated(
                        itemCount: visibles.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final u = visibles[i];
                          final esYo =
                              u['idusuario'] == widget.usuario.idUsuario;
                          final rolActual =
                              (u['rol'] as String).trim().toLowerCase();
                          return ListTile(
                            title: Text('${u['nombre']} ${u['apellido']}'),
                            subtitle: Text('${u['correo']}'),
                            trailing: esYo
                                ? const Chip(label: Text('Tú (admin)'))
                                : DropdownButton<String>(
                                    value: kRoles.contains(rolActual)
                                        ? rolActual
                                        : null,
                                    items: kRoles
                                        .map((r) => DropdownMenuItem(
                                            value: r, child: Text(r)))
                                        .toList(),
                                    onChanged: (nuevo) {
                                      if (nuevo != null && nuevo != rolActual) {
                                        _cambiarRol(u, nuevo);
                                      }
                                    },
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}