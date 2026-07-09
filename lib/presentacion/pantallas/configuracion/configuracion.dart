import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF7),
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Color(0xFF294E69))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF65ABDE)),
      ),
      body: const Center(
        child: Text('Implementación de Configuración'),
      ),
    );
  }
}
