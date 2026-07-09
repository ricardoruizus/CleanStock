import 'package:flutter/material.dart';
import 'presentacion/pantallas/configuracion/iniciosesion.dart';

void main() {
  runApp(const CleanStockApp());
}

class CleanStockApp extends StatelessWidget {
  const CleanStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65abde),
        ),
        useMaterial3: true,
      ),
      home: const LoginPantalla(),
    );
  }
}