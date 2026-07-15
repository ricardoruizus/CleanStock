import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inicio_sesion.dart'; // <-- Importación agregada

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);
  final Color leftColBg = const Color(0xFFF0F6FB);

  // --- VARIABLES DE ESTADO ---
  int _navActivo = 1; 
  bool _isDarkMode = false;
  bool _isLoading = true;
  String? _idEmpleado;

  // --- DATOS DINÁMICOS DEL USUARIO ---
  final Map<String, String> _userData = {
    'nombre': 'Usuario',
    'iniciales': 'US',
    'rol': 'Cargando...',
    'edad': '0',
    'correo': '',
    'password': '', 
  };

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // --- OBTENER DATOS DESDE SUPABASE ---
  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _idEmpleado = prefs.getString('id_empleado');

      if (_idEmpleado != null) {
        final List<dynamic> response = await Supabase.instance.client
            .from('usuarios')
            .select()
            .eq('id_empleado', _idEmpleado!.trim());

        if (response.isNotEmpty && mounted) {
          final usuario = response.first;
          setState(() {
            _userData['nombre'] = usuario['nombre_completo'] ?? 'Sin Nombre';
            _userData['rol'] = usuario['rol'] ?? 'Empleado';
            _userData['edad'] = (usuario['edad'] ?? 0).toString();
            _userData['correo'] = usuario['correo'] ?? '';
            _userData['password'] = usuario['contrasena_hash'] ?? '';
            
            // Generar iniciales automáticamente
            _actualizarInicialesLocal(_userData['nombre']!);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando configuración del usuario: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _actualizarInicialesLocal(String nombre) {
    List<String> palabras = nombre.trim().split(" ");
    if (palabras.length >= 2) {
      _userData['iniciales'] = "${palabras[0][0]}${palabras[1][0]}".toUpperCase();
    } else if (palabras.isNotEmpty && palabras[0].isNotEmpty) {
      _userData['iniciales'] = palabras[0][0].toUpperCase();
    } else {
      _userData['iniciales'] = "US";
    }
  }

  // --- ACTUALIZAR EN SUPABASE Y LOCAL ---
  Future<void> _actualizarDatoUsuario(String clave, String nuevoValor) async {
    if (_idEmpleado == null) return;

    // Determinar qué columna mapear en PostgreSQL
    String columnaBd;
    dynamic valorProcesado = nuevoValor;

    switch (clave) {
      case 'nombre':
        columnaBd = 'nombre_completo';
        break;
      case 'edad':
        columnaBd = 'edad';
        valorProcesado = int.tryParse(nuevoValor) ?? 0;
        break;
      case 'correo':
        columnaBd = 'correo';
        break;
      case 'password':
        columnaBd = 'contrasena_hash';
        break;
      default:
        return;
    }

    try {
      // 1. Actualizar en Supabase
      await Supabase.instance.client
          .from('usuarios')
          .update({columnaBd: valorProcesado})
          .eq('id_empleado', _idEmpleado!.trim());

      // 2. Si se actualizó el nombre completo, actualizar localmente en SharedPreferences para consistencia con el Home
      if (clave == 'nombre') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nombre_completo', nuevoValor);
      }

      // 3. Actualizar la interfaz local
      setState(() {
        _userData[clave] = nuevoValor;
        if (clave == 'nombre') {
          _actualizarInicialesLocal(nuevoValor);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración actualizada con éxito.'),
            backgroundColor: Color(0xFF2E9E8A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error actualizando usuario en base de datos: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- MOSTRAR PANTALLA/DIALOGO DE EDICIÓN ---
  void _mostrarPantallaEdicion(String clave, String titulo, String valorActual) {
    final TextEditingController controller = TextEditingController(text: valorActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Editar $titulo',
            style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            obscureText: clave == 'password',
            keyboardType: clave == 'edad' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Introduce el nuevo $titulo',
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryLight)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _actualizarDatoUsuario(clave, controller.text.trim());
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // COLUMNA IZQUIERDA (Perfil y Menú)
          _buildLeftColumn(),

          // COLUMNA DERECHA (Formularios de Configuración)
          Expanded(
            child: Container(
              color: bgLight,
              child: _buildRightColumn(),
            ),
          ),
        ],
      ),
    );
  }

  // --- APPBAR ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: borderLight, height: 0.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text('CLEANSTOCK', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(width: 8),
          Text('/', style: TextStyle(color: borderLight)),
          const SizedBox(width: 8),
          Text('Configuración', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.help_outline, color: primaryLight), onPressed: () {}),
        IconButton(icon: Icon(Icons.notifications_none, color: primaryLight), onPressed: () {}),
        const SizedBox(width: 16),
      ],
    );
  }

  // --- COLUMNA IZQUIERDA ---
  Widget _buildLeftColumn() {
    return Container(
      width: 260,
      color: leftColBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TARJETA DE PERFIL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderLight, width: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 62, height: 62,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDEEEF8),
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryLight, width: 2.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _isLoading ? '-' : _userData['iniciales']!,
                                style: TextStyle(color: primaryDark, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: primaryLight, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                              child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? 'Cargando usuario...' : _userData['nombre']!, 
                          style: TextStyle(color: primaryDark, fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFDEEEF8), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            _isLoading ? '...' : _userData['rol']!, 
                            style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _mostrarPantallaEdicion('nombre', 'Nombre de Usuario', _userData['nombre']!),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo, size: 14, color: primaryLight),
                                const SizedBox(width: 6),
                                Text('Cambiar foto de perfil', style: TextStyle(color: primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // NAVEGACIÓN
                  Text('SECCIONES', style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderLight, width: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildNavItem(0, Icons.settings, 'General', const Color(0xFF65ABDE)),
                        Divider(height: 1, color: borderLight.withOpacity(0.5)),
                        _buildNavItem(1, Icons.person, 'Cuenta', const Color(0xFF4A87B4)),
                        Divider(height: 1, color: borderLight.withOpacity(0.5)),
                        _buildNavItem(2, Icons.palette, 'Apariencia', const Color(0xFF294E69)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // BOTÓN CERRAR SESIÓN (Navegación Directa)
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Limpia los datos guardados en el dispositivo[cite: 3]
              
              if (mounted) {
                // Navega directamente a la LoginPantalla y elimina todo el historial previo
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPantalla()),
                  (route) => false,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF09595), width: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 16, color: Color(0xFFA32D2D)),
                  SizedBox(width: 8),
                  Text('Cerrar sesión', style: TextStyle(color: Color(0xFFA32D2D), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color dotColor) {
    bool isActive = _navActivo == index;
    return InkWell(
      onTap: () => setState(() => _navActivo = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: isActive ? const Color(0xFFDEEEF8) : Colors.white),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: dotColor, borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: borderLight),
          ],
        ),
      ),
    );
  }

  // --- COLUMNA DERECHA ---
  Widget _buildRightColumn() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryLight),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // DATOS DE LA CUENTA
        Text('DATOS DE LA CUENTA', style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildSettingRow('nombre', Icons.person, const Color(0xFF65ABDE), 'Nombre', _userData['nombre']!),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow('edad', Icons.cake, const Color(0xFF4A87B4), 'Edad', '${_userData['edad']} años'),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow('correo', Icons.mail, const Color(0xFF4A87B4), 'Correo electrónico', _userData['correo']!),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow('password', Icons.lock, const Color(0xFF294E69), 'Contraseña', '••••••••', isSecure: true),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // APARIENCIA Y SISTEMA
        Text('APARIENCIA Y SISTEMA', style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildSettingRow('', Icons.calendar_month, const Color(0xFFADCBE3), 'Fecha del dispositivo', '14 de julio, 2026', showEdit: false),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildThemeToggleRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String clave, IconData icon, Color color, String label, String value, {bool isSecure = false, bool showEdit = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: textMuted, 
                    fontSize: isSecure ? 14 : 11, 
                    letterSpacing: isSecure ? 2.0 : 0.0,
                    fontWeight: isSecure ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
          if (showEdit)
            InkWell(
              onTap: () => _mostrarPantallaEdicion(clave, label, _userData[clave]!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 12, color: primaryLight),
                    const SizedBox(width: 4),
                    Text('Editar', style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF294E69), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.dark_mode, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modo de diseño', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(_isDarkMode ? 'Oscuro activo' : 'Claro activo', style: TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildThemeBtn('Claro', Icons.light_mode, !_isDarkMode),
                _buildThemeBtn('Oscuro', Icons.dark_mode, _isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeBtn(String text, IconData icon, bool isActive) {
    return InkWell(
      onTap: () => setState(() => _isDarkMode = text == 'Oscuro'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: isActive ? primaryDark : textMuted),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(color: isActive ? primaryDark : textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}