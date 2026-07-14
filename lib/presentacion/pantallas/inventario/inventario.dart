import 'package:flutter/material.dart';

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

  int _filtroActivo = 0; // 0: Todos, 1: Activos, 2: Bajo stock, 3: Agotado

  // --- DATOS (Lista vacía esperando a Supabase) ---
  final List<Map<String, dynamic>> _productos = [];

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
        IconButton(icon: Icon(Icons.tune, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.download, color: primaryLight), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Aquí irá la lógica para abrir tu pantalla/modal de Agregar Producto
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
    // Cálculos dinámicos para las estadísticas
    int totalProductos = _productos.length;
    int totalAlertas = _productos.where((p) => p['estado'] == 'Bajo stock' || p['estado'] == 'Agotado').length;

    return Container(
      color: toolbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Buscador
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: textMuted),
                    const SizedBox(width: 8),
                    Text('Buscar producto...', style: TextStyle(color: textMuted, fontSize: 12)),
                  ],
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
              // Píldoras estadísticas ahora son dinámicas
              _buildStatChip(Icons.inventory_2, '$totalProductos productos'),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.warning_amber_rounded, 
                '$totalAlertas alertas',
                // Si hay alertas, la pintamos un poco más llamativa
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
      onTap: () => setState(() => _filtroActivo = index),
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
                Expanded(flex: 20, child: _thText('FECHA ENTRADA', align: TextAlign.center)),
              ],
            ),
          ),
          
          // Cuerpo de la Tabla (Validando si está vacía)
          Expanded(
            child: _productos.isEmpty
                ? _buildEstadoVacio()
                : ListView.builder(
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      var prod = _productos[index];
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
            'Tu inventario está vacío',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Conecta Supabase y agrega tu primer producto.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- FILA DINÁMICA (Lista para cuando haya datos) ---
  Widget _buildFilaTabla(Map<String, dynamic> prod, bool isEven) {
    IconData iconEstado = Icons.circle;
    if (prod['estado'] == 'Bajo stock') iconEstado = Icons.arrow_drop_up;
    if (prod['estado'] == 'Agotado') iconEstado = Icons.close;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF5F9FD),
        border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        children: [
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
          Expanded(
            flex: 16,
            child: Text('\$${prod['precio'].toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: primaryDark, fontSize: 12)),
          ),
          Expanded(
            flex: 16,
            child: Text('${prod['stock']} uds', textAlign: TextAlign.center, style: TextStyle(color: primaryDark, fontSize: 12)),
          ),
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
          Expanded(
            flex: 20,
            child: Text(prod['fecha'], textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}