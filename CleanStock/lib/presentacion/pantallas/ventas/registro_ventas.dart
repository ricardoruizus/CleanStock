import 'package:flutter/material.dart';
import 'package:clean_stock/core/theme.dart';
import 'package:clean_stock/presentacion/pantallas/ventas/nueva_venta.dart';

class RegistroVentasScreen extends StatelessWidget {
  const RegistroVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanStockTheme.background,
      appBar: AppBar(
        title: const Text('Registro de Ventas', style: TextStyle(color: CleanStockTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildSalesTable()),
          _buildStatsFooter(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NuevaVentaScreen())),
        label: const Text('Nueva venta'),
        icon: const Icon(Icons.add),
        backgroundColor: CleanStockTheme.accent,
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(hintText: 'Buscar folio o producto...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
          const SizedBox(width: 16),
          _buildFilterPill('Todos', true),
          _buildFilterPill('Completados', false),
          _buildFilterPill('Pendientes', false),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isSelected ? CleanStockTheme.accent : CleanStockTheme.border, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : CleanStockTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildSalesTable() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: CleanStockTheme.border)),
          child: Column(
            children: [
              _buildTableHeader(),
              _buildDataRow('Limpiador multiusos Pro', '#V-0041', '\$89.00', '3', '\$267.00', '12 jun 2026', 'Completado', Colors.green),
              _buildDataRow('Desinfectante', '#V-0042', '\$145.50', '2', '\$291.00', '14 jun 2026', 'Completado', Colors.green),
              _buildDataRow('Jabón industrial', '#V-0043', '\$62.00', '5', '\$310.00', '17 jun 2026', 'Pendiente', Colors.orange),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: CleanStockTheme.textDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Expanded(child: Text('PRODUCTO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(child: Text('FOLIO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(child: Text('TOTAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(child: Text('ESTADO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDataRow(String prod, String folio, String price, String cant, String total, String date, String status, Color statusColor) {
    return ListTile(
      title: Text(prod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      subtitle: Text('$folio • $date'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(total, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildStatsFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: CleanStockTheme.textDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Ventas totales: 3 registros', style: TextStyle(color: Colors.white, fontSize: 12)),
          Text('Total período: \$868.00 MXN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
