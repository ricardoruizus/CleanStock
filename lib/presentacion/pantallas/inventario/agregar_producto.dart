import 'package:flutter/material.dart';

class AgregarProductoScreen extends StatelessWidget {
  const AgregarProductoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF7),
      appBar: AppBar(
        title: const Text('Agregar producto', style: TextStyle(color: Color(0xFF294E69))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF65ABDE)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImageUpload(),
            const SizedBox(height: 16),
            _buildCategorySection(),
            const SizedBox(height: 16),
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFADCBE3), style: BorderStyle.solid),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, color: Color(0xFF65ABDE), size: 30),
            Text('Foto del producto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF294E69))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CATEGORÍA DEL PRODUCTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9AB4C8))),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCategoryChip(Icons.water_drop, 'Limpieza', true),
            const SizedBox(width: 8),
            _buildCategoryChip(Icons.air, 'Aromas', false),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDEEEF8) : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: isSelected ? const Color(0xFF65ABDE) : const Color(0xFFADCBE3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF294E69) : const Color(0xFFADCBE3)),
          Text(label, style: TextStyle(fontSize: 8, color: isSelected ? const Color(0xFF294E69) : const Color(0xFFADCBE3))),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFADCBE3)),
      ),
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.inventory_2, color: Color(0xFF65ABDE)),
            title: Text('Nombre del producto', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            subtitle: Text('Ingresar nombre...'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.qr_code, color: Color(0xFF4A87B4)),
            title: Text('Código de barras', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            subtitle: Text('Escanear o ingresar...'),
          ),
        ],
      ),
    );
  }
}
