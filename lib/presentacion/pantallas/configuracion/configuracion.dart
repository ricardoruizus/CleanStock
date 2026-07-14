import 'package:flutter/material.dart';

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
  int _navActivo = 0; // 0: General, 1: Cuenta, 2: Apariencia
  bool _isDarkMode = false; // Control del tema

  // --- DATOS DEL USUARIO (Vacíos, listos para Supabase) ---
  final Map<String, String> _userData = {
    'nombre': '',
    'iniciales': '',
    'rol': '',
    'edad': '',
    'correo': '',
    'password': '', // La contraseña real no se trae, esto es solo visual
  };

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
    bool isLoading = _userData['nombre']!.isEmpty;

    return Container(
      width: 260,
      color: leftColBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                // Avatar
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
                        isLoading ? '-' : _userData['iniciales']!,
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
                Text(isLoading ? 'Cargando usuario...' : _userData['nombre']!, style: TextStyle(color: primaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDEEEF8), borderRadius: BorderRadius.circular(6)),
                  child: Text(isLoading ? '...' : _userData['rol']!, style: TextStyle(color: primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {},
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
          
          const Spacer(),
          
          // BOTÓN CERRAR SESIÓN
          InkWell(
            onTap: () {
              // Lógica de Supabase Auth SignOut
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF09595), width: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 16, color: Color(0xFFA32D2D)),
                  const SizedBox(width: 8),
                  const Text('Cerrar sesión', style: TextStyle(color: Color(0xFFA32D2D), fontSize: 12, fontWeight: FontWeight.bold)),
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
    bool isLoading = _userData['nombre']!.isEmpty;

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
              _buildSettingRow(Icons.person, const Color(0xFF65ABDE), 'Nombre', isLoading ? '-' : _userData['nombre']!),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow(Icons.cake, const Color(0xFF4A87B4), 'Edad', isLoading ? '-' : '${_userData['edad']} años'),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow(Icons.mail, const Color(0xFF4A87B4), 'Correo electrónico', isLoading ? '-' : _userData['correo']!),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildSettingRow(Icons.lock, const Color(0xFF294E69), 'Contraseña', '••••••••', isSecure: true),
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
              _buildSettingRow(Icons.calendar_month, const Color(0xFFADCBE3), 'Fecha del dispositivo', '24 de junio, 2026', showEdit: false),
              Divider(height: 1, color: borderLight.withOpacity(0.5)),
              _buildThemeToggleRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(IconData icon, Color color, String label, String value, {bool isSecure = false, bool showEdit = true}) {
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
              onTap: () {},
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