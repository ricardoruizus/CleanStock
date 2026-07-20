import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ventas/ventas.dart';

class RegistroVentasScreen extends StatefulWidget {
  const RegistroVentasScreen({super.key});

  @override
  State<RegistroVentasScreen> createState() => _RegistroVentasScreenState();
}

class _RegistroVentasScreenState extends State<RegistroVentasScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color toolbarBg = const Color(0xFFF0F6FB);

  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  int _filtroActivo = 0; // 0: Todos, 1: Completados, 2: Pendientes, 3: Cancelados
  int _filtroTiempoActivo = 0; // 0: Todos, 1: Hoy, 2: Esta Semana, 3: Este Mes
  String _busquedaQuery = '';
  bool _isLoading = true;

  // --- DATOS ---
  List<Map<String, dynamic>> _ventasRaw = []; 
  List<Map<String, dynamic>> _ventasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  //            OPERACIONES CRUD (BD)
  // ==========================================

  // [READ] Obtener ventas combinando Maestro-Detalle y Producto
  Future<void> _cargarVentas() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('venta_detalles')
          .select('''
            id,
            cantidad,
            precio_unitario,
            subtotal,
            ventas (
              id,
              folio,
              fecha_venta,
              estado
            ),
            productos (
              nombre
            )
          ''');

      _ventasRaw = List<Map<String, dynamic>>.from(response);
      _procesarYFiltrarVentas();
    } catch (e) {
      _mostrarSnack('Error al cargar ventas: $e', Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // [UPDATE] Cambiar el estado de una venta (Completado / Pendiente / Cancelado)
  Future<void> _cambiarEstadoVenta(int ventaId, String nuevoEstado) async {
    try {
      await _supabase
          .from('ventas')
          .update({'estado': nuevoEstado})
          .eq('id', ventaId);

      _mostrarSnack('Estado de la venta actualizado', const Color(0xFF2E9E8A));
      _cargarVentas();
    } catch (e) {
      _mostrarSnack('Error al actualizar estado: $e', Colors.redAccent);
    }
  }

  // [DELETE] Eliminar registro de venta
  Future<void> _eliminarVenta(int ventaId, String folio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('¿Deseas eliminar permanentemente el registro del folio $folio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
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
        await _supabase.from('ventas').delete().eq('id', ventaId);
        _mostrarSnack('Venta eliminada con éxito', const Color(0xFF2E9E8A));
        _cargarVentas();
      } catch (e) {
        _mostrarSnack('Error al eliminar venta: $e', Colors.redAccent);
      }
    }
  }

  // ==========================================
  //         PROCESAMIENTO Y FILTROS
  // ==========================================

  void _procesarYFiltrarVentas() {
    List<Map<String, dynamic>> temp = [];
    final DateTime ahora = DateTime.now();

    for (var item in _ventasRaw) {
      final venta = item['ventas'] as Map<String, dynamic>?;
      final producto = item['productos'] as Map<String, dynamic>?;

      if (venta == null || producto == null) continue;

      String nomProd = producto['nombre'] ?? 'Desconocido';
      String folio = venta['folio'] ?? 'S/F';
      String estado = venta['estado'] ?? 'Pendiente';
      
      // --- CORRECCIÓN DE FECHA (CONVERSIÓN A HORA LOCAL) ---
      String fechaRaw = venta['fecha_venta'] ?? '';
      String fechaStr = 'S/F';
      DateTime? fechaLocal;
      
      if (fechaRaw.isNotEmpty) {
        String fechaParseable = fechaRaw;
        if (!fechaParseable.endsWith('Z') && !fechaParseable.contains('+') && !fechaParseable.contains('-')) {
          fechaParseable = '${fechaParseable.replaceFirst(' ', 'T')}Z';
        }
        fechaLocal = DateTime.parse(fechaParseable).toLocal();
        fechaStr = "${fechaLocal.toString().substring(0, 10)} ${fechaLocal.toString().substring(11, 16)}";
      }

      // --- FILTRO DE BÚSQUEDA ---
      if (_busquedaQuery.isNotEmpty &&
          !nomProd.toLowerCase().contains(_busquedaQuery.toLowerCase()) &&
          !folio.toLowerCase().contains(_busquedaQuery.toLowerCase())) {
        continue;
      }

      // --- FILTRO DE ESTADO ---
      if (_filtroActivo == 1 && estado != 'Completado') continue;
      if (_filtroActivo == 2 && estado != 'Pendiente') continue;
      if (_filtroActivo == 3 && estado != 'Cancelado') continue;

      // --- FILTRO DE TIEMPO (YA USA LA FECHA LOCAL CORRECTA) ---
      if (fechaLocal != null) {
        if (_filtroTiempoActivo == 1) { // HOY
          if (fechaLocal.year != ahora.year || 
              fechaLocal.month != ahora.month || 
              fechaLocal.day != ahora.day) {
            continue;
          }
        } else if (_filtroTiempoActivo == 2) { // ESTA SEMANA (Últimos 7 días)
          final diferenciaDias = ahora.difference(fechaLocal).inDays;
          if (diferenciaDias < 0 || diferenciaDias > 7) {
            continue;
          }
        } else if (_filtroTiempoActivo == 3) { // ESTE MES
          if (fechaLocal.year != ahora.year || fechaLocal.month != ahora.month) {
            continue;
          }
        }
      } else if (_filtroTiempoActivo != 0) {
        continue;
      }

      temp.add({
        'id_detalle': item['id'],
        'id_venta': venta['id'],
        'producto': nomProd,
        'folio': folio,
        'precio': (item['precio_unitario'] as num).toDouble(),
        'cantidad': item['cantidad'] as int,
        'fecha': fechaStr,
        'estado': estado,
      });
    }

    setState(() {
      _ventasFiltradas = temp;
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
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildTablaRegistros(),
          ),
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
          Text('Registro de Ventas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: primaryLight), 
          onPressed: _cargarVentas,
        ),
      ],
    );
  }

  // --- TOOLBAR CON AMBOS FILTROS ---
  Widget _buildToolbar() {
    return Container(
      color: toolbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Barra de búsqueda
              Container(
                width: 240,
                height: 36,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: primaryDark, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: 16, color: textMuted),
                    hintText: 'Buscar producto o folio...',
                    hintStyle: TextStyle(color: textMuted, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    _busquedaQuery = val;
                    _procesarYFiltrarVentas();
                  },
                ),
              ),
              
              // Filtro de Estado
              Row(
                children: [
                  Text('Estado: ', style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  _buildFiltroPill('Todos', 0),
                  const SizedBox(width: 6),
                  _buildFiltroPill('Completados', 1),
                  const SizedBox(width: 6),
                  _buildFiltroPill('Cancelados', 3),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Fila para el Filtro de Tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Período: ', style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              _buildFiltroTiempoPill('Todos', 0),
              const SizedBox(width: 6),
              _buildFiltroTiempoPill('Hoy', 1),
              const SizedBox(width: 6),
              _buildFiltroTiempoPill('Semana', 2),
              const SizedBox(width: 6),
              _buildFiltroTiempoPill('Mes', 3),
            ],
          ),
        ],
      ),
    );
  }

  // Píldoras para filtro de Estado
  Widget _buildFiltroPill(String texto, int index) {
    bool activo = _filtroActivo == index;
    return InkWell(
      onTap: () {
        setState(() => _filtroActivo = index);
        _procesarYFiltrarVentas();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: activo ? primaryLight : Colors.white,
          border: Border.all(color: activo ? primaryLight : borderLight, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(texto, style: TextStyle(color: activo ? Colors.white : primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Píldoras para filtro de Tiempo
  Widget _buildFiltroTiempoPill(String texto, int index) {
    bool activo = _filtroTiempoActivo == index;
    return InkWell(
      onTap: () {
        setState(() => _filtroTiempoActivo = index);
        _procesarYFiltrarVentas();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: activo ? primaryDark : Colors.white,
          border: Border.all(color: activo ? primaryDark : borderLight, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(texto, style: TextStyle(color: activo ? Colors.white : primaryDark, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- TABLA DE REGISTROS ---
  Widget _buildTablaRegistros() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
            child: Row(
              children: [
                Expanded(flex: 22, child: _thText('PRODUCTO', color: borderLight)),
                Expanded(flex: 11, child: _thText('FOLIO', color: borderLight)),
                Expanded(flex: 10, child: _thText('PRECIO UNIT.', color: borderLight, align: TextAlign.right)),
                Expanded(flex: 10, child: _thText('CANTIDAD', color: borderLight, align: TextAlign.center)),
                Expanded(flex: 11, child: _thText('TOTAL', color: borderLight, align: TextAlign.right)),
                Expanded(flex: 10, child: _thText('FECHA VENTA', color: borderLight, align: TextAlign.center)),
                const SizedBox(width: 95, child: Text('ESTADO / ACCIÓN', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFADCBE3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              ],
            ),
          ),
          Expanded(
            child: _ventasFiltradas.isEmpty 
                ? _buildEstadoVacio() 
                : ListView.builder(
                    itemCount: _ventasFiltradas.length,
                    itemBuilder: (context, index) {
                      var reg = _ventasFiltradas[index];
                      bool isEven = index % 2 == 0;
                      return _buildFilaRegistro(reg, isEven);
                    },
                  ),
          ),
          _buildFooterEstadistico(),
        ],
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left, required Color color}) {
    return Text(text, textAlign: align, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: borderLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No hay registros de ventas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Registra transacciones para verlas aquí o cambia los filtros.', style: TextStyle(color: textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilaRegistro(Map<String, dynamic> reg, bool isEven) {
    double total = reg['precio'] * reg['cantidad'];

    Color badgeBgColor, badgeTextColor;
    IconData statusIcon;
    String statusText = reg['estado'];

    switch (statusText) {
      case 'Completado':
        badgeBgColor = const Color(0xFFD6F0EB); badgeTextColor = const Color(0xFF0F6E56);
        statusIcon = Icons.check;
        break;
      case 'Pendiente':
        badgeBgColor = const Color(0xFFFFF3E0); badgeTextColor = const Color(0xFF854F0B);
        statusIcon = Icons.hourglass_bottom;
        break;
      case 'Cancelado':
      default:
        badgeBgColor = const Color(0xFFFCE9E9); badgeTextColor = const Color(0xFFC53030);
        statusIcon = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FBFD),
        border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 22,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: primaryLight.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.sell, color: primaryLight, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(reg['producto'], style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 11,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(4)),
              child: Text(reg['folio'], style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(flex: 10, child: Text('\$${reg['precio'].toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 11))),
          Expanded(
            flex: 10,
            child: Center(
              child: Container(
                width: 24, height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFDEEEF8), borderRadius: BorderRadius.circular(6)),
                child: Text('${reg['cantidad']}', style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(flex: 11, child: Text('\$${total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 10, child: Text(reg['fecha'], textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 11))),
          SizedBox(
            width: 95,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  tooltip: 'Cambiar estado',
                  onSelected: (nuevoEstado) => _cambiarEstadoVenta(reg['id_venta'], nuevoEstado),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Completado', child: Text('Completado')),
                    const PopupMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                    const PopupMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 10, color: badgeTextColor),
                        const SizedBox(width: 2),
                        Text(statusText, style: TextStyle(color: badgeTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _eliminarVenta(reg['id_venta'], reg['folio']),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: const Color(0xFFFCE9E9), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFA32D2D)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterEstadistico() {
    int completadas = _ventasFiltradas.where((r) => r['estado'] == 'Completado').length;
    int pendientes = _ventasFiltradas.where((r) => r['estado'] == 'Pendiente').length;
    int canceladas = _ventasFiltradas.where((r) => r['estado'] == 'Cancelado').length;
    
    double totalVendido = _ventasFiltradas.fold(0.0, (sum, item) {
      if (item['estado'] == 'Completado') {
        return sum + (item['precio'] * item['cantidad']);
      }
      return sum;
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildStatFooterItem(Icons.receipt, 'Totales:', '${_ventasFiltradas.length} reg.'),
              const SizedBox(width: 16),
              _buildStatFooterItem(Icons.check_circle_outline, 'Completadas:', '$completadas'),
              const SizedBox(width: 16),
              _buildStatFooterItem(Icons.access_time, 'Pendientes:', '$pendientes'),
              const SizedBox(width: 16),
              _buildStatFooterItem(Icons.cancel_outlined, 'Canceladas:', '$canceladas'),
            ],
          ),
          _buildStatFooterItem(
            Icons.monetization_on_outlined, 
            'Total período:', 
            '\$${totalVendido.toStringAsFixed(2)} MXN', 
            isTotal: true
          ),
        ],
      ),
    );
  }

  Widget _buildStatFooterItem(IconData icon, String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: borderLight),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: borderLight, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: isTotal ? borderLight : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
