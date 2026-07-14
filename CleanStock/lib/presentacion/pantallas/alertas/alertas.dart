import 'package:flutter/material.dart';
import 'package:clean_stock/core/theme.dart';

class AlertasScreen extends StatelessWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanStockTheme.background,
      appBar: AppBar(
        title: Text('Centro de Alertas', style: TextStyle(color: CleanStockTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildFilterTabs(),
                Expanded(child: _buildAlertsTable()),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildActionPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildPill('Activas', true),
          const SizedBox(width: 8),
          _buildPill('Resueltas', false),
        ],
      ),
    );
  }

  Widget _buildPill(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? CleanStockTheme.accent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CleanStockTheme.border),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : CleanStockTheme.textLight, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAlertsTable() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildAlertRow('Jabón Líquido', '2', 'Agotado', Colors.red),
              const Divider(),
              _buildAlertRow('Mopa Microfibra', '15', 'Bajo Stock', Colors.orange),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAlertRow(String name, String stock, String status, Color statusColor) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Stock: $stock'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: CleanStockTheme.border))),
      child: Column(
        children: [
          Text('Acciones Sugeridas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: Text('Generar orden de compra')),
        ],
      ),
    );
  }
}
