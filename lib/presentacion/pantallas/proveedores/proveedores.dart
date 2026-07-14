import 'package:flutter/material.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color toolbarBg = const Color(0xFFF0F6FB);

  int _filtroActivo = 0; // 0: Todos, 1: Activos, 2: Limpieza, 3: Comida, 4: Dulces

  // --- DATOS (Lista vacía esperando a Supabase) ---
  List<Map<String, dynamic>> _categorias = [];

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
        IconButton(icon: Icon(Icons.download, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.tune, color: primaryLight), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Aquí irá tu lógica para abrir el formulario y guardar en Supabase
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
          // Buscador
          Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: textMuted),
                const SizedBox(width: 8),
                Text('Buscar proveedor o categoría...', style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Filtros
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroPill('Todos', 0),
                  const SizedBox(width: 8),
                  _buildFiltroPill('Activos', 1),
                  const SizedBox(width: 8),
                  _buildFiltroPill('Limpieza', 2),
                  const SizedBox(width: 8),
                  _buildFiltroPill('Comida', 3),
                  const SizedBox(width: 8),
                  _buildFiltroPill('Dulces', 4),
                ],
              ),
            ),
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

  // --- TABLA DE PROVEEDORES ---
  Widget _buildTablaProveedores() {
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
                Expanded(flex: 14, child: _thText('CONTACTO', color: borderLight)),
                Expanded(flex: 14, child: _thText('TELÉFONO', color: borderLight)),
                Expanded(flex: 10, child: _thText('ESTADO', color: borderLight, align: TextAlign.center)),
                const SizedBox(width: 80, child: Text('DETALLE', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFADCBE3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              ],
            ),
          ),
          
          // Cuerpo de la Tabla (Validando si está vacía)
          Expanded(
            child: _categorias.isEmpty 
                ? _buildEstadoVacio() 
                : ListView(
                    children: _construirFilasDinamicas(),
                  ),
          ),
          
          // Footer Estadístico
          _buildFooterEstadistico(),
        ],
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left, required Color color}) {
    return Text(text, textAlign: align, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5));
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
            'Aún no hay proveedores registrados',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Conecta tu base de datos o agrega uno nuevo.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Widget> _construirFilasDinamicas() {
    List<Widget> filas = [];
    for (var cat in _categorias) {
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
    bool isReview = prov['estado'] == 'Revisión';

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
                  decoration: BoxDecoration(color: prov['colorPunto'], shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(prov['nombre'], style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 14, child: Text(prov['contacto'], style: TextStyle(color: textMuted, fontSize: 11))),
          Expanded(flex: 14, child: Text(prov['telefono'], style: TextStyle(color: textMuted, fontSize: 11))),
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
                  prov['estado'],
                  style: TextStyle(color: isReview ? const Color(0xFF854F0B) : const Color(0xFF0F6E56), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.chevron_right, size: 16, color: primaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER ESTADÍSTICO ---
  Widget _buildFooterEstadistico() {
    int totalProveedores = 0;
    for (var cat in _categorias) {
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
              Text('${_categorias.length} categorías', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
}