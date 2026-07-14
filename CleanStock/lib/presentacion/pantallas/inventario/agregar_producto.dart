import 'package:flutter/material.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({Key? key}) : super(key: key);

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  // Controladores para capturar el texto real de los inputs
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  // Estado para la categoría seleccionada (por defecto 'Limpieza')
  String _categoriaSeleccionada = 'Limpieza';

  // Lista de categorías disponibles
  final List<String> _categorias = ['Limpieza', 'Herramientas', 'Químicos', 'Otros'];

  @override
  void dispose() {
    // Limpieza de controladores para evitar fugas de memoria
    _nombreController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Producto',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de subida de imagen interactiva
            _buildImageUploadSection(),
            const SizedBox(height: 32),

            // Formulario de datos del producto
            const Text('Detalles del Producto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            const SizedBox(height: 16),
            
            // Campo Nombre de Producto
            _buildInputField(
              label: 'Nombre del producto',
              controller: _nombreController,
              hint: 'Ej. Detergente Líquido 1L',
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 20),

            // Campo Código de Barras
            _buildInputField(
              label: 'Código de barras / SKU',
              controller: _codigoController,
              hint: 'Escribe o escanea el código',
              icon: Icons.qr_code_scanner_rounded,
              suffixIcon: IconButton(
                icon: const Icon(Icons.center_focus_weak, color: Color(0xFF1E88E5)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulando apertura de Escáner QR...'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Selector de categorías funcional
            const Text('Categoría', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 40),

            // Botón Guardar
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Center(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Simulando apertura de Galería/Cámara...'), behavior: SnackBarBehavior.floating),
          );
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt_outlined, size: 32, color: Color(0xFF1E88E5)),
              SizedBox(height: 8),
              Text('Añadir foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categorias.map((cat) {
        final bool isSelected = _categoriaSeleccionada == cat;
        return GestureDetector(
          onTap: () {
            setState(() {
              _categoriaSeleccionada = cat; // Cambia el estado al presionar
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: () {
          // Validación básica antes de guardar
          if (_nombreController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, ingresa el nombre del producto.'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
            );
            return;
          }

          // Aquí ya tienes las variables listas con los datos reales ingresados:
          String nombre = _nombreController.text;
          String codigo = _codigoController.text;
          String categoria = _categoriaSeleccionada;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto guardado con éxito:\n$nombre ($categoria)'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Cierra la pantalla regresando al Home
          Navigator.pop(context);
        },
        child: const Text('Guardar Producto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}