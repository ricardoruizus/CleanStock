import 'package:flutter/material.dart';
import 'package:clean_stock/core/theme.dart';

class Supplier {
  final String id;
  final String name;
  final String category;
  final String phone;
  final String status;

  Supplier({required this.id, required this.name, required this.category, required this.phone, required this.status});
}

class CleanStockSuppliersScreen extends StatefulWidget {
  const CleanStockSuppliersScreen({Key? key}) : super(key: key);

  @override
  State<CleanStockSuppliersScreen> createState() => _CleanStockSuppliersScreenState();
}

class _CleanStockSuppliersScreenState extends State<CleanStockSuppliersScreen> {
  final List<Supplier> _allSuppliers = [
    Supplier(id: '1', name: 'Whiskas', category: 'Comida', phone: '+52 55 1234 5678', status: 'Activo'),
    Supplier(id: '2', name: 'Pedigreen', category: 'Comida', phone: '+52 55 8765 4321', status: 'Activo'),
    Supplier(id: '3', name: 'Pinol', category: 'Limpieza', phone: '+52 33 4567 8901', status: 'Activo'),
    Supplier(id: '4', name: 'Fabuloso', category: 'Limpieza', phone: '+52 33 2345 6789', status: 'Revisión'),
  ];

  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Comida', 'Limpieza', 'Dulces'];

  List<Supplier> get _filteredSuppliers {
    if (_selectedCategory == 'Todos') return _allSuppliers;
    return _allSuppliers.where((s) => s.category == _selectedCategory).toList();
  }

  void _addSupplierDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoría')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allSuppliers.add(Supplier(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  category: categoryController.text,
                  phone: phoneController.text,
                  status: 'Activo',
                ));
                if (!_categories.contains(categoryController.text)) {
                  _categories.add(categoryController.text);
                }
              });
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
      appBar: AppBar(title: const Text('Proveedores', style: TextStyle(color: CleanStockTheme.textDark, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: Column(
        children: [
          _buildToolbar(),
          _buildCategoryFilter(),
          Expanded(child: _buildSuppliersTable()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSupplierDialog,
        backgroundColor: CleanStockTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true, fillColor: CleanStockTheme.background),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(_categories[i]),
            selected: _selectedCategory == _categories[i],
            onSelected: (selected) => setState(() => _selectedCategory = _categories[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuppliersTable() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSuppliers.length,
      itemBuilder: (context, i) {
        final s = _filteredSuppliers[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.category} • ${s.phone}'),
            trailing: Chip(label: Text(s.status), backgroundColor: s.status == 'Activo' ? Colors.green.shade100 : Colors.orange.shade100),
          ),
        );
      },
    );
  }
}
