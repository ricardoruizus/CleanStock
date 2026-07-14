import 'package:flutter/material.dart';

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

  int _filtroActivo = 0; // 0: Todos, 1: Completados, 2: Pendientes, 3: Cancelados

  // --- DATOS (Lista vacía esperando a Supabase) ---
  final List<Map<String, dynamic>> _registros = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildTablaRegistros()),
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
        IconButton(icon: Icon(Icons.file_upload_outlined, color: primaryLight), onPressed: () {}), // Exportar
        IconButton(icon: Icon(Icons.print, color: primaryLight), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Aquí podrías abrir un modal o navegar para forzar un registro manual
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Nueva venta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Buscador
          Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: textMuted),
                const SizedBox(width: 8),
                Text('Buscar producto o folio...', style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          // Filtros y Fecha
          Row(
            children: [
              // Fecha (Podría ser dinámica después)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: primaryLight),
                    const SizedBox(width: 6),
                    Text('Mes actual', style: TextStyle(color: primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildFiltroPill('Todos', 0),
              const SizedBox(width: 8),
              _buildFiltroPill('Completados', 1),
              const SizedBox(width: 8),
              _buildFiltroPill('Pendientes', 2),
              const SizedBox(width: 8),
              _buildFiltroPill('Cancelados', 3),
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
          // Header
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
                const SizedBox(width: 90, child: Text('ESTADO / ACCIÓN', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFADCBE3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              ],
            ),
          ),
          
          // Cuerpo de la Tabla (Validando si está vacía)
          Expanded(
            child: _registros.isEmpty 
                ? _buildEstadoVacio() 
                : ListView.builder(
                    itemCount: _registros.length,
                    itemBuilder: (context, index) {
                      var reg = _registros[index];
                      bool isEven = index % 2 == 0;
                      return _buildFilaRegistro(reg, isEven);
                    },
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
          Icon(Icons.receipt_long_outlined, size: 64, color: borderLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Aún no hay registros de ventas',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Las ventas que confirmes aparecerán aquí.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- FILA DINÁMICA (Lista para cuando haya datos) ---
  Widget _buildFilaRegistro(Map<String, dynamic> reg, bool isEven) {
    double total = reg['precio'] * reg['cantidad'];

    Color badgeBgColor, badgeTextColor;
    IconData statusIcon;
    String statusText;
    bool isCanceled = reg['estado'] == 'Cancelado';

    switch (reg['estado']) {
      case 'Completado':
        badgeBgColor = const Color(0xFFD6F0EB); badgeTextColor = const Color(0xFF0F6E56);
        statusIcon = Icons.check; statusText = 'Completado';
        break;
      case 'Pendiente':
        badgeBgColor = const Color(0xFFFFF3E0); badgeTextColor = const Color(0xFF854F0B);
        statusIcon = Icons.hourglass_bottom; statusText = 'Pendiente';
        break;
      case 'Cancelado':
      default:
        badgeBgColor = const Color(0xFFFCE9E9); badgeTextColor = const Color(0xFFA32D2D);
        statusIcon = Icons.close; statusText = 'Cancelado';
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
                  decoration: BoxDecoration(color: reg['colorIcono'], borderRadius: BorderRadius.circular(6)),
                  child: Icon(reg['icono'], color: Colors.white, size: 12),
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
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                const SizedBox(width: 4),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: isCanceled ? const Color(0xFFFCE9E9) : bgLight, borderRadius: BorderRadius.circular(6)),
                  child: Icon(isCanceled ? Icons.delete_outline : Icons.visibility_outlined, size: 14, color: isCanceled ? const Color(0xFFA32D2D) : primaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER ESTADÍSTICO DINÁMICO ---
  Widget _buildFooterEstadistico() {
    // Calculamos todo al vuelo. Como ahora está vacío, mostrará 0s. 
    // Cuando conectes Supabase, esto se actualizará solo.
    int completadas = _registros.where((r) => r['estado'] == 'Completado').length;
    int pendientes = _registros.where((r) => r['estado'] == 'Pendiente').length;
    int canceladas = _registros.where((r) => r['estado'] == 'Cancelado').length;
    
    double totalVendido = _registros.fold(0.0, (sum, item) {
      if (item['estado'] != 'Cancelado') {
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
              _buildStatFooterItem(Icons.receipt, 'Ventas totales:', '${_registros.length} registros'),
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