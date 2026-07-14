import 'package:flutter/material.dart';
import 'package:clean_stock/core/theme.dart';
import 'package:clean_stock/presentacion/pantallas/configuracion/inicio_sesion.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _nombre = 'Administrador';
  String _correo = 'admin@cleanstock.mx';

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $title'),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanStockTheme.background,
      appBar: AppBar(title: const Text('Configuración', style: TextStyle(color: CleanStockTheme.textDark, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: CleanStockTheme.border, child: Icon(Icons.person, size: 40, color: CleanStockTheme.primary)),
                const SizedBox(height: 12),
                Text(_nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_correo, style: const TextStyle(color: CleanStockTheme.textLight)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup('Cuenta', [
            _buildSettingsRow(Icons.person_outline, 'Nombre', _nombre, () => _showEditDialog('Nombre', _nombre, (v) => setState(() => _nombre = v))),
            _buildSettingsRow(Icons.mail_outline, 'Correo', _correo, () => _showEditDialog('Correo', _correo, (v) => setState(() => _correo = v))),
          ]),
          _buildSettingsGroup('Sistema', [
            _buildSettingsRow(Icons.palette_outlined, 'Apariencia', 'Claro', () {}),
            _buildSettingsRow(Icons.notifications_none, 'Notificaciones', 'Activadas', () {}),
          ]),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPantalla()), (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CleanStockTheme.textLight))),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsRow(IconData icon, String label, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: CleanStockTheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit, size: 18, color: CleanStockTheme.textLight),
      onTap: onTap,
    );
  }
}
