import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla reutilizable para agregar o editar un proveedor.
class ProveedorFormScreen extends StatefulWidget {
  final Map<String, dynamic>? proveedorAEditar;

  const ProveedorFormScreen({super.key, this.proveedorAEditar});

  @override
  State<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);

  // --- CONTROLADORES ---
  final _nombreCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  String _estadoSeleccionado = 'Activo';
  int? _categoriaIdSeleccionada;

  // --- CATÁLOGO ---
  List<Map<String, dynamic>> _categorias = [];
  bool _cargandoCategorias = true;
  bool _guardando = false;

  bool get _esEdicion => widget.proveedorAEditar != null;

  @override
  void initState() {
    super.initState();
    _cargarCategoriasYPrellenar();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contactoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCategoriasYPrellenar() async {
    try {
      final data = await _supabase.from('categorias').select('id, nombre').order('nombre');
      final lista = List<Map<String, dynamic>>.from(data);
      
      setState(() {
        _categorias = lista;
        
        if (_esEdicion) {
          final p = widget.proveedorAEditar!;
          _nombreCtrl.text = p['nombre'] ?? '';
          _contactoCtrl.text = p['contacto'] ?? '';
          _telefonoCtrl.text = p['telefono'] ?? '';
          _estadoSeleccionado = p['estado'] ?? 'Activo';
          _categoriaIdSeleccionada = p['categoria_id'] as int?;
        } else {
          _categoriaIdSeleccionada = lista.isNotEmpty ? lista.first['id'] as int : null;
        }
        _cargandoCategorias = false;
      });
    } catch (e) {
      _mostrarSnack('Error al cargar datos: $e', Colors.red);
      setState(() => _cargandoCategorias = false);
    }
  }

  // --- NUEVA CATEGORÍA ---
  Future<void> _crearNuevaCategoria() async {
    final ctrl = TextEditingController();
    final nuevaCat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );

    if (nuevaCat != null && nuevaCat.isNotEmpty) {
      try {
        await _supabase.from('categorias').insert({'nombre': nuevaCat});
        _cargarCategoriasYPrellenar();
        _mostrarSnack('Categoría creada', Colors.green);
      } catch (e) {
        _mostrarSnack('Error: $e', Colors.red);
      }
    }
  }

  Future<void> _guardarProveedor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaIdSeleccionada == null) {
      _mostrarSnack('Selecciona una categoría.', Colors.orange);
      return;
    }

    setState(() => _guardando = true);
    try {
      final payload = {
        'nombre': _nombreCtrl.text.trim(),
        'contacto': _contactoCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'estado': _estadoSeleccionado,
        'categoria_id': _categoriaIdSeleccionada,
      };

      if (_esEdicion) {
        await _supabase.from('proveedores').update(payload).eq('id', widget.proveedorAEditar!['id']);
      } else {
        await _supabase.from('proveedores').insert(payload);
      }

      if (!mounted) return;
      _mostrarSnack('Proveedor guardado correctamente.', const Color(0xFF2E9E8A));
      Navigator.pop(context, true); // true = recarga
    } catch (e) {
      _mostrarSnack('Error al guardar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        title: Text(_esEdicion ? 'Editar Proveedor' : 'Agregar Proveedor', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
      ),
      body: _cargandoCategorias 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                      validator: (val) => (val?.isEmpty ?? true) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactoCtrl,
                      decoration: const InputDecoration(labelText: 'Empresa', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _categoriaIdSeleccionada,
                      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      items: _categorias.map((cat) => DropdownMenuItem(value: cat['id'] as int, child: Text(cat['nombre']))).toList(),
                      onChanged: (val) => setState(() => _categoriaIdSeleccionada = val),
                    ),
                    IconButton(
                      onPressed: _crearNuevaCategoria,
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Nueva categoría',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                      items: ['Activo', 'Inactivo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardarProveedor,
                      child: _guardando ? const CircularProgressIndicator(color: Colors.white) : Text(_esEdicion ? 'Actualizar' : 'Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
