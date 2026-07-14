import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean_stock/presentacion/pantallas/configuracion/inicio_sesion.dart'; 
import 'package:clean_stock/presentacion/pantallas/inicio/inicio_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xiespxnjnefikzrqehgk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpZXNweG5qbmVmaWt6cnFlaGdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM5ODgyNzMsImV4cCI6MjA5OTU2NDI3M30.eoIcXPsbDB3jVvwZ7VOGhPLmZf3zBxB4nig3X31Hd40',
  );

  final prefs = await SharedPreferences.getInstance();
  final String? idEmpleadoGuardado = prefs.getString('id_empleado');

  runApp(MyApp(idEmpleado: idEmpleadoGuardado));
}

class MyApp extends StatelessWidget {
  final String? idEmpleado;
  
  const MyApp({Key? key, this.idEmpleado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF62A5DF)),
        useMaterial3: true,
      ),
      home: idEmpleado != null ? const CleanStockHomeScreen() : const LoginPantalla(),
    );
  }
}