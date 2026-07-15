import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ---------------------------------------------------------------------
/// Pantalla dedicada para agregar un proveedor nuevo.
/// Inserta directamente en la tabla `proveedores` de Supabase:
///
///   id serial primary key,
///   nombre varchar(150) not null,
///   contacto varchar(150),
///   telefono varchar(20),
///   estado varchar(50) default 'Activo',
///   categoria_id int references categorias(id),
///   fecha_registro timestamp default now()
///
/// Al guardar con éxito, hace Navigator.pop(context, true) para que la
/// pantalla anterior (ProveedoresScreen) sepa que debe recargar la lista.
/// ---------------------------------------------------------------------
class AgregarProveedorScreen extends StatefulWidget {
  const AgregarProveedorScreen({super.key});

  @override
  State<AgregarProveedorScreen> createState() => _AgregarProveedorScreenState();
}

class _AgregarProveedorScreenState extends State<AgregarProveedorScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // --- PALETA DE COLORES (misma que ProveedoresScreen) ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);

  // --- CONTROLADORES DE FORMULARIO ---
  final _nombreCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  String _estadoSeleccionado = 'Activo';
  int? _categoriaIdSeleccionada;

  // --- CATÁLOGO DE CATEGORÍAS ---
  List<Map<String, dynamic>> _categorias = [];
  bool _cargandoCategorias = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contactoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    try {
      final data = await _supabase.from('categorias').select('id, nombre').order('nombre');
      final lista = List<Map<String, dynamic>>.from(data);
      setState(() {
        _categorias = lista;
        _categoriaIdSeleccionada = lista.isNotEmpty ? lista.first['id'] as int : null;
        _cargandoCategorias = false;
      });
    } catch (e) {
      _mostrarSnack('Error al cargar categorías: $e', Colors.red);
      setState(() => _cargandoCategorias = false);
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
      await _supabase.from('proveedores').insert({
        'nombre': _nombreCtrl.text.trim(),
        'contacto': _contactoCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'estado': _estadoSeleccionado,
        'categoria_id': _categoriaIdSeleccionada,
      });

      if (!mounted) return;
      _mostrarSnack('Proveedor "${_nombreCtrl.text.trim()}" agregado correctamente.', const Color(0xFF2E9E8A));
      Navigator.pop(context, true); // true = "hubo cambios, recarga la lista"
    } catch (e) {
      _mostrarSnack('Error al guardar proveedor: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: _cargandoCategorias
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildFormulario(),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: borderLight, height: 0.5),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text('CLEANSTOCK', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(width: 8),
          Text('/', style: TextStyle(color: borderLight)),
          const SizedBox(width: 8),
          Text('Nuevo proveedor', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: primaryLight),
                const SizedBox(width: 8),
                Text('Datos del proveedor', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            _label('Nombre del proveedor'),
            TextFormField(
              controller: _nombreCtrl,
              decoration: _inputDecoration('Ej. Distribuidora del Sureste'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            _label('Categoría'),
            _categorias.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'No hay categorías registradas. Crea una en la tabla "categorias" antes de continuar.',
                      style: TextStyle(color: const Color(0xFF854F0B), fontSize: 12),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    value: _categoriaIdSeleccionada,
                    decoration: _inputDecoration('Selecciona una categoría'),
                    items: _categorias
                        .map((c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['nombre'].toString()),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _categoriaIdSeleccionada = v),
                    validator: (v) => v == null ? 'Selecciona una categoría' : null,
                  ),
            const SizedBox(height: 16),

            _label('Contacto'),
            TextFormField(
              controller: _contactoCtrl,
              decoration: _inputDecoration('Nombre de la persona de contacto'),
            ),
            const SizedBox(height: 16),

            _label('Teléfono'),
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Ej. 999 123 4567'),
            ),
            const SizedBox(height: 16),

            _label('Estado'),
            DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: _inputDecoration(''),
              items: const [
                DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                DropdownMenuItem(value: 'Revisión', child: Text('Revisión')),
              ],
              onChanged: (v) => setState(() => _estadoSeleccionado = v ?? 'Activo'),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancelar', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_guardando || _categorias.isEmpty) ? null : _guardarProveedor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar proveedor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textMuted, fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderLight, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryLight, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 0.5),
      ),
    );
  }
}
