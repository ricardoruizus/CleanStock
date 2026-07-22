import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Esencial para restringir la entrada de teclado
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Para guardar en la base de datos

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  // --- PALETA DE COLORES (CleanStock) ---
  final Color bgLight = const Color(0xFFE8EFF7);
  final Color primaryDark = const Color(0xFF294E69);
  final Color primaryLight = const Color(0xFF65ABDE);
  final Color borderLight = const Color(0xFFADCBE3);

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _skuController = TextEditingController(); // NUEVO
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();

  bool _isLoading = false; // Controla el spinner del botón

  @override
  void dispose() {
    _nombreController.dispose();
    _skuController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA GUARDAR EN SUPABASE ---
  Future<void> _guardarProducto() async {
    // 1. Validar que los campos de texto cumplan las reglas
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String nombre = _nombreController.text.trim();
      final String sku = _skuController.text.trim(); // NUEVO
      final double precio = double.parse(_precioController.text.trim());
      final int stock = int.parse(_stockController.text.trim());

      // 2. Insertar en tu tabla de Supabase (asegúrate de que los nombres de columna coincidan)
      await Supabase.instance.client.from('productos').insert({
        'nombre': nombre,
        'sku': sku, // NUEVO
        'precio': precio,
        'stock': stock,
        // Si tu tabla requiere campos extra como 'creado_en', Supabase suele generarlos por defecto.
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Producto guardado exitosamente!'),
            backgroundColor: Color(0xFF2E9E8A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior (Inventario)
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar en la base de datos: $error'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        title: Text(
          'Agregar Producto', 
          style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo: Nombre
              _buildTextField(
                label: 'Nombre del producto',
                controller: _nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo: SKU
              _buildTextField(
                label: 'SKU',
                controller: _skuController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el SKU';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Precio (Solo números y un punto decimal)
              _buildTextField(
                label: 'Precio',
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Expresión regular que solo deja pasar dígitos y opcionalmente un único punto decimal
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número decimal válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Stock Inicial (Solo números enteros)
              _buildTextField(
                label: 'Stock inicial',
                controller: _stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  // Filtro nativo de Flutter para no permitir nada que no sea un dígito
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el stock inicial';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingresa un número entero válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de Guardar con estado de carga
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarProducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Guardar Producto',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER PARA CONSTRUIR CAMPOS DE TEXTO ESTILIZADOS ---
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters, // Aplica los limitadores físicos de teclado
      validator: validator, // Aplica la validación lógica antes de enviar
      style: TextStyle(color: primaryDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryDark.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}