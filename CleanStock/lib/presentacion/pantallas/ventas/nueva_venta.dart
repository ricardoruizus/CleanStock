import 'package:flutter/material.dart';
import 'package:clean_stock/core/theme.dart';
import 'package:clean_stock/core/models.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final List<ProductModel> _allProducts = [
    ProductModel(id: '1', name: 'Detergente Líquido 1L', sku: '750102030405', category: 'Limpieza', stock: 24, price: 45.00),
    ProductModel(id: '2', name: 'Desinfectante de Pino 900ml', sku: '750112233445', category: 'Limpieza', stock: 42, price: 35.00),
  ];

  final List<Map<String, dynamic>> _cart = [];
  String _searchQuery = '';

  List<ProductModel> get _filteredProducts => _allProducts
      .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  double get _total => _cart.fold(0, (sum, item) => sum + (item['product'].price * item['quantity']));

  void _addToCart(ProductModel product) {
    setState(() {
      int index = _cart.indexWhere((item) => item['product'].id == product.id);
      if (index != -1) {
        _cart[index]['quantity']++;
      } else {
        _cart.add({'product': product, 'quantity': 1});
      }
    });
  }

  void _confirmSale() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Venta Exitosa'),
        content: Text('Total cobrado: \$${_total.toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () {
            setState(() => _cart.clear());
            Navigator.pop(context);
          }, child: const Text('Aceptar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanStockTheme.background,
      appBar: AppBar(title: const Text('Nueva Venta', style: TextStyle(color: CleanStockTheme.textDark, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5),
      body: Row(
        children: [
          // Lado Izquierdo: Buscador y Productos
          Expanded(flex: 2, child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: TextField(
              decoration: InputDecoration(hintText: 'Buscar producto...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              onChanged: (val) => setState(() => _searchQuery = val),
            )),
            Expanded(child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_filteredProducts[i].name),
                trailing: IconButton(icon: const Icon(Icons.add_circle, color: CleanStockTheme.accent), onPressed: () => _addToCart(_filteredProducts[i])),
              ),
            )),
          ])),
          // Lado Derecho: Carrito
          Expanded(flex: 1, child: Container(
            color: Colors.white,
            child: Column(children: [
              const Padding(padding: EdgeInsets.all(16), child: Text('Carrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Expanded(child: ListView.builder(
                itemCount: _cart.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(_cart[i]['product'].name),
                  subtitle: Text('${_cart[i]['quantity']} x \$${_cart[i]['product'].price}'),
                ),
              )),
              Container(padding: const EdgeInsets.all(16), child: Column(children: [
                Text('Total: \$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _cart.isEmpty ? null : _confirmSale, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('Confirmar Venta')),
              ])),
            ]),
          )),
        ],
      ),
    );
  }
}
