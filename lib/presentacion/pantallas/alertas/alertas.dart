import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Conexión a Base de Datos

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  // --- PALETA DE COLORES ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);
  final Color textMuted = const Color(0xFF9AB4C8);

  final _supabase = Supabase.instance.client;

  int _filtroActivo = 0; // 0: Activas, 1: Resueltas (Stock >= 15), 2: Todas
  bool _isLoading = true;

  // --- DATOS PROCESADOS DE SUPABASE ---
  List<Map<String, dynamic>> _todasLasAlertas = []; 
  List<Map<String, dynamic>> _alertasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  // --- CARGAR Y PROCESAR ALERTAS DESDE SUPABASE ---
  Future<void> _cargarAlertas() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .order('stock', ascending: true);

      final List<Map<String, dynamic>> productos = List<Map<String, dynamic>>.from(response);
      List<Map<String, dynamic>> alertasProcesadas = [];

      for (var prod in productos) {
        int stock = prod['stock'] ?? 0;
        double precio = (prod['precio'] as num?)?.toDouble() ?? 0.0;
        String nombre = prod['nombre'] ?? 'Sin nombre';

        String estado = 'Normal';
        Color colorTexto = primaryDark;
        Color colorFondo = Colors.white;
        double impacto = 0.0; 

        // REGLAS SOLICITADAS:
        if (stock == 0) {
          estado = 'Agotado';
          colorTexto = const Color(0xFFC53030); // Rojo oscuro
          colorFondo = const Color(0xFFFCE8E6);
          impacto = precio * 10; // Impacto estimado por quiebre de stock total
        } else if (stock <= 5) {
          estado = 'Bajo stock';
          colorTexto = const Color(0xFFA32D2D); // Rojo intermedio
          colorFondo = const Color(0xFFFDF2F2);
          impacto = precio * (10 - stock); // Pérdida de ventas potenciales
        } else if (stock < 15) {
          estado = 'Aviso';
          colorTexto = const Color(0xFFB7791F); // Naranja preventivo
          colorFondo = const Color(0xFFFEF3C7);
          impacto = precio * (15 - stock) * 0.5; // Menor urgencia de impacto
        }

        alertasProcesadas.add({
          'id': prod['id'],
          'producto': nombre,
          'precio': precio,
          'stock': stock,
          'estado': estado,
          'impacto': impacto,
          'colorTexto': colorTexto,
          'colorFondo': colorFondo,
        });
      }

      setState(() {
        _todasLasAlertas = alertasProcesadas;
        _filtrarAlertas();
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alertas: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- APLICACIÓN DE LOS TABS DE FILTRADO ---
  void _filtrarAlertas() {
    List<Map<String, dynamic>> temp = [];

    for (var alerta in _todasLasAlertas) {
      String est = alerta['estado'];
      if (_filtroActivo == 0) {
        // Solo las activas (Agotado, Bajo stock, Aviso)
        if (est == 'Agotado' || est == 'Bajo stock' || est == 'Aviso') {
          temp.add(alerta);
        }
      } else if (_filtroActivo == 1) {
        // Resueltas (Productos con stock seguro >= 15)
        if (est == 'Normal') {
          temp.add(alerta);
        }
      } else {
        // Todas las existencias sin excepción
        temp.add(alerta);
      }
    }

    setState(() {
      _alertasFiltradas = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cuenta cuántos elementos reales de alarma hay activos
    int cantidadActivas = _todasLasAlertas.where((a) => a['estado'] != 'Normal').length;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INTRODUCCIÓN
                  Text('Centro de Alertas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark)),
                  const SizedBox(height: 4),
                  Text('Monitoree el inventario en tiempo real. Gestione existencias críticas.', style: TextStyle(fontSize: 13, color: textMuted)),
                  const SizedBox(height: 16),

                  // TABS DE FILTRO[cite: 3]
                  Row(
                    children: [
                      _buildFiltroTab('Activas', 0, badge: cantidadActivas > 0 ? '$cantidadActivas' : null),
                      const SizedBox(width: 8),
                      _buildFiltroTab('Resueltas', 1),
                      const SizedBox(width: 8),
                      _buildFiltroTab('Todas', 2),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PANELES[cite: 3]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PANEL IZQUIERDO (Lista de Alertas filtradas)
                      Expanded(
                        flex: 3,
                        child: _buildTablaAlertas(),
                      ),
                      const SizedBox(width: 16),
                      
                      // PANEL DERECHO (Acciones e Impacto financiero dinámicos)
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildAccionesSugeridas(cantidadActivas),
                            const SizedBox(height: 16),
                            _buildImpactoFinanciero(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          Text('Alertas', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: primaryLight), 
          onPressed: _cargarAlertas // Botón para recargar la base de datos de manera manual
        ),
      ],
    );
  }

  // --- WIDGETS DE FILTRO ---
  Widget _buildFiltroTab(String titulo, int index, {String? badge}) {
    bool isSelected = _filtroActivo == index;
    return GestureDetector(
      onTap: () {
        setState(() => _filtroActivo = index);
        _filtrarAlertas();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryLight : Colors.white,
          border: Border.all(color: isSelected ? primaryLight : borderLight, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : primaryLight)),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE24B4A), borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- TABLA DE ALERTAS ---
  Widget _buildTablaAlertas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderLight, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Expanded(flex: 3, child: _thText('PRODUCTO')),
                Expanded(flex: 1, child: _thText('PRECIO', align: TextAlign.right)),
                Expanded(flex: 2, child: _thText('STOCK', align: TextAlign.center)),
                Expanded(flex: 2, child: _thText('ESTADO', align: TextAlign.center)),
              ],
            ),
          ),
          
          // Contenido (Validamos si hay alertas)
          if (_alertasFiltradas.isEmpty)
            _buildEstadoVacioAlertas()
          else
            ..._alertasFiltradas.asMap().entries.map((entry) {
              bool isEven = entry.key % 2 != 0;
              return _buildDataRow(entry.value, isEven);
            }),

          // Footer estadístico
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FD),
              border: Border(top: BorderSide(color: borderLight, width: 0.5)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrando ${_alertasFiltradas.length} productos en lista', 
                  style: TextStyle(color: textMuted, fontSize: 12)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacioAlertas() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, size: 50, color: borderLight.withValues(alpha: 0.8)),
            const SizedBox(height: 12),
            Text('No hay registros aquí', style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('No se encontraron productos para esta categoría.', style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _thText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text, textAlign: align, style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0));
  }

  Widget _buildDataRow(Map<String, dynamic> alerta, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8FBFD) : Colors.white,
        border: Border(bottom: BorderSide(color: borderLight.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(alerta['producto'], style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('\$${alerta['precio'].toStringAsFixed(2)}', textAlign: TextAlign.right, style: TextStyle(color: primaryDark, fontSize: 12))),
          // Muestra el stock con los colores de alerta
          Expanded(
            flex: 2, 
            child: Text(
              '${alerta['stock']}', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: alerta['colorTexto'], fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // Badge dinámico según las nuevas reglas de negocio
          Expanded(
            flex: 2, 
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alerta['colorFondo'],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alerta['estado'], 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: alerta['colorTexto'], fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PANEL ACCIONES ---
  Widget _buildAccionesSugeridas(int cantidadActivas) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFDEEEF8), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: primaryLight, size: 16),
                const SizedBox(width: 8),
                Text('Acciones sugeridas', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Text(
              cantidadActivas == 0 
                  ? 'No hay acciones requeridas por el momento.' 
                  : 'Basado en sus alertas críticas actuales, le recomendamos:', 
              style: TextStyle(color: textMuted, fontSize: 11)
            ),
          ),
          if (cantidadActivas > 0) ...[
            _buildActionRow(Icons.shopping_cart, 'Generar orden de compra masiva', isPrimary: true),
            _buildActionRow(Icons.contact_phone, 'Contactar proveedores críticos', isPrimary: false),
          ]
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String text, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? primaryLight : Colors.white,
        border: Border(top: BorderSide(color: borderLight.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isPrimary ? Colors.white : primaryLight),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isPrimary ? Colors.white : primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- PANEL IMPACTO FINANCIERO DINÁMICO ---
  Widget _buildImpactoFinanciero() {
    // Filtramos solo los elementos activos reales para calcular la pérdida estimada
    double impactoTotal = _todasLasAlertas
        .where((a) => a['estado'] != 'Normal')
        .fold(0, (sum, item) => sum + (item['impacto'] ?? 0.0));

    return Container(
      decoration: BoxDecoration(border: Border.all(color: borderLight, width: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryDark, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Text('IMPACTO FINANCIERO', style: TextStyle(color: borderLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${impactoTotal.toStringAsFixed(2)}', style: TextStyle(color: primaryDark, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Venta potencial retenida por falta de stock.', style: TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Icon(Icons.trending_down, color: primaryDark.withValues(alpha: 0.1), size: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}