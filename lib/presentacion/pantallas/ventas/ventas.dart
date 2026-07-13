import 'package:flutter/material.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  // Paleta de colores
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color leftPanelBg = const Color(0xFFF0F6FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PANEL IZQUIERDO (Búsqueda y Teclado Numérico)
          Container(
            width: 280, // Ancho fijo para el panel lateral
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
          
          // Separador vertical
          Container(width: 0.5, color: borderLight),

          // PANEL DERECHO (Ticket de Venta)
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

  // --- COMPONENTES DEL APPBAR ---
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
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            'CLEANSTOCK',
            style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(width: 8),
          Text('/', style: TextStyle(color: borderLight)),
          const SizedBox(width: 8),
          Text('Ventas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.history, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.print, color: primaryLight), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {},
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

  // --- COMPONENTES DEL PANEL IZQUIERDO ---
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
          Expanded(
            child: Text('Buscar ID del producto', style: TextStyle(color: textMuted, fontSize: 12)),
          ),
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
      child: Column(
        children: [
          _buildFilaResultado(color: primaryLight, id: '1001', nombre: 'Limpiador multiusos', precio: '\$89', isSelected: true),
          Divider(height: 1, color: borderLight.withOpacity(0.5)),
          _buildFilaResultado(color: const Color(0xFF2E9E8A), id: '1002', nombre: 'Desinfectante bact.', precio: '\$145'),
          Divider(height: 1, color: borderLight.withOpacity(0.5)),
          _buildFilaResultado(color: primaryDark, id: '1003', nombre: 'Jabón industrial', precio: '\$62'),
        ],
      ),
    );
  }

  Widget _buildFilaResultado({required Color color, required String id, required String nombre, required String precio, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: isSelected ? const Color(0xFFDEEEF8) : Colors.transparent,
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text(id, style: TextStyle(color: primaryLight, fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(width: 8),
          Expanded(child: Text(nombre, style: TextStyle(color: primaryDark, fontSize: 11), overflow: TextOverflow.ellipsis)),
          Text(precio, style: TextStyle(color: textMuted, fontSize: 11)),
          const SizedBox(width: 8),
          Icon(Icons.add_circle_outline, size: 16, color: primaryLight),
        ],
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
          children: const [
            TextSpan(text: 'Cant: ', style: TextStyle(fontWeight: FontWeight.w300)),
            TextSpan(text: '1', style: TextStyle(fontWeight: FontWeight.bold)),
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
        _buildTeclaAccion(Icons.add, true), _buildTeclaNum('0'), _buildTeclaAccion(Icons.backspace_outlined, false),
      ],
    );
  }

  Widget _buildTeclaNum(String num) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(num, style: TextStyle(fontSize: 18, color: primaryDark, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTeclaAccion(IconData icon, bool isAct) {
    return Container(
      decoration: BoxDecoration(
        color: isAct ? const Color(0xFFDEEEF8) : const Color(0xFFFCE9E9),
        border: Border.all(color: isAct ? borderLight : const Color(0xFFF09595)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: isAct ? primaryLight : const Color(0xFFA32D2D), size: 18),
    );
  }

  // --- COMPONENTES DEL PANEL DERECHO (TICKET) ---
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
              const SizedBox(width: 32), // Espacio para botón de borrar
            ],
          ),
        ),
      ],
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildCuerpoTabla() {
    return ListView(
      children: [
        _buildFilaTicket(Icons.water_drop, primaryLight, 'Limpiador multiusos', '3', '\$89.00', '\$267.00', false),
        _buildFilaTicket(Icons.cleaning_services, const Color(0xFF2E9E8A), 'Desinfectante bact.', '2', '\$145.50', '\$291.00', true),
        _buildFilaTicket(Icons.opacity, primaryDark, 'Jabón industrial', '5', '\$62.00', '\$310.00', false),
        _buildFilaTicket(Icons.air, const Color(0xFF4A87B4), 'Aromatizante cítrico', '1', '\$55.00', '\$55.00', true),
        _buildFilaTicket(Icons.wash, borderLight, 'Escoba industrial', '2', '\$210.00', '\$420.00', false),
      ],
    );
  }

  Widget _buildFilaTicket(IconData icon, Color color, String nombre, String cant, String precio, String total, bool isEven) {
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFFCE9E9), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.close, size: 12, color: Color(0xFFA32D2D)),
          ),
        ],
      ),
    );
  }

  Widget _buildPieTabla() {
    return Container(
      color: primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('TOTAL · 13 arts.', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Text('MXN', style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text('\$1,343.00', style: TextStyle(color: borderLight, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24), // Compensar el botón de borrar de las filas
        ],
      ),
    );
  }
}