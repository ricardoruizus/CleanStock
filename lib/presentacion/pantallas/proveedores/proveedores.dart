// ==========================================================================
// CleanStock Suppliers Screen (Dart / Flutter) - TOTALMENTE OPTIMIZADO
// Ubicación sugerida: lib/presentacion/pantallas/proveedores/proveedores_screen.dart
// ==========================================================================

import 'package:flutter/material.dart';

// ----------------------------------------------------
// MODELOS DE DATOS
// ----------------------------------------------------

enum SupplierStatus {
  activo,
  revision,
  inactivos,
}

extension SupplierStatusExtension on SupplierStatus {
  String get label {
    switch (this) {
      case SupplierStatus.activo:
        return 'Activo';
      case SupplierStatus.revision:
        return 'Revisión';
      case SupplierStatus.inactivos:
        return 'Inactivo';
    }
  }

  Color get bgColor {
    switch (this) {
      case SupplierStatus.activo:
        return const Color(0xFFE8F5E9);
      case SupplierStatus.revision:
        return const Color(0xFFFFF3E0);
      case SupplierStatus.inactivos:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get textColor {
    switch (this) {
      case SupplierStatus.activo:
        return const Color(0xFF2E7D32);
      case SupplierStatus.revision:
        return const Color(0xFFE65100);
      case SupplierStatus.inactivos:
        return const Color(0xFFC62828);
    }
  }
}

class Supplier {
  final String id;
  final String name;
  final String category;
  final String contact;
  final String phone;
  final SupplierStatus status;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.contact,
    required this.phone,
    required this.status,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? category,
    String? contact,
    String? phone,
    SupplierStatus? status,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }
}

// ----------------------------------------------------
// TEMA / COLORES CONSTANTES (Alineados con CleanStock)
// ----------------------------------------------------

class CleanStockTheme {
  static const Color primary = Color(0xFF62A5DF);      // Azul pastel característico
  static const Color tableHeader = Color(0xFF1E2E40);  // Azul oscuro de la marca
  static const Color background = Color(0xFFEBF2FA);   // Fondo azul pastel general
  static const Color accentBlue = Color(0xFFEFF6FF);
  static const Color textDark = Color(0xFF1E2E40);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color borderSide = Color(0xFFD0E1F4);
}

// ----------------------------------------------------
// PANTALLA PRINCIPAL DE PROVEEDORES
// ----------------------------------------------------

class CleanStockSuppliersScreen extends StatefulWidget {
  const CleanStockSuppliersScreen({Key? key}) : super(key: key);

  @override
  State<CleanStockSuppliersScreen> createState() => _CleanStockSuppliersScreenState();
}

class _CleanStockSuppliersScreenState extends State<CleanStockSuppliersScreen> {
  late List<Supplier> _suppliers;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Todos';
  int _currentNavIndex = 3; // Index de Proveedores

  final Map<String, String> _categoryIcons = {
    'Comida': '🥫',
    'Limpieza': '🧹',
    'Dulces': '🍬',
    'Otros': '📦',
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _suppliers = [
      Supplier(id: '1', name: 'Whiskas', category: 'Comida', contact: 'Dist. mascotas', phone: '+52 55 1234 5678', status: SupplierStatus.activo),
      Supplier(id: '2', name: 'Pedigree', category: 'Comida', contact: 'Dist. mascotas', phone: '+52 55 8765 4321', status: SupplierStatus.activo),
      Supplier(id: '3', name: 'Pinol', category: 'Limpieza', contact: 'Limpieza hogar', phone: '+52 33 4567 8901', status: SupplierStatus.activo),
      Supplier(id: '4', name: 'Fabuloso', category: 'Limpieza', contact: 'Limpieza hogar', phone: '+52 33 2345 6789', status: SupplierStatus.revision),
      Supplier(id: '5', name: 'Marinela', category: 'Dulces', contact: 'Dist. dulces', phone: '+52 55 9876 5432', status: SupplierStatus.activo),
      Supplier(id: '6', name: 'Barcel', category: 'Dulces', contact: 'Dist. dulces', phone: '+52 55 1122 3344', status: SupplierStatus.revision),
    ];
  }

  List<Supplier> get _filteredSuppliers {
    return _suppliers.where((supplier) {
      final matchesSearch = supplier.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          supplier.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          supplier.contact.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedCategoryFilter == 'Todos') {
        return true;
      } else if (_selectedCategoryFilter == 'Activos') {
        return supplier.status == SupplierStatus.activo;
      } else {
        return supplier.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();
      }
    }).toList();
  }

  Map<String, List<Supplier>> get _groupedSuppliers {
    final Map<String, List<Supplier>> groups = {};
    for (var supplier in _filteredSuppliers) {
      if (!groups.containsKey(supplier.category)) {
        groups[supplier.category] = [];
      }
      groups[supplier.category]!.add(supplier);
    }
    return groups;
  }

  void _addSupplier(Supplier supplier) {
    setState(() {
      _suppliers.add(supplier);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proveedor "${supplier.name}" agregado con éxito.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editSupplier(Supplier updatedSupplier) {
    setState(() {
      final index = _suppliers.indexWhere((s) => s.id == updatedSupplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proveedor "${updatedSupplier.name}" actualizado.'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteSupplier(String id) {
    final supplierName = _suppliers.firstWhere((s) => s.id == id).name;
    setState(() {
      _suppliers.removeWhere((s) => s.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proveedor "$supplierName" ya fue eliminado.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 760;

    return Scaffold(
      backgroundColor: CleanStockTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isTablet),
            _buildSearchAndFilters(),
            Expanded(
              child: _suppliers.isEmpty
                  ? _buildEmptyState()
                  : _buildSuppliersTable(isTablet),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: CleanStockTheme.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'CLEANSTOCK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A4E6C),
                        letterSpacing: 0.5,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('/', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
              const Text(
                'Proveedores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: CleanStockTheme.textDark),
              ),
            ],
          ),
          Row(
            children: [
              if (isTablet) ...[
                _buildIconButton(
                  icon: Icons.download_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Descargando reporte de proveedores...'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.tune_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtros avanzados activos...'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: () => _showAddSupplierDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar proveedor', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CleanStockTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF475569), size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final categories = ['Todos', 'Activos', 'Limpieza', 'Comida', 'Dulces'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Buscar proveedor o categoría...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategoryFilter = cat),
                    selectedColor: CleanStockTheme.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: CleanStockTheme.accentBlue, shape: BoxShape.circle),
            child: const Icon(Icons.people_outline_rounded, size: 64, color: CleanStockTheme.primary),
          ),
          const SizedBox(height: 16),
          const Text('No hay proveedores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CleanStockTheme.textDark)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddSupplierDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Proveedor'),
            style: ElevatedButton.styleFrom(backgroundColor: CleanStockTheme.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersTable(bool isTablet) {
    final groups = _groupedSuppliers;
    final categoriesOrdered = groups.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: CleanStockTheme.tableHeader,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildTableHeaderText('PROVEEDOR')),
                if (isTablet) ...[
                  Expanded(flex: 2, child: _buildTableHeaderText('CONTACTO')),
                  Expanded(flex: 2, child: _buildTableHeaderText('TELÉFONO')),
                ],
                Expanded(flex: 2, child: _buildTableHeaderText('ESTADO')),
                const SizedBox(width: 40, child: Center(child: Text('编辑', style: TextStyle(color: Colors.transparent, fontSize: 1))) )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categoriesOrdered.length,
              itemBuilder: (context, index) {
                final categoryName = categoriesOrdered[index];
                final categorySuppliers = groups[categoryName] ?? [];
                final categoryIcon = _categoryIcons[categoryName] ?? '📦';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: const Color(0xFFE2F0FD).withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Text('$categoryIcon $categoryName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CleanStockTheme.textDark)),
                          const SizedBox(width: 8),
                          Text('(${categorySuppliers.length})', style: const TextStyle(fontSize: 12, color: CleanStockTheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ...categorySuppliers.map((supplier) => _buildSupplierRow(supplier, isTablet)).toList(),
                  ],
                );
              },
            ),
          ),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeaderText(String text) {
    return Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5));
  }

  Widget _buildSupplierRow(Supplier supplier, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, color: CleanStockTheme.textDark, fontSize: 14)),
                if (!isTablet) ...[
                  const SizedBox(height: 2),
                  Text('${supplier.contact} • ${supplier.phone}', style: const TextStyle(color: CleanStockTheme.textLight, fontSize: 12)),
                ]
              ],
            ),
          ),
          if (isTablet) ...[
            Expanded(flex: 2, child: Text(supplier.contact, style: const TextStyle(color: CleanStockTheme.textDark, fontSize: 13))),
            Expanded(flex: 2, child: Text(supplier.phone, style: const TextStyle(color: CleanStockTheme.textLight, fontSize: 13))),
          ],
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: supplier.status.bgColor, borderRadius: BorderRadius.circular(6)),
                child: Text(supplier.status.label, style: TextStyle(color: supplier.status.textColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.edit_note_rounded, size: 22, color: CleanStockTheme.primary),
              padding: EdgeInsets.zero,
              onPressed: () => _showAddSupplierDialog(existingSupplier: supplier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableFooter() {
    return Container(
      color: CleanStockTheme.tableHeader,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Categorías: ${_suppliers.map((s) => s.category).toSet().length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          Text('Total: ${_suppliers.length} proveedores', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'icon': Icons.grid_view, 'label': 'Inicio'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Inventario'},
      {'icon': Icons.trending_up, 'label': 'Ventas'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Proveedores'},
      {'icon': Icons.settings_outlined, 'label': 'Config'},
    ];

    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEFF6FF), width: 1.5))),
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = _currentNavIndex == index;
          final color = isSelected ? CleanStockTheme.primary : const Color(0xFF94A3B8);

          return GestureDetector(
            onTap: () => setState(() => _currentNavIndex = index),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, color: color, size: 22),
                  const SizedBox(height: 2),
                  Text(item['label'] as String, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------
  // FORMULARIO DE DIÁLOGO COMPLETADO Y REFACTORIZADO
  // ----------------------------------------------------
  void _showAddSupplierDialog({Supplier? existingSupplier}) {
    final isEdit = existingSupplier != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: isEdit ? existingSupplier.name : '');
    final contactController = TextEditingController(text: isEdit ? existingSupplier.contact : '');
    final phoneController = TextEditingController(text: isEdit ? existingSupplier.phone : '');
    
    String selectedCategory = isEdit ? existingSupplier.category : 'Comida';
    SupplierStatus selectedStatus = isEdit ? existingSupplier.status : SupplierStatus.activo;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFEBF2FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: CleanStockTheme.tableHeader,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Editar Proveedor' : 'Nuevo Proveedor',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _buildDialogInputField(label: 'Nombre del Proveedor', hint: 'Ej. Whiskas', controller: nameController),
                      const SizedBox(height: 12),
                      _buildDialogInputField(label: 'Giro / Contacto', hint: 'Ej. Distribuidor', controller: contactController),
                      const SizedBox(height: 12),
                      _buildDialogInputField(label: 'Teléfono', hint: '+52...', controller: phoneController, keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      
                      // Selector de Categorías Estilizado
                      _buildDialogDropdownField<String>(
                        label: 'Categoría',
                        value: selectedCategory,
                        items: ['Comida', 'Limpieza', 'Dulces'],
                        onChanged: (val) => setDialogState(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 12),

                      // Selector de Estado Estilizado
                      _buildDialogDropdownField<SupplierStatus>(
                        label: 'Estado del Proveedor',
                        value: selectedStatus,
                        items: SupplierStatus.values,
                        itemLabelBuilder: (status) => status.label,
                        onChanged: (val) => setDialogState(() => selectedStatus = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, bottom: 16),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isEdit)
                      TextButton.icon(
                        label: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                        icon: const Icon(Icons.delete_forever_rounded, size: 18),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () {
                          _deleteSupplier(existingSupplier.id);
                          Navigator.pop(context);
                        },
                      )
                    else
                      const SizedBox(),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CleanStockTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final supplier = Supplier(
                                id: isEdit ? existingSupplier.id : DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameController.text.trim(),
                                category: selectedCategory,
                                contact: contactController.text.trim(),
                                phone: phoneController.text.trim(),
                                status: selectedStatus,
                              );
                              if (isEdit) _editSupplier(supplier); else _addSupplier(supplier);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEdit ? 'Guardar' : 'Agregar', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Métodos Auxiliares para renderizar Inputs idénticos a Login/Registro
  Widget _buildDialogInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CleanStockTheme.borderSide, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: CleanStockTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: CleanStockTheme.textDark, fontWeight: FontWeight.w500),
            decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 13)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? itemLabelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CleanStockTheme.borderSide, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: CleanStockTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<T>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabelBuilder != null ? itemLabelBuilder(item) : item.toString(), style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}