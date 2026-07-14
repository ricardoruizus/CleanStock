import 'package:flutter/material.dart';
import 'package:clean_stock/presentacion/pantallas/configuracion/inicio_sesion.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF62A5DF)),
        useMaterial3: true,
      ),
      home: const LoginPantalla(), // Abre directamente tu inicio
    );
  }
}