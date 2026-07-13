import 'package:flutter/material.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  // Paleta de colores basada en tu CSS
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);

  int _filtroActivo = 0; // 0: Activas, 1: Resueltas, 2: Todas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
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
              style: TextStyle(
                color: primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text('/', style: TextStyle(color: borderLight)),
            const SizedBox(width: 8),
            Text(
              'Centro de Alertas',
              style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderLight, height: 0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: primaryLight),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.download, color: primaryLight),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTRODUCCIÓN
            Text(
              'Centro de Alertas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitoree el inventario en tiempo real. Gestione existencias críticas y productos agotados.',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
            const SizedBox(height: 16),

            // TABS DE FILTRO
            Row(
              children: [
                _buildFiltroTab('Activas', 0, badge: '12'),
                const SizedBox(width: 8),
                _buildFiltroTab('Resueltas', 1),
                const SizedBox(width: 8),
                _buildFiltroTab('Todas', 2),
              ],
            ),
            const SizedBox(height: 20),

            // DISEÑO ADAPTATIVO: En pantallas grandes se puede usar Row, aquí usamos Column para móvil/tablet
            // PANEL IZQUIERDO (Tabla de alertas)
            _buildTablaAlertas(),
            const SizedBox(height: 20),

            // PANEL DERECHO (Acciones e Impacto)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAccionesSugeridas()),
                const SizedBox(width: 16),
                Expanded(child: _buildImpactoFinanciero()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Pestañas de filtrado
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
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : primaryLight,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFE24B4A), shape: BoxShape.circle),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // WIDGET: Tabla Principal
  Widget _buildTablaAlertas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _thText('PRODUCTO')),
                Expanded(flex: 1, child: _thText('PRECIO', align: TextAlign.right)),
                Expanded(flex: 2, child: _thText('STOCK', align: TextAlign.center)),
                Expanded(flex: 2, child: _thText('ESTADO', align: TextAlign.center)),
                Expanded(flex: 2, child: _thText('FECHA', align: TextAlign.center)),
                const SizedBox(width: 30), // Espacio para el botón de acción
              ],
            ),
          ),
          // Filas
          _buildDataRow(
            icon: Icons.water_drop,
            iconColor: primaryLight,
            name: 'Jabón Líquido Industrial 5L',
            price: '\$24.50',
            stock: '2',
            isCritical: true,
            statusText: 'Agotado',
            date: '24 Oct, 08:30',
            isEven: false,
          ),
          _buildDataRow(
            icon: Icons.cleaning_services,
            iconColor: const Color(0xFF4A87B4),
            name: 'Mopa Microfibra Pro',
            price: '\$12.99',
            stock: '15',
            isCritical: false,
            statusText: 'Bajo Stock',
            date: '23 Oct, 16:45',
            isEven: true,
          ),
          _buildDataRow(
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF2E9E8A),
            name: 'Desinfectante Multiusos',
            price: '\$8.75',
            stock: '0',
            isCritical: true,
            statusText: 'Agotado',
            date: '23 Oct, 11:20',
            isEven: false,
          ),
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
                Text('Mostrando 4 de 12 alertas activas', style: TextStyle(color: textMuted, fontSize: 12)),
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

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String price,
    required String stock,
    required bool isCritical,
    required String statusText,
    required String date,
    required bool isEven,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8FBFD) : Colors.white,
        border: Border(bottom: BorderSide(color: borderLight.withOpacity(0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(price, textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 12))),
          Expanded(
            flex: 2,
            child: Text(
              stock,
              textAlign: TextAlign.center,
              style: TextStyle(color: isCritical ? const Color(0xFFA32D2D) : const Color(0xFF854F0B), fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical ? const Color(0xFFFCE9E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: isCritical ? const Color(0xFFA32D2D) : const Color(0xFF854F0B)),
                    const SizedBox(width: 4),
                    Text(statusText, style: TextStyle(color: isCritical ? const Color(0xFFA32D2D) : const Color(0xFF854F0B), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(date, textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 11))),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.more_vert, size: 16, color: primaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPagBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: primaryLight),
    );
  }

  // WIDGET: Panel de Acciones Sugeridas
  Widget _buildAccionesSugeridas() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFDEEEF8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
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
            child: Text('Basado en sus alertas actuales, le recomendamos:', style: TextStyle(color: textMuted, fontSize: 11)),
          ),
          _buildActionRow(Icons.shopping_cart, 'Generar orden de compra masiva', isPrimary: true),
          _buildActionRow(Icons.contact_phone, 'Contactar proveedores críticos', isPrimary: false),
          _buildActionRow(Icons.tune, 'Ajustar puntos de pedido', isPrimary: false),
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

  // WIDGET: Panel de Impacto Financiero
  Widget _buildImpactoFinanciero() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text('IMPACTO FINANCIERO', style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$3,420.00', style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Venta potencial retenida por falta de stock.', style: TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Icon(Icons.trending_down, color: primaryDark.withOpacity(0.2), size: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}