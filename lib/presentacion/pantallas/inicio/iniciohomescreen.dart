import 'package:flutter/material.dart';

/// Modelo de datos interno para cada módulo/tarjeta del Dashboard
class DashboardCardData {
  final String id;
  final String title;
  final String subtitle;
  final IconData mainIcon;
  final String? badgeValue;
  final List<IconData> subIcons;
  final Color circleBgColor;

  const DashboardCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mainIcon,
    this.badgeValue,
    required this.subIcons,
    required this.circleBgColor,
  });
}

class CleanStockHomeScreen extends StatefulWidget {
  const CleanStockHomeScreen({Key? key}) : super(key: key);

  @override
  State<CleanStockHomeScreen> createState() => _CleanStockHomeScreenState();
}

class _CleanStockHomeScreenState extends State<CleanStockHomeScreen> {
  // Configuración de Paleta de Colores (Fieles al diseño original)
  static const Color primaryColor = Color(0xFF1E88E5);      // Azul CleanStock
  static const Color primaryLightColor = Color(0xFFE3F2FD); // Fondo interactivo seleccionado
  static const Color accentColor = Color(0xFF42A5F5);       // Degradado secundario
  static const Color screenBgColor = Color(0xFFF1F5FA);     // Fondo del lienzo general
  static const Color sidebarBgColor = Colors.white;

  // Estado de navegación activa
  int _activeNavIndex = 0; // 0: Inicio, 1: Alertas, 2: Config

  // Estado y controladores de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Listado oficial de Módulos (Exactamente con los iconos y badges de la imagen)
  final List<DashboardCardData> _allCards = [
    const DashboardCardData(
      id: 'inventario',
      title: 'Inventario',
      subtitle: 'Gestión de productos',
      mainIcon: Icons.inventory_2_outlined,
      badgeValue: '4',
      circleBgColor: Color(0xFFE3F2FD),
      subIcons: [
        Icons.all_inbox_rounded,        // Box icon
        Icons.qr_code_scanner_rounded, // Scan icon
        Icons.sync_alt_rounded,        // Sync icon
      ],
    ),
    const DashboardCardData(
      id: 'ventas',
      title: 'Ventas',
      subtitle: 'Historial y análisis',
      mainIcon: Icons.trending_up_rounded,
      badgeValue: null,
      circleBgColor: Color(0xFFE0F2F1), // Verde azulado pastel suave
      subIcons: [
        Icons.auto_graph_rounded,       // Chart icon
        Icons.currency_exchange_rounded, // Coins icon
        Icons.local_offer_outlined,     // Tag icon
      ],
    ),
    const DashboardCardData(
      id: 'proveedores',
      title: 'Proveedores',
      subtitle: 'Directorio de contactos',
      mainIcon: Icons.local_shipping_outlined,
      badgeValue: null,
      circleBgColor: Color(0xFFE3F2FD),
      subIcons: [
        Icons.storefront_rounded,      // Home icon
        Icons.badge_outlined,          // Card ID icon
        Icons.location_on_outlined,    // Pin icon
      ],
    ),
    const DashboardCardData(
      id: 'registro_venta',
      title: 'Registro de venta',
      subtitle: 'Nueva transacción',
      mainIcon: Icons.receipt_long_outlined,
      badgeValue: '!',
      circleBgColor: Color(0xFFECEFF1), // Gris slate pastel suave
      subIcons: [
        Icons.edit_note_rounded,       // Pencil icon
        Icons.list_alt_rounded,        // List icon
        Icons.done_all_rounded,        // Check status icon
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Obtiene el título dinámico según la navegación
  String _getAppBarTitle() {
    switch (_activeNavIndex) {
      case 0: return 'Página principal';
      case 1: return 'Alertas';
      case 2: return 'Configuración';
      default: return 'Página principal';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtro dinámico de módulos basado en la barra de búsqueda
    final filteredCards = _allCards.where((card) {
      final query = _searchQuery.toLowerCase();
      return card.title.toLowerCase().contains(query) ||
             card.subtitle.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: screenBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptativo: Si el ancho es mayor a 750px renderiza tipo Tablet, de lo contrario móvil.
            final isWideScreen = constraints.maxWidth > 750;

            if (isWideScreen) {
              return Row(
                children: [
                  // 1. Sidebar lateral izquierdo original
                  _buildSidebar(context),
                  
                  // 2. Contenido Principal del Dashboard
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderRow(context),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _buildMainContent(filteredCards, isTablet: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // 3. Vista optimizada y scrollable para Móviles
              return Column(
                children: [
                  _buildMobileAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMobileWelcomeText(),
                          if (_activeNavIndex == 0) ...[
                            const SizedBox(height: 16),
                            _buildSearchField(),
                          ],
                          const SizedBox(height: 20),
                          _buildMainContent(filteredCards, isTablet: false),
                        ],
                      ),
                    ),
                  ),
                  _buildMobileBottomNav(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // --- CONTROLADOR DE VISTAS DINÁMICAS ---
  Widget _buildMainContent(List<DashboardCardData> filteredCards, {required bool isTablet}) {
    switch (_activeNavIndex) {
      case 0:
        return _buildGridCards(filteredCards, isTablet: isTablet);
      case 1:
        return _buildAlertsView();
      case 2:
        return _buildConfigView();
      default:
        return _buildGridCards(filteredCards, isTablet: isTablet);
    }
  }

  // Vista secundaria de Alertas
  Widget _buildAlertsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined, size: 64, color: primaryColor),
          SizedBox(height: 12),
          Text(
            'No hay alertas pendientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Vista secundaria de Configuración
  Widget _buildConfigView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Color(0xFF64748B)),
          SizedBox(height: 12),
          Text(
            'Configuración del Sistema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // --- ELEMENTOS DE DISEÑO TABLET & ESCRITORIO ---

  // Cabecera superior (Título dinámico + Bienvenido + Buscador condicional)
  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bienvenido, Alex · CleanStock v2.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        if (_activeNavIndex == 0)
          SizedBox(
            width: 300,
            child: _buildSearchField(),
          ),
      ],
    );
  }

  // Campo de búsqueda común redondeado (Pill Style)
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar módulo',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  // Sidebar izquierdo idéntico a la imagen de referencia
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sidebarBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAppLogo(),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                _buildSidebarItem(0, Icons.grid_view_rounded, 'Inicio'),
                const SizedBox(height: 16),
                _buildSidebarItem(1, Icons.notifications_none_rounded, 'Alertas', hasAlertDot: true),
                const Divider(indent: 20, endIndent: 20, height: 32, color: Color(0xFFF1F5F9)),
                _buildSidebarItem(2, Icons.settings_outlined, 'Config'),
              ],
            ),
          ),
          _buildUserAvatar(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Logo de CleanStock con degradado de color y tipografía spaced
  Widget _buildAppLogo() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded, // Sparkles icon
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'CLEAN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryColor,
          ),
        ),
        const Text(
          'STOCK',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  // Botón interactivo para el Sidebar con animación de hover/selección
  Widget _buildSidebarItem(int index, IconData icon, String label, {bool hasAlertDot = false}) {
    final bool isSelected = _activeNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNavIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? primaryLightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : const Color(0xFF94A3B8),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? primaryColor : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Punto indicador a la izquierda idéntico a la imagen original en "Alertas"
          if (hasAlertDot)
            Positioned(
              left: -16,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Iniciales del avatar (AM - Alex Miguel) en la parte inferior del menú
  Widget _buildUserAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: primaryLightColor,
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
      ),
      child: const Center(
        child: Text(
          'AM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  // --- RENDEREADO DE BOTONES / MÓDULOS DE TARJETAS ---

  Widget _buildGridCards(List<DashboardCardData> filteredList, {required bool isTablet}) {
    if (filteredList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No se encontraron módulos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: !isTablet, // CORRECCIÓN CLAVE: Previene desbordamiento infinito en móvil
      physics: isTablet ? null : const NeverScrollableScrollPhysics(), // Evita conflicto de scroll interno
      itemCount: filteredList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
        childAspectRatio: isTablet ? 1.35 : 1.7, // Mantiene la forma rectangular perfecta de la UI
      ),
      itemBuilder: (context, index) {
        return _buildModuleCard(context, filteredList[index]);
      },
    );
  }

  // Tarjeta de Módulo individual (Alineación y proporciones exactas)
  Widget _buildModuleCard(BuildContext context, DashboardCardData card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.012),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          splashColor: primaryColor.withOpacity(0.05),
          highlightColor: primaryColor.withOpacity(0.02),
          onTap: () {
            _onCardPressed(context, card);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Círculo central con icono y micro sub-iconos encapsulados debajo
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: card.circleBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              card.mainIcon,
                              color: const Color(0xFF334155),
                              size: 38,
                            ),
                          ),
                          // Encapsulador de sub-iconos flotantes en la parte inferior del círculo
                          Positioned(
                            bottom: -6,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: card.subIcons.map((subIcon) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    subIcon,
                                    size: 10,
                                    color: primaryColor,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Título de la Tarjeta (Módulo)
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtítulo descriptivo
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Insignia de notificación ('4' o '!') en la esquina superior derecha
              if (card.badgeValue != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.badgeValue == '!' ? Colors.blue.shade400 : primaryColor.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      card.badgeValue!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ELEMENTOS ESPECÍFICOS DE LA INTERFAZ MÓVIL ---

  Widget _buildMobileAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'CleanStock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildMobileWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Bienvenido, Alex · v2.0',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: _activeNavIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: const Color(0xFF94A3B8),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _activeNavIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_rounded),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Config',
        ),
      ],
    );
  }

  // --- COMPORTAMIENTO Y NAVEGACIÓN ---

  // Evento disparado al presionar cualquier botón del menú
  void _onCardPressed(BuildContext context, DashboardCardData card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: card.circleBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(card.mainIcon, color: primaryColor, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                card.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                card.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Puedes enlazar este evento para abrir la ruta correspondiente de tu base de datos o sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Abriendo el módulo de: ${card.title}'),
                            backgroundColor: primaryColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Entrar al Módulo',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      }
    }