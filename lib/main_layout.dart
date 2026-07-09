import 'package:flutter/material.dart';
import 'presentacion/pantallas/inicio/iniciohomescreen.dart';
import 'presentacion/pantallas/inventario_principal/inventario_principal.dart';
import 'presentacion/pantallas/ventas/registro_ventas.dart';
import 'presentacion/pantallas/proveedores/proveedores.dart';
import 'presentacion/pantallas/configuracion/configuracion.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InicioHomeScreen(), // Asegúrate de que este archivo exista
    const InventarioScreen(),
    const RegistroVentasScreen(),
    const ProveedoresScreen(), // Asegúrate de que este archivo exista
    const ConfiguracionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF65ABDE),
        unselectedItemColor: const Color(0xFFADCBE3),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Proveedores'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
