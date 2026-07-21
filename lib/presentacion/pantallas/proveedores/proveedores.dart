import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'agregarProveedor.dart';

// NOTA: agrega esta dependencia en tu pubspec.yaml si no la tienes:
//   share_plus: ^7.2.0
// (ya no se necesita path_provider: la exportación se hace en memoria,
//  compatible con Web, macOS, iOS y Android sin distinción)

/// ---------------------------------------------------------------------
/// ESQUEMA SUPABASE (según tu diagrama):
///
/// create table categorias (
///   id serial primary key,
///   nombre varchar(100) not null
/// );
///
/// create table proveedores (
///   id serial primary key,
///   nombre varchar(150) not null,
///   contacto varchar(150),
///   telefono varchar(20),
///   estado varchar(50) default 'Activo',
///   categoria_id int references categorias(id),
///   fecha_registro timestamp default now()
/// );
///
/// -- (Opcional) Activa RLS y agrega políticas según tu caso de uso.
/// ---------------------------------------------------------------------

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final _supabase = Supabase.instance.client;

  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color toolbarBg = const Color(0xFFF0F6FB);

  dynamic _filtroSeleccionado = 'todos'; // 'todos' | 'activos' | <int categoria_id>
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';

  // --- DATOS ---
  List<Map<String, dynamic>> _proveedoresRaw = []; // Lista plana traída de Supabase (con join a categorias)
  List<Map<String, dynamic>> _categoriasCatalogo = []; // Catálogo de la tabla 'categorias'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(() {
      setState(() => _busqueda = _searchController.text);
    });
  }

  Future<void> _cargarDatos() async {
    await Future.wait([_cargarCategorias(), _cargarProveedores()]);
  }

  Future<void> _cargarCategorias() async {
    try {
      final data = await _supabase.from('categorias').select('id, nombre').order('nombre');
      setState(() => _categoriasCatalogo = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      _mostrarSnack('Error al cargar categorías: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- CARGA DESDE SUPABASE ---
  // categorias(nombre) trae el nombre de la categoría relacionada vía categoria_id (FK)
  Future<void> _cargarProveedores() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('proveedores')
          .select('id, nombre, contacto, telefono, estado, categoria_id, fecha_registro, categorias(id, nombre)')
          .order('nombre', ascending: true);

      setState(() {
        _proveedoresRaw = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      _mostrarSnack('Error al cargar proveedores: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // (La inserción de nuevos proveedores ahora vive en AgregarProveedorScreen)

  // --- ACTUALIZAR ESTADO ---
  Future<void> _actualizarEstado(int id, String nuevoEstado) async {
    try {
      await _supabase.from('proveedores').update({'estado': nuevoEstado}).eq('id', id);
      _mostrarSnack('Estado actualizado.', const Color(0xFF2E9E8A));
      await _cargarProveedores();
    } catch (e) {
      _mostrarSnack('Error al actualizar estado: $e', Colors.red);
    }
  }

  // --- ELIMINAR PROVEEDOR ---
  Future<void> _eliminarProveedor(int id, String nombre) async {
    try {
      await _supabase.from('proveedores').delete().eq('id', id);
      _mostrarSnack('Proveedor "$nombre" eliminado.', Colors.orange);
      await _cargarProveedores();
    } catch (e) {
      _mostrarSnack('Error al eliminar proveedor: $e', Colors.red);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // --- EXPORTAR PROVEEDORES A CSV ---
  // Exporta la lista actualmente visible (respeta el buscador y el filtro activo).
  Future<void> _exportarProveedoresCSV() async {
    final categorias = _categoriasFiltradas;
    final List<Map<String, dynamic>> proveedoresAExportar = [
      for (var cat in categorias) ...List<Map<String, dynamic>>.from(cat['proveedores'])
    ];

    if (proveedoresAExportar.isEmpty) {
      _mostrarSnack('No hay proveedores para exportar con el filtro actual.', Colors.orange);
      return;
    }

    try {
      final buffer = StringBuffer();
      buffer.writeln('Nombre,Categoria,Contacto,Telefono,Estado,Fecha de registro');
      for (var p in proveedoresAExportar) {
        final fecha = p['fecha_registro'] != null ? p['fecha_registro'].toString().substring(0, 10) : '';
        buffer.writeln([
          _csvEscape(p['nombre']),
          _csvEscape(_nombreCategoria(p)),
          _csvEscape(p['contacto']),
          _csvEscape(p['telefono']),
          _csvEscape(p['estado']),
          _csvEscape(fecha),
        ].join(','));
      }

      final nombreArchivo = 'proveedores_${DateTime.now().millisecondsSinceEpoch}.csv';
      final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
      final archivo = XFile.fromData(bytes, name: nombreArchivo, mimeType: 'text/csv');

      await Share.shareXFiles([archivo], text: 'Listado de proveedores - CleanStock');
    } catch (e) {
      _mostrarSnack('Error al exportar proveedores: $e', Colors.red);
    }
  }

  String _csvEscape(dynamic valor) {
    final texto = (valor ?? '').toString().replaceAll('"', '""');
    return '"$texto"';
  }

  // --- HELPERS DE PRESENTACIÓN ---
  String _nombreCategoria(Map<String, dynamic> prov) {
    final cat = prov['categorias'];
    if (cat is Map && cat['nombre'] != null) return cat['nombre'].toString();
    return 'Sin categoría';
  }

  String _emojiPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'limpieza':
        return '🧼';
      case 'comida':
        return '🍎';
      case 'dulces':
        return '🍬';
      default:
        return '📦';
    }
  }

  Color _colorPorEstado(String estado) {
    return estado == 'Activo' ? const Color(0xFF2E9E8A) : const Color(0xFFE0A72E);
  }

  // --- FILTRADO + AGRUPADO ---
  List<Map<String, dynamic>> get _categoriasFiltradas {
    List<Map<String, dynamic>> filtrados = _proveedoresRaw.where((p) {
      final nombreCat = _nombreCategoria(p);
      final coincideBusqueda = _busqueda.isEmpty ||
          (p['nombre'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
          nombreCat.toLowerCase().contains(_busqueda.toLowerCase());

      bool coincideFiltro;
      if (_filtroSeleccionado == 'todos') {
        coincideFiltro = true;
      } else if (_filtroSeleccionado == 'activos') {
        coincideFiltro = p['estado'] == 'Activo';
      } else if (_filtroSeleccionado is int) {
        coincideFiltro = p['categoria_id'] == _filtroSeleccionado;
      } else {
        coincideFiltro = true;
      }
      return coincideBusqueda && coincideFiltro;
    }).toList();

    // Agrupar por categoría
    Map<String, List<Map<String, dynamic>>> agrupado = {};
    for (var prov in filtrados) {
      final cat = _nombreCategoria(prov);
      agrupado.putIfAbsent(cat, () => []).add(prov);
    }

    return agrupado.entries.map((e) {
      return {
        'emoji': _emojiPorCategoria(e.key),
        'nombre': e.key,
        'proveedores': e.value,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildTablaProveedores()),
        ],
      ),
    );
  }

  // --- APPBAR ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: borderLight, height: 0.5),
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
          Text('Proveedores', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: primaryLight),
          onPressed: _cargarDatos,
          tooltip: 'Recargar',
        ),
        IconButton(
          icon: Icon(Icons.download, color: primaryLight),
          onPressed: _exportarProveedoresCSV,
          tooltip: 'Descargar CSV',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProveedorFormScreen()),
              );
              if (resultado == true) {
                _cargarDatos();
              }
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Agregar proveedor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryLight,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // --- TOOLBAR ---
  Widget _buildToolbar() {
    return Container(
      color: toolbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Buscador (conectado a _busqueda)
          Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: primaryDark, fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Buscar proveedor o categoría...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Filtros (dinámicos: Todos, Activos + una pill por cada categoría real)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroPill('Todos', 'todos'),
                  const SizedBox(width: 8),
                  _buildFiltroPill('Activos', 'activos'),
                  for (var cat in _categoriasCatalogo) ...[
                    const SizedBox(width: 8),
                    _buildFiltroPill(cat['nombre'].toString(), cat['id'] as int),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroPill(String texto, dynamic valor) {
    bool activo = _filtroSeleccionado == valor;
    return InkWell(
      onTap: () => setState(() => _filtroSeleccionado = valor),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? primaryLight : Colors.white,
          border: Border.all(color: activo ? primaryLight : borderLight, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(texto, style: TextStyle(color: activo ? Colors.white : primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- TABLA DE PROVEEDORES ---
  Widget _buildTablaProveedores() {
    final categorias = _categoriasFiltradas;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header Tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
            child: Row(
              children: [
                Expanded(flex: 20, child: _thText('CATEGORÍA / PROVEEDOR', color: borderLight)),
                Expanded(flex: 14, child: _thText('PROVEEDOR', color: borderLight)),
                Expanded(flex: 14, child: _thText('TELÉFONO', color: borderLight)),
                Expanded(flex: 10, child: _thText('ESTADO', color: borderLight, align: TextAlign.center)),
                const SizedBox(width: 80, child: Text('DETALLE', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFADCBE3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              ],
            ),
          ),

          // Cuerpo de la Tabla
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : categorias.isEmpty
                    ? _buildEstadoVacio()
                    : ListView(
                        children: _construirFilasDinamicas(categorias),
                      ),
          ),

          // Footer Estadístico
          _buildFooterEstadistico(categorias),
        ],
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left, required Color color}) {
    return Text(text, textAlign: align, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  // --- DISEÑO DE ESTADO VACÍO ---
  Widget _buildEstadoVacio() {
    final hayFiltroOBusqueda = _filtroSeleccionado != 'todos' || _busqueda.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: borderLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            hayFiltroOBusqueda ? 'No hay proveedores que coincidan' : 'Aún no hay proveedores registrados',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hayFiltroOBusqueda ? 'Prueba con otro filtro o término de búsqueda.' : 'Agrega uno nuevo con el botón de arriba.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Widget> _construirFilasDinamicas(List<Map<String, dynamic>> categorias) {
    List<Widget> filas = [];
    for (var cat in categorias) {
      filas.add(_buildFilaCategoria(cat['emoji'], cat['nombre'], cat['proveedores'].length));
      List<dynamic> provs = cat['proveedores'];
      for (int i = 0; i < provs.length; i++) {
        bool isEven = i % 2 == 0;
        filas.add(_buildFilaProveedor(provs[i], isEven));
      }
    }
    return filas;
  }

  Widget _buildFilaCategoria(String emoji, String nombre, int cantidad) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFDEEEF8), border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5))),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(nombre, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: borderLight, borderRadius: BorderRadius.circular(6)),
            child: Text('$cantidad proveedores', style: TextStyle(color: primaryDark, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaProveedor(Map<String, dynamic> prov, bool isEven) {
    bool isReview = prov['estado'] != 'Activo';
    final colorPunto = _colorPorEstado(prov['estado'] ?? 'Activo');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FBFD),
        border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: colorPunto, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(prov['nombre'] ?? '', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 14, child: Text(prov['contacto'] ?? '-', style: TextStyle(color: textMuted, fontSize: 11))),
          Expanded(flex: 14, child: Text(prov['telefono'] ?? '-', style: TextStyle(color: textMuted, fontSize: 11))),
          Expanded(
            flex: 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isReview ? const Color(0xFFFFF3E0) : const Color(0xFFD6F0EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  prov['estado'] ?? 'Activo',
                  style: TextStyle(color: isReview ? const Color(0xFF854F0B) : const Color(0xFF0F6E56), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _abrirDetalleProveedor(prov),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.chevron_right, size: 16, color: primaryLight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER ESTADÍSTICO ---
  Widget _buildFooterEstadistico(List<Map<String, dynamic>> categorias) {
    int totalProveedores = 0;
    for (var cat in categorias) {
      totalProveedores += (cat['proveedores'] as List).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 14, color: borderLight),
              const SizedBox(width: 6),
              Text('Total · ', style: TextStyle(color: borderLight, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('${categorias.length} categorías', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text('$totalProveedores proveedores', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Icon(Icons.local_shipping, size: 14, color: borderLight),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DETALLE / EDITAR ESTADO / ELIMINAR
  // ---------------------------------------------------------------------
  void _abrirDetalleProveedor(Map<String, dynamic> prov) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(prov['nombre'] ?? '', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _filaDetalle('Categoría', _nombreCategoria(prov)),
                _filaDetalle('Contacto', prov['contacto'] ?? '-'),
                _filaDetalle('Teléfono', prov['telefono'] ?? '-'),
                _filaDetalle('Estado', prov['estado'] ?? '-'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarEliminar(prov);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final recargar = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => ProveedorFormScreen(proveedorAEditar: prov)),
                );
                if (recargar == true) _cargarProveedores();
              },
              child: const Text('Editar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _filaDetalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(valor, style: TextStyle(color: primaryDark, fontSize: 13))),
        ],
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> prov) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('¿Eliminar proveedor?'),
        content: Text('Esta acción eliminará a "${prov['nombre']}" permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _eliminarProveedor(prov['id'], prov['nombre'] ?? '');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
