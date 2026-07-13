import 'package:flutter/material.dart';
// Importa el archivo de tu inicio de sesión (ajusta la ruta exacta de tu proyecto)
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // CORRECCIÓN: El nombre correcto de la clase según tu código es LoginPantalla
      home: const LoginPantalla(), 
    );
  }
}