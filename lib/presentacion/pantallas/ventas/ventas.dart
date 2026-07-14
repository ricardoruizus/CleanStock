import 'package:flutter/material.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  // --- VARIABLES DE ESTADO ---
  
  // 1. Lo que el usuario escribe en el teclado numérico
  String _cantidadInput = "1"; 

  // 2. Lista de productos agregados al ticket actual (Empieza vacío)
  List<Map<String, dynamic>> _ticket = [];

  // 3. Catálogo de productos (Vacío, esperando a Supabase)
  List<Map<String, dynamic>> _catalogo = [];

  // Paleta de colores
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color leftPanelBg = const Color(0xFFF0F6FB);

  // --- LÓGICA DE NEGOCIO ---

  void _teclaPresionada(String tecla) {
    setState(() {
      if (tecla == 'del') {
        if (_cantidadInput.length > 1) {
          _cantidadInput = _cantidadInput.substring(0, _cantidadInput.length - 1);
        } else {
          _cantidadInput = "1";
        }
      } else if (tecla == '+') {
        int actual = int.tryParse(_cantidadInput) ?? 1;
        _cantidadInput = (actual + 1).toString();
      } else {
        if (_cantidadInput == "1") {
          _cantidadInput = tecla;
        } else {
          _cantidadInput += tecla;
        }
      }
    });
  }

  void _agregarAlTicket(Map<String, dynamic> producto) {
    setState(() {
      int cant = int.tryParse(_cantidadInput) ?? 1;
      int index = _ticket.indexWhere((item) => item['id'] == producto['id']);
      
      if (index != -1) {
        _ticket[index]['cantidad'] += cant;
      } else {
        _ticket.add({
          'id': producto['id'],
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'icono': producto['icono'],
          'color': producto['color'],
          'cantidad': cant,
        });
      }
      _cantidadInput = "1"; 
    });
  }

  void _eliminarDelTicket(int index) {
    setState(() {
      _ticket.removeAt(index);
    });
  }

  void _confirmarVenta() {
    if (_ticket.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El ticket está vacío.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Aquí irá el insert a Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Venta registrada con éxito!'), backgroundColor: Color(0xFF2E9E8A)),
    );

    setState(() {
      _ticket.clear();
      _cantidadInput = "1";
    });
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PANEL IZQUIERDO (Búsqueda y Teclado)
          Container(
            width: 280, 
            color: leftPanelBg,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBuscador(),
                const SizedBox(height: 12),
                _buildResultadosBusqueda(),
                const SizedBox(height: 12),
                _buildDisplayNumpad(),
                const SizedBox(height: 8),
                Expanded(child: _buildNumpad()),
              ],
            ),
          ),
          
          Container(width: 0.5, color: borderLight),

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
        IconButton(icon: Icon(Icons.history, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.print, color: primaryLight), onPressed: () {}),
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

  Widget _buildBuscador() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, size: 16, color: textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text('Buscar ID del producto', style: TextStyle(color: textMuted, fontSize: 12))),
          Icon(Icons.search, size: 16, color: textMuted),
        ],
      ),
    );
  }

  Widget _buildResultadosBusqueda() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _catalogo.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Catálogo vacío.\nConecta Supabase para ver los productos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ),
            )
          : Column(
              children: _catalogo.asMap().entries.map((entry) {
                int index = entry.key;
                var prod = entry.value;
                return Column(
                  children: [
                    _buildFilaResultado(prod),
                    if (index < _catalogo.length - 1) Divider(height: 1, color: borderLight.withOpacity(0.5)),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildFilaResultado(Map<String, dynamic> producto) {
    return InkWell(
      onTap: () => _agregarAlTicket(producto),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: producto['color']),
            const SizedBox(width: 8),
            Text(producto['id'], style: TextStyle(color: primaryLight, fontWeight: FontWeight.bold, fontSize: 10)),
            const SizedBox(width: 8),
            Expanded(child: Text(producto['nombre'], style: TextStyle(color: primaryDark, fontSize: 11), overflow: TextOverflow.ellipsis)),
            Text('\$${producto['precio']}', style: TextStyle(color: textMuted, fontSize: 11)),
            const SizedBox(width: 8),
            Icon(Icons.add_circle_outline, size: 16, color: primaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: primaryDark, fontSize: 16),
          children: [
            const TextSpan(text: 'Cant: ', style: TextStyle(fontWeight: FontWeight.w300)),
            TextSpan(text: _cantidadInput, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTeclaNum('1'), _buildTeclaNum('2'), _buildTeclaNum('3'),
        _buildTeclaNum('4'), _buildTeclaNum('5'), _buildTeclaNum('6'),
        _buildTeclaNum('7'), _buildTeclaNum('8'), _buildTeclaNum('9'),
        _buildTeclaAccion(Icons.add, true, '+'), _buildTeclaNum('0'), _buildTeclaAccion(Icons.backspace_outlined, false, 'del'),
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
          border: Border.all(color: borderLight.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(num, style: TextStyle(fontSize: 18, color: primaryDark, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTeclaAccion(IconData icon, bool isAct, String accion) {
    return InkWell(
      onTap: () => _teclaPresionada(accion),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isAct ? const Color(0xFFDEEEF8) : const Color(0xFFFCE9E9),
          border: Border.all(color: isAct ? borderLight : const Color(0xFFF09595)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: isAct ? primaryLight : const Color(0xFFA32D2D), size: 18),
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
              Expanded(flex: 1, child: _thText('CANT.', align: TextAlign.center)),
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
            Icon(Icons.shopping_cart_checkout, size: 48, color: borderLight.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('El ticket está vacío', style: TextStyle(color: primaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Agrega productos desde el buscador', style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _ticket.length,
      itemBuilder: (context, index) {
        var item = _ticket[index];
        double totalFila = item['precio'] * item['cantidad'];
        bool isEven = index % 2 != 0;

        return _buildFilaTicket(
          index,
          item['icono'],
          item['color'],
          item['nombre'],
          item['cantidad'].toString(),
          '\$${item['precio'].toStringAsFixed(2)}',
          '\$${totalFila.toStringAsFixed(2)}',
          isEven,
        );
      },
    );
  }

  Widget _buildFilaTicket(int index, IconData icon, Color color, String nombre, String cant, String precio, String total, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF5F9FD) : Colors.white,
        border: Border(bottom: BorderSide(color: borderLight.withOpacity(0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  child: Icon(icon, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(nombre, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDEEEF8), borderRadius: BorderRadius.circular(4)),
                child: Text(cant, style: TextStyle(color: primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(precio, textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 12))),
          Expanded(flex: 2, child: Text(total, textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold))),
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