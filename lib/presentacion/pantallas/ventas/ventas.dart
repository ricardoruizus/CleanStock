import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../servicios/ticket_servicio.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _supabase = Supabase.instance.client;

  // --- VARIABLES DE ESTADO ---
  String _codigoInput = ""; 
  final List<Map<String, dynamic>> _ticket = [];
  
  // Catálogo real traído de la Base de Datos
  List<Map<String, dynamic>> _catalogo = [];
  bool _isLoadingCatalog = true;

  // Paleta de colores[cite: 2]
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color leftPanelBg = const Color(0xFFF0F6FB);

  @override
  void initState() {
    super.initState();
    _cargarCatalogoProductos();
  }

  // Carga inicial de productos desde la base de datos
  Future<void> _cargarCatalogoProductos() async {
    try {
      final data = await _supabase
          .from('productos')
          .select('id, nombre, precio, stock, sku'); // INCLUIR SKU
      
      setState(() {
        _catalogo = List<Map<String, dynamic>>.from(data);
        _isLoadingCatalog = false;
      });
    } catch (e) {
      _mostrarSnack('Error al cargar catálogo: $e', Colors.red);
      setState(() => _isLoadingCatalog = false);
    }
  }

  // --- LÓGICA DE NEGOCIO ---

  void _teclaPresionada(String tecla) {
    setState(() {
      if (tecla == 'del') {
        if (_codigoInput.isNotEmpty) {
          _codigoInput = _codigoInput.substring(0, _codigoInput.length - 1);
        }
      } else if (tecla == 'add') {
        _buscarYAgregarPorSKU(_codigoInput); // CAMBIO: Usar SKU
      } else {
        _codigoInput += tecla;
      }
    });
  }

  List<Map<String, dynamic>> _obtenerSugerencias() {
    if (_codigoInput.isEmpty) return [];
    return _catalogo.where((producto) {
      final skuStr = (producto['sku'] ?? '').toString(); // CAMBIO
      return skuStr.toLowerCase().contains(_codigoInput.toLowerCase()) || // CAMBIO
             producto['nombre']!.toLowerCase().contains(_codigoInput.toLowerCase());
    }).toList();
  }

  void _buscarYAgregarPorSKU(String sku) {
    final productoIndex = _catalogo.indexWhere((item) => (item['sku'] ?? '').toString().toLowerCase() == sku.toLowerCase()); // CAMBIO

    if (productoIndex != -1) {
      _agregarAlTicket(_catalogo[productoIndex]);
      _codigoInput = "";
    } else {
      _mostrarSnack('SKU de producto no encontrado.', Colors.red);
    }
  }

  void _agregarAlTicket(Map<String, dynamic> producto) {
    setState(() {
      int index = _ticket.indexWhere((item) => item['id'] == producto['id']);
      
      if (index != -1) {
        if (_ticket[index]['cantidad'] < producto['stock']) {
          _ticket[index]['cantidad'] += 1;
        } else {
          _mostrarSnack('No puedes agregar más de este producto. Stock límite alcanzado.', Colors.orange);
        }
      } else {
        if (producto['stock'] > 0) {
          _ticket.add({
            'id': producto['id'],
            'sku': producto['sku'],
            'nombre': producto['nombre'],
            'precio': (producto['precio'] as num).toDouble(),
            'cantidad': 1,
            'stock': producto['stock']
          });
        } else {
          _mostrarSnack('Producto sin stock disponible.', Colors.orange);
        }
      }
    });
  }

  void _eliminarDelTicket(int index) {
    setState(() {
      _ticket.removeAt(index);
    });
  }

  void _duplicarProducto(int index) {
    setState(() {
      final item = _ticket[index];
      if (item['cantidad'] < item['stock']) {
        item['cantidad'] += 1;
      } else {
        _mostrarSnack('No puedes agregar más de este producto. Stock límite alcanzado.', Colors.orange);
      }
    });
  }

  void _reducirProducto(int index) {
    setState(() {
      final item = _ticket[index];
      if (item['cantidad'] >= 2) {
        item['cantidad'] -= 1;
      }
    });
  }

  // --- CONFIRMAR VENTA (GUARDADO REAL EN BASE DE DATOS) ---
  Future<void> _confirmarVenta() async {
    if (_ticket.isEmpty) {
      _mostrarSnack('El ticket está vacío.', Colors.orange);
      return;
    }

    // Preguntar por el ticket
    final bool? generarTicket = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Generar Ticket?'),
        content: const Text('¿Deseas generar el ticket de compra y compartirlo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    setState(() => _isLoadingCatalog = true);

    try {
      final double totalVenta = _ticket.fold(0.0, (sum, item) => sum + (item['precio'] * item['cantidad']));
      final String folioUnico = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // 1. Insertar la venta cabecera (Maestro) en 'ventas'
      final nuevaVenta = await _supabase.from('ventas').insert({
        'folio': folioUnico,
        'total': totalVenta,
        'estado': 'Completado',
        'fecha_venta': DateTime.now().toIso8601String(), // Enviamos la hora exacta del dispositivo
      }).select().single();

      final int ventaId = nuevaVenta['id'];

      // 2. Insertar cada renglón en 'venta_detalles'[cite: 3]
      for (var item in _ticket) {
        await _supabase.from('venta_detalles').insert({
          'venta_id': ventaId,
          'producto_id': item['id'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio'],
          // El subtotal se calcula solo en la BD gracias al script alter[cite: 3]
        });

        // 3. Descontar stock del producto en la tabla 'productos'
        await _supabase.rpc('descontar_stock', params: {
          'p_id': item['id'],
          'p_cantidad': item['cantidad']
        });
      }

      // Generar ticket si el usuario aceptó
      if (generarTicket == true) {
        await TicketServicio.generarYCompartirTicket(_ticket, totalVenta, folioUnico);
      }

      _mostrarSnack('¡Venta $folioUnico registrada con éxito!', const Color(0xFF2E9E8A));
      
      setState(() {
        _ticket.clear();
        _codigoInput = "";
      });

      // Recargar catálogo para actualizar stocks en pantalla
      await _cargarCatalogoProductos();

    } catch (e) {
      _mostrarSnack('Error al procesar la venta: $e', Colors.red);
    } finally {
      setState(() => _isLoadingCatalog = false);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: _isLoadingCatalog 
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Consideramos horizontal si el ancho es significativamente mayor a la altura
                bool isHorizontal = constraints.maxWidth > constraints.maxHeight;

                if (isHorizontal) {
                  // --- DISEÑO HORIZONTAL (3 PARTES) ---
                  return Row(
                    children: [
                      // PARTE 1: TECLADO
                      Container(
                        width: 200,
                        color: leftPanelBg,
                        padding: const EdgeInsets.all(8.0),
                        child: _buildNumpad(isMobile: false),
                      ),
                      Container(width: 0.5, color: borderLight),

                      // PARTE 2: SUGERENCIAS
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildDisplayCodigo(),
                              const SizedBox(height: 8),
                              Expanded(child: _buildPanelSugerencias()),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 0.5, color: borderLight),

                      // PARTE 3: TICKET
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: bgLight,
                          child: Column(
                            children: [
                              _buildCabeceraTabla(),
                              Expanded(child: _buildCuerpoTabla()),
                              _buildPieTabla(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // --- DISEÑO VERTICAL (ORIGINAL FUNCIONAL) ---
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PANEL IZQUIERDO (Búsqueda + Teclado)
                      Container(
                        color: leftPanelBg,
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildDisplayCodigo(), 
                            const SizedBox(height: 10),
                            SizedBox(height: 180, child: _buildPanelSugerencias()), 
                            const SizedBox(height: 10),
                            _buildNumpad(isMobile: true), 
                          ],
                        ),
                      ),
                      
                      Container(height: 0.5, color: borderLight),

                      // PANEL DERECHO (Ticket)
                      Expanded(
                        child: Container(
                          color: bgLight,
                          child: Column(
                            children: [
                              _buildCabeceraTabla(),
                              Expanded(child: _buildCuerpoTabla()),
                              _buildPieTabla(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
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
          Text('Punto de Venta', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: _confirmarVenta,
            icon: const Icon(Icons.check, size: 16, color: Colors.white),
            label: const Text('Confirmar venta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildDisplayCodigo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _codigoInput.isEmpty ? 'Ingrese el SKU' : _codigoInput,
              style: TextStyle(
                color: _codigoInput.isEmpty ? textMuted : primaryDark,
                fontSize: 13,
                fontWeight: _codigoInput.isEmpty ? FontWeight.normal : FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelSugerencias() {
    final sugerencias = _obtenerSugerencias();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _codigoInput.isEmpty
          ? Center(
              child: Text(
                'Comienza a teclear\npara buscar productos',
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
            )
          : sugerencias.isEmpty
              ? Center(
                  child: Text(
                    'Ningún producto coincide',
                    style: TextStyle(color: textMuted, fontSize: 11),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sugerencias.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: borderLight.withValues(alpha: 0.3)),
                  itemBuilder: (context, index) {
                    final prod = sugerencias[index];
                    return InkWell(
                      onTap: () {
                        _agregarAlTicket(prod);
                        setState(() {
                          _codigoInput = ""; 
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: primaryLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod['nombre'], style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                  Text('SKU: ${prod['sku']} - Stock: ${prod['stock']}', style: TextStyle(color: textMuted, fontSize: 9)),
                                ],
                              ),
                            ),
                            Text('\$${(prod['precio'] as num).toDouble().toStringAsFixed(2)}', style: TextStyle(color: primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.add_circle_outline, size: 14, color: primaryLight),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildNumpad({bool isMobile = false}) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      childAspectRatio: isMobile ? 2.0 : 1.2, 
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTeclaNum('1'), _buildTeclaNum('2'), _buildTeclaNum('3'),
        _buildTeclaNum('4'), _buildTeclaNum('5'), _buildTeclaNum('6'),
        _buildTeclaNum('7'), _buildTeclaNum('8'), _buildTeclaNum('9'),
        _buildTeclaAccion(Icons.check_circle, true, 'add'), _buildTeclaNum('0'), _buildTeclaAccion(Icons.backspace_outlined, false, 'del'),
      ],
    );
  }

  Widget _buildTeclaNum(String num) {
    return InkWell(
      onTap: () => _teclaPresionada(num),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderLight.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(num, style: TextStyle(fontSize: 16, color: primaryDark, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTeclaAccion(IconData icon, bool isAct, String accion) {
    return InkWell(
      onTap: () => _teclaPresionada(accion),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isAct ? const Color(0xFFD6F0EB) : const Color(0xFFFCE9E9),
          border: Border.all(color: isAct ? const Color(0xFF2E9E8A) : const Color(0xFFF09595)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: isAct ? const Color(0xFF0F6E56) : const Color(0xFFA32D2D), size: 18),
      ),
    );
  }

  Widget _buildCabeceraTabla() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: primaryDark,
          alignment: Alignment.center,
          child: const Text('PRODUCTOS EN ESTA VENTA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ),
        Container(
          color: const Color(0xFFDDEAF5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 4, child: _thText('PRODUCTO')),
              Expanded(flex: 2, child: _thText('CANT.', align: TextAlign.center)),
              Expanded(flex: 2, child: _thText('PRECIO', align: TextAlign.right)),
              Expanded(flex: 2, child: _thText('TOTAL', align: TextAlign.right)),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text, textAlign: align, style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  Widget _buildCuerpoTabla() {
    if (_ticket.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_checkout, size: 48, color: borderLight.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('El ticket está vacío', style: TextStyle(color: primaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Digita códigos en el teclado de la izquierda', style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _ticket.length,
      itemBuilder: (context, index) {
        var item = _ticket[index];
        bool isEven = index % 2 != 0;

        return _buildFilaTicket(
          index,
          item,
          isEven,
        );
      },
    );
  }

  Widget _buildFilaTicket(int index, Map<String, dynamic> item, bool isEven) {
    double totalFila = item['precio'] * item['cantidad'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF5F9FD) : Colors.white,
        border: Border(bottom: BorderSide(color: borderLight.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.sell, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nombre'],
                        style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'SKU: ${item['sku'] ?? 'N/A'}',
                        style: TextStyle(color: textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: item['cantidad'] >= 2 ? () => _reducirProducto(index) : null,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: item['cantidad'] >= 2 ? const Color(0xFFFCE9E9) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 11,
                      color: item['cantidad'] >= 2 ? const Color(0xFFA32D2D) : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDEEEF8), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    item['cantidad'].toString(),
                    style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _duplicarProducto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F0EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 11,
                      color: Color(0xFF0F6E56),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${item['precio'].toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: primaryDark, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${totalFila.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _eliminarDelTicket(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFFCE9E9), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.close, size: 12, color: Color(0xFFA32D2D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieTabla() {
    int totalArticulos = _ticket.fold(0, (sum, item) => sum + (item['cantidad'] as int));
    double totalVenta = _ticket.fold(0.0, (sum, item) => sum + (item['precio'] * item['cantidad']));

    return Container(
      color: primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'TOTAL · $totalArticulos arts.', 
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Text('MXN', style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(
            '\$${totalVenta.toStringAsFixed(2)}', 
            style: TextStyle(color: borderLight, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}