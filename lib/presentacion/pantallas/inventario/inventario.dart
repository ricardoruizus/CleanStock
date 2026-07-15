import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'agregar_producto.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color toolbarBg = const Color(0xFFF0F6FB);

  final _supabase = Supabase.instance.client;

  int _filtroActivo = 0; // 0: Todos, 1: Activos, 2: Bajo stock, 3: Agotado
  String _busquedaQuery = ''; // Almacena el texto del buscador
  final _searchController = TextEditingController();

  // --- DATOS DE SUPABASE ---
  List<Map<String, dynamic>> _productosRaw = []; // Datos puros de BD
  List<Map<String, dynamic>> _productosProcesados = []; // Datos con estilos y filtros aplicados
  bool _isDbLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  //            OPERACIONES CRUD (BD)
  // ==========================================

  // [READ] Obtener productos
  Future<void> _cargarProductos() async {
    setState(() => _isDbLoading = true);
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .order('nombre', ascending: true);

      _productosRaw = List<Map<String, dynamic>>.from(response);
      _procesarYFiltrarDatos();
    } catch (e) {
      _mostrarSnack('Error al cargar inventario: $e', Colors.redAccent);
    } finally {
      setState(() => _isDbLoading = false);
    }
  }

  // [UPDATE] Editar producto rápidamente
  Future<void> _editarProducto(Map<String, dynamic> prod) async {
    final nombreCtrl = TextEditingController(text: prod['nombre']);
    final precioCtrl = TextEditingController(text: prod['precio'].toString());
    final stockCtrl = TextEditingController(text: prod['stock'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar ${prod['nombre']}', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryLight),
              onPressed: () async {
                try {
                  final nuevoPrecio = double.tryParse(precioCtrl.text) ?? prod['precio'];
                  final nuevoStock = int.tryParse(stockCtrl.text) ?? prod['stock'];
                  final nuevoNombre = nombreCtrl.text.trim();

                  await _supabase.from('productos').update({
                    'nombre': nuevoNombre,
                    'precio': nuevoPrecio,
                    'stock': nuevoStock,
                  }).eq('id', prod['id']); // Asegúrate de que tu tabla use 'id' como llave primaria

                  Navigator.pop(context);
                  _mostrarSnack('Producto actualizado', const Color(0xFF2E9E8A));
                  _cargarProductos();
                } catch (e) {
                  _mostrarSnack('Error al actualizar: $e', Colors.redAccent);
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // [DELETE] Eliminar producto
  Future<void> _eliminarProducto(Map<String, dynamic> prod) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text('¿Estás seguro de que deseas eliminar "${prod['nombre']}" del inventario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _supabase.from('productos').delete().eq('id', prod['id']);
        _mostrarSnack('Producto eliminado', const Color(0xFF2E9E8A));
        _cargarProductos();
      } catch (e) {
        _mostrarSnack('Error al eliminar: $e', Colors.redAccent);
      }
    }
  }

  // ==========================================
  //     LÓGICA DE PROCESAMIENTO Y FILTROS
  // ==========================================

  void _procesarYFiltrarDatos() {
    List<Map<String, dynamic>> temporal = [];

    for (var prod in _productosRaw) {
      // 1. Calcular dinámicamente el estado y sus colores de UI
      int stock = prod['stock'] ?? 0;
      double precio = (prod['precio'] as num?)?.toDouble() ?? 0.0;
      String nombre = prod['nombre'] ?? 'Sin nombre';
      String fecha = prod['creado_en'] != null 
          ? prod['creado_en'].toString().substring(0, 10) 
          : 'Sin fecha';

      String estado = 'Activo';
      Color colorBadgeBg = const Color(0xFFE2F9F3);
      Color colorBadgeTxt = const Color(0xFF1E856D);
      Color colorIcono = primaryLight;
      IconData icono = Icons.inventory_2;

      if (stock == 0) {
        estado = 'Agotado';
        colorBadgeBg = const Color(0xFFFCE8E6);
        colorBadgeTxt = const Color(0xFFC53030);
        colorIcono = Colors.redAccent;
        icono = Icons.cancel;
      } else if (stock <= 5) {
        estado = 'Bajo stock';
        colorBadgeBg = const Color(0xFFFFF3E0);
        colorBadgeTxt = const Color(0xFFC43E00);
        colorIcono = Colors.orangeAccent;
        icono = Icons.warning;
      }

      // Crear mapa enriquecido con datos visuales para CleanStock
      final itemProcesado = {
        'id': prod['id'],
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'estado': estado,
        'fecha': fecha,
        'colorBadgeBg': colorBadgeBg,
        'colorBadgeTxt': colorBadgeTxt,
        'colorIcono': colorIcono,
        'icono': icono,
      };

      // 2. Aplicar buscador de texto
      if (_busquedaQuery.isNotEmpty && 
          !nombre.toLowerCase().contains(_busquedaQuery.toLowerCase())) {
        continue; // Ignorar si no coincide
      }

      // 3. Aplicar filtro de barra superior
      if (_filtroActivo == 1 && estado != 'Activo') continue;
      if (_filtroActivo == 2 && estado != 'Bajo stock') continue;
      if (_filtroActivo == 3 && estado != 'Agotado') continue;

      temporal.add(itemProcesado);
    }

    setState(() {
      _productosProcesados = temporal;
    });
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
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildTablaInventario()),
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
          Text('Inventario', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: primaryLight), 
          onPressed: _cargarProductos, // Botón de recarga manual
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              // [CREATE] Navegar y refrescar al regresar
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarProductoScreen()),
              );
              _cargarProductos(); // Se recarga cuando el usuario regresa de agregar
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Agregar producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    int totalProductos = _productosRaw.length;
    int totalAlertas = _productosRaw.where((p) => (p['stock'] ?? 0) <= 5).length;

    return Container(
      color: toolbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Buscador dinámico funcional
              Container(
                width: 200,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white, 
                  border: Border.all(color: borderLight, width: 0.5), 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: primaryDark, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: 16, color: textMuted),
                    hintText: 'Buscar producto...',
                    hintStyle: TextStyle(color: textMuted, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    _busquedaQuery = val;
                    _procesarYFiltrarDatos();
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Filtros
              _buildFiltroPill('Todos', 0),
              const SizedBox(width: 8),
              _buildFiltroPill('Activos', 1),
              const SizedBox(width: 8),
              _buildFiltroPill('Bajo stock', 2),
              const SizedBox(width: 8),
              _buildFiltroPill('Agotado', 3),
            ],
          ),
          Row(
            children: [
              _buildStatChip(Icons.inventory_2, '$totalProductos productos'),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.warning_amber_rounded, 
                '$totalAlertas alertas',
                colorTexto: totalAlertas > 0 ? const Color(0xFF854F0B) : primaryLight,
                colorFondo: totalAlertas > 0 ? const Color(0xFFFFF3E0) : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroPill(String texto, int index) {
    bool activo = _filtroActivo == index;
    return InkWell(
      onTap: () {
        setState(() => _filtroActivo = index);
        _procesarYFiltrarDatos();
      },
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

  Widget _buildStatChip(IconData icono, String texto, {Color? colorTexto, Color? colorFondo}) {
    Color txtColor = colorTexto ?? primaryLight;
    Color bgColor = colorFondo ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: txtColor.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icono, size: 12, color: txtColor),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: txtColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- TABLA DE INVENTARIO ---
  Widget _buildTablaInventario() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFDDEAF5), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Expanded(flex: 28, child: _thText('PRODUCTO')),
                Expanded(flex: 16, child: _thText('PRECIO', align: TextAlign.center)),
                Expanded(flex: 16, child: _thText('STOCK', align: TextAlign.center)),
                Expanded(flex: 20, child: _thText('ESTADO', align: TextAlign.center)),
                Expanded(flex: 15, child: _thText('FECHA', align: TextAlign.center)),
                Expanded(flex: 10, child: _thText('ACCIONES', align: TextAlign.center)),
              ],
            ),
          ),
          
          // Cuerpo de la Tabla dinámico
          Expanded(
            child: _isDbLoading
                ? const Center(child: CircularProgressIndicator())
                : _productosProcesados.isEmpty
                    ? _buildEstadoVacio()
                    : ListView.builder(
                        itemCount: _productosProcesados.length,
                        itemBuilder: (context, index) {
                          var prod = _productosProcesados[index];
                          bool isEven = index % 2 == 0;
                          return _buildFilaTabla(prod, isEven);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text, textAlign: align, style: TextStyle(color: primaryLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  // --- DISEÑO DE ESTADO VACÍO ---
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: borderLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No hay productos que coincidan',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba cambiando los filtros o agrega un producto nuevo.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- FILA DINÁMICA CON EDITAR Y ELIMINAR ---
  Widget _buildFilaTabla(Map<String, dynamic> prod, bool isEven) {
    IconData iconEstado = Icons.circle;
    if (prod['estado'] == 'Bajo stock') iconEstado = Icons.arrow_drop_up;
    if (prod['estado'] == 'Agotado') iconEstado = Icons.close;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF5F9FD),
        border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          // Producto
          Expanded(
            flex: 28,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: prod['colorIcono'], borderRadius: BorderRadius.circular(6)),
                  child: Icon(prod['icono'], color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(prod['nombre'], style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          // Precio
          Expanded(
            flex: 16,
            child: Text('\$${prod['precio'].toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: primaryDark, fontSize: 12)),
          ),
          // Stock
          Expanded(
            flex: 16,
            child: Text('${prod['stock']} uds', textAlign: TextAlign.center, style: TextStyle(color: primaryDark, fontSize: 12)),
          ),
          // Estado (Badge)
          Expanded(
            flex: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: prod['colorBadgeBg'], borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconEstado, size: 10, color: prod['colorBadgeTxt']),
                    const SizedBox(width: 4),
                    Text(prod['estado'], style: TextStyle(color: prod['colorBadgeTxt'], fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          // Fecha
          Expanded(
            flex: 15,
            child: Text(prod['fecha'], textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 11)),
          ),
          // Acciones rápidas (Editar y Borrar)
          Expanded(
            flex: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.edit_outlined, size: 16, color: primaryLight),
                  onPressed: () => _editarProducto(prod),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  onPressed: () => _eliminarProducto(prod),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}