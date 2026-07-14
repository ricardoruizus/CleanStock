import 'package:flutter/material.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);

  int _filtroActivo = 0; // 0: Activas, 1: Resueltas, 2: Todas

  // --- DATOS (Lista vacía esperando a Supabase) ---
  final List<Map<String, dynamic>> _alertas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTRODUCCIÓN
            Text('Centro de Alertas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 4),
            Text('Monitoree el inventario en tiempo real. Gestione existencias críticas.', style: TextStyle(fontSize: 13, color: textMuted)),
            const SizedBox(height: 16),

            // TABS DE FILTRO
            Row(
              children: [
                _buildFiltroTab('Activas', 0, badge: _alertas.isNotEmpty ? '${_alertas.length}' : null),
                const SizedBox(width: 8),
                _buildFiltroTab('Resueltas', 1),
                const SizedBox(width: 8),
                _buildFiltroTab('Todas', 2),
              ],
            ),
            const SizedBox(height: 20),

            // PANELES
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PANEL IZQUIERDO (Lista de Alertas)
                Expanded(
                  flex: 3,
                  child: _buildTablaAlertas(),
                ),
                const SizedBox(width: 16),
                
                // PANEL DERECHO (Acciones e Impacto)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildAccionesSugeridas(),
                      const SizedBox(height: 16),
                      _buildImpactoFinanciero(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
          Text('Alertas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.tune, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.download, color: primaryLight), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Lógica para marcar como resueltas
            },
            icon: const Icon(Icons.checklist, size: 16, color: Colors.white),
            label: const Text('Marcar resueltas', style: TextStyle(color: Colors.white)),
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

  // --- WIDGETS DE FILTRO ---
  Widget _buildFiltroTab(String titulo, int index, {String? badge}) {
    bool isSelected = _filtroActivo == index;
    return GestureDetector(
      onTap: () => setState(() => _filtroActivo = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryLight : Colors.white,
          border: Border.all(color: isSelected ? primaryLight : borderLight, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : primaryLight)),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFE24B4A), shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- TABLA DE ALERTAS ---
  Widget _buildTablaAlertas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Expanded(flex: 3, child: _thText('PRODUCTO')),
                Expanded(flex: 1, child: _thText('PRECIO', align: TextAlign.right)),
                Expanded(flex: 2, child: _thText('STOCK', align: TextAlign.center)),
                Expanded(flex: 2, child: _thText('ESTADO', align: TextAlign.center)),
              ],
            ),
          ),
          
          // Contenido (Validamos si hay alertas)
          if (_alertas.isEmpty)
            _buildEstadoVacioAlertas()
          else
            ..._alertas.asMap().entries.map((entry) {
              bool isEven = entry.key % 2 != 0;
              return _buildDataRow(entry.value, isEven);
            }),

          // Paginación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FD),
              border: Border(top: BorderSide(color: borderLight, width: 0.5)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mostrando ${_alertas.length} de ${_alertas.length} alertas activas', style: TextStyle(color: textMuted, fontSize: 12)),
                Row(
                  children: [
                    _buildPagBtn(Icons.chevron_left),
                    const SizedBox(width: 8),
                    _buildPagBtn(Icons.chevron_right),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacioAlertas() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, size: 50, color: borderLight.withOpacity(0.8)),
            const SizedBox(height: 12),
            Text('No hay alertas activas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Todo tu inventario está bajo control.', style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text, textAlign: align, style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0));
  }

  Widget _buildDataRow(Map<String, dynamic> alerta, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8FBFD) : Colors.white,
        border: Border(bottom: BorderSide(color: borderLight.withOpacity(0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(alerta['producto'], style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('\$${alerta['precio']}', textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 12))),
          Expanded(flex: 2, child: Text('${alerta['stock']}', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFA32D2D), fontSize: 14, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(alerta['estado'], textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFA32D2D), fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPagBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: primaryLight),
    );
  }

  // --- PANELES DERECHOS ---
  Widget _buildAccionesSugeridas() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFDEEEF8), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: primaryLight, size: 16),
                const SizedBox(width: 8),
                Text('Acciones sugeridas', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Text(
              _alertas.isEmpty ? 'No hay acciones requeridas por el momento.' : 'Basado en sus alertas actuales, le recomendamos:', 
              style: TextStyle(color: textMuted, fontSize: 11)
            ),
          ),
          if (_alertas.isNotEmpty) ...[
            _buildActionRow(Icons.shopping_cart, 'Generar orden de compra masiva', isPrimary: true),
            _buildActionRow(Icons.contact_phone, 'Contactar proveedores críticos', isPrimary: false),
          ]
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String text, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? primaryLight : Colors.white,
        border: Border(top: BorderSide(color: borderLight.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isPrimary ? Colors.white : primaryLight),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isPrimary ? Colors.white : primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImpactoFinanciero() {
    // Calculamos el impacto basado en la lista (si está vacía, será 0)
    double impactoTotal = _alertas.fold(0, (sum, item) => sum + (item['impacto'] ?? 0.0));

    return Container(
      decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Text('IMPACTO FINANCIERO', style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${impactoTotal.toStringAsFixed(2)}', style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Venta potencial retenida por falta de stock.', style: TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Icon(Icons.trending_down, color: primaryDark.withOpacity(0.1), size: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}