import 'package:flutter/material.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF7),
      appBar: AppBar(
        title: const Text('Inventario', style: TextStyle(color: Color(0xFF294E69))),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: const Center(child: Text('Implementación de Inventario')),
    );
  }
}
