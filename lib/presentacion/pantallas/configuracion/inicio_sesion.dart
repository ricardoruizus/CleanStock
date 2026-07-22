import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'registro.dart'; 
import 'package:clean_stock/presentacion/pantallas/inicio/inicio_home_screen.dart'; 

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(); 
  final _passwordController = TextEditingController(); 
  bool _isPasswordVisible = false; 
  bool _isLoading = false; 

  @override
  void dispose() {
    _idController.dispose(); 
    _passwordController.dispose(); 
    super.dispose(); 
  }

  // --- FUNCIÓN CON EL PROCESO COMPLETO DENTRO DEL MODAL ---
  void _mostrarModalRecuperarContrasena() {
    final TextEditingController correoRecuperarController = TextEditingController();
    final TextEditingController nuevaContraController = TextEditingController();
    final TextEditingController confirmarContraController = TextEditingController();
    
    final GlobalKey<FormState> modalFormKey = GlobalKey<FormState>();
    
    // Variables de control de estado del modal
    bool modalCargando = false;
    bool correoEncontrado = false;
    bool mostrarContraNueva = false;
    bool mostrarContraConfirmar = false;

    // Datos recuperados del empleado
    String idEmpleadoEncontrado = '';
    String nombreEmpleadoEncontrado = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Icon(
                    correoEncontrado ? Icons.lock_open : Icons.lock_reset, 
                    color: const Color(0xFF62A5DF), 
                    size: 28
                  ),
                  const SizedBox(width: 10),
                  Text(
                    correoEncontrado ? 'Nueva Contraseña' : 'Recuperar acceso',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2E40),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: modalFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PASO 1: INGRESAR CORREO ---
                      if (!correoEncontrado) ...[
                        const Text(
                          'Ingresa tu correo registrado para buscar tu cuenta.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: correoRecuperarController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF1E2E40)),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle: const TextStyle(color: Color(0xFF62A5DF), fontWeight: FontWeight.bold),
                            hintText: 'ejemplo@cleanstock.com',
                            filled: true,
                            fillColor: const Color(0xFFEBF2FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            final bool emailValido = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value);
                            if (!emailValido) {
                              return 'Ingresa un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                      ] 
                      // --- PASO 2: MOSTRAR DATOS Y SOLICITAR NUEVA CONTRASEÑA ---
                      else ...[
                        // Tarjeta de información del empleado encontrado con botón de copiar ID
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF2FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD0E1F4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreEmpleadoEncontrado,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E2E40),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: $idEmpleadoEncontrado',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xFF62A5DF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // BOTÓN DE COPIAR ID
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: Color(0xFF62A5DF), size: 20),
                                tooltip: 'Copiar ID de empleado',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: idEmpleadoEncontrado));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ID $idEmpleadoEncontrado copiado al portapapeles'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: const Color(0xFF2E9E8A),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ingresa y confirma tu nueva contraseña de acceso.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        // Input Nueva Contraseña
                        TextFormField(
                          controller: nuevaContraController,
                          obscureText: !mostrarContraNueva,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF1E2E40)),
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            labelStyle: const TextStyle(color: Color(0xFF62A5DF), fontWeight: FontWeight.bold),
                            hintText: 'Mínimo 6 caracteres',
                            filled: true,
                            fillColor: const Color(0xFFEBF2FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                mostrarContraNueva ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF62A5DF),
                                size: 20,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  mostrarContraNueva = !mostrarContraNueva;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa la nueva contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo debe tener 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Input Confirmar Contraseña
                        TextFormField(
                          controller: confirmarContraController,
                          obscureText: !mostrarContraConfirmar,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF1E2E40)),
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: const TextStyle(color: Color(0xFF62A5DF), fontWeight: FontWeight.bold),
                            hintText: 'Repite la contraseña',
                            filled: true,
                            fillColor: const Color(0xFFEBF2FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                mostrarContraConfirmar ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF62A5DF),
                                size: 20,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  mostrarContraConfirmar = !mostrarContraConfirmar;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirma tu contraseña';
                            }
                            if (value != nuevaContraController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: modalCargando ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF62A5DF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: modalCargando
                      ? null
                      : () async {
                          if (!modalFormKey.currentState!.validate()) return;

                          setModalState(() {
                            modalCargando = true;
                          });

                          try {
                            // --- LÓGICA DE BÚSQUEDA (PASO 1) ---
                            if (!correoEncontrado) {
                              final correo = correoRecuperarController.text.trim();

                              final List<dynamic> response = await Supabase.instance.client
                                  .from('usuarios')
                                  .select('id_empleado, nombre_completo')
                                  .eq('correo', correo);

                              if (response.isEmpty) {
                                throw 'Este correo electrónico no está registrado.';
                              }

                              // Guardamos los datos localmente en el modal y cambiamos de pantalla
                              setModalState(() {
                                idEmpleadoEncontrado = response.first['id_empleado'].toString();
                                nombreEmpleadoEncontrado = response.first['nombre_completo'].toString();
                                correoEncontrado = true;
                              });

                            } 
                            // --- LÓGICA DE ACTUALIZACIÓN (PASO 2) ---
                            else {
                              final nuevaContra = nuevaContraController.text;

                              await Supabase.instance.client
                                  .from('usuarios')
                                  .update({'contrasena_hash': nuevaContra})
                                  .eq('id_empleado', idEmpleadoEncontrado);

                              if (context.mounted) {
                                Navigator.pop(context); // Cierra el modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Contraseña actualizada correctamente.'),
                                    backgroundColor: const Color(0xFF2E9E8A),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } finally {
                            setModalState(() {
                              modalCargando = false;
                            });
                          }
                        },
                  child: modalCargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          correoEncontrado ? 'Guardar' : 'Buscar cuenta',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return; 

    setState(() {
      _isLoading = true; 
    });

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('id_empleado', _idController.text.trim()); 

      if (response.isEmpty) {
        throw 'El ID de empleado no está registrado.'; 
      }

      final usuario = response.first; 

      if (usuario['contrasena_hash'] != _passwordController.text.trim()) {
        throw 'La contraseña es incorrecta.'; 
      }

      final prefs = await SharedPreferences.getInstance(); 
      await prefs.setString('id_empleado', usuario['id_empleado'] ?? ''); 
      await prefs.setString('nombre_completo', usuario['nombre_completo'] ?? ''); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido, ${usuario['nombre_completo']}'), 
            backgroundColor: const Color(0xFF2E9E8A), 
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CleanStockHomeScreen()), 
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()), 
            backgroundColor: Colors.redAccent, 
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
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
      backgroundColor: const Color(0xFFEBF2FA), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), 
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), 
              child: Form(
                key: _formKey, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10), 
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF62A5DF), 
                        borderRadius: BorderRadius.circular(22), 
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF62A5DF).withValues(alpha: 0.3), 
                            blurRadius: 16, 
                            offset: const Offset(0, 8), 
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), 
                    const Text(
                      'CLEANSTOCK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5E8A), 
                        letterSpacing: 3.0, 
                      ),
                    ),
                    const SizedBox(height: 6), 
                    const Text(
                      'Inicio de sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E2E40), 
                        letterSpacing: -0.5, 
                      ),
                    ),
                    const SizedBox(height: 32), 
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(18), 
                        border: Border.all(
                          color: const Color(0xFFD0E1F4), 
                          width: 1.5, 
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2E40).withValues(alpha: 0.03), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4), 
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), 
                            child: TextFormField(
                              controller: _idController, 
                              keyboardType: TextInputType.text, 
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E2E40), 
                                  fontWeight: FontWeight.w500, 
                              ),
                              decoration: const InputDecoration(
                                labelText: 'ID empleado',
                                labelStyle: TextStyle(
                                  color: Color(0xFF62A5DF), 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                                border: InputBorder.none, 
                                floatingLabelBehavior: FloatingLabelBehavior.always, 
                                hintText: 'Ingresa tu ID de empleado', 
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14), 
                                isDense: true, 
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa tu ID de empleado'; 
                                }
                                return null; 
                              },
                            ),
                          ),
                          const Divider(
                            height: 1, 
                            thickness: 1, 
                            color: Color(0xFFEBF2FA), 
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), 
                            child: TextFormField(
                              controller: _passwordController, 
                              obscureText: !_isPasswordVisible, 
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E2E40), 
                                fontWeight: FontWeight.w500, 
                              ),
                              decoration: InputDecoration(
                                labelText: 'Contraseña', 
                                labelStyle: const TextStyle(
                                  color: Color(0xFF62A5DF), 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                                border: InputBorder.none, 
                                floatingLabelBehavior: FloatingLabelBehavior.always, 
                                hintText: '••••••••', 
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14), 
                                isDense: true, 
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.zero, 
                                  constraints: const BoxConstraints(), 
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off, 
                                    color: const Color(0xFF62A5DF), 
                                    size: 20, 
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible; 
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña'; 
                                }
                                return null; 
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24), 
                    SizedBox(
                      width: double.infinity, 
                      height: 54, 
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF62A5DF), 
                          foregroundColor: Colors.white, 
                          elevation: 0, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18), 
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5), 
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20), 
                    TextButton(
                      onPressed: _mostrarModalRecuperarContrasena, 
                      child: const Text(
                        '¿Olvidaste tu contraseña?', 
                        style: TextStyle(
                          color: Color(0xFF62A5DF), 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        const Text(
                          '¿No tienes cuenta? ', 
                          style: TextStyle(color: Colors.grey, fontSize: 14), 
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistroPantalla()), 
                            );
                          },
                          child: const Text(
                            'Regístrate aquí', 
                            style: TextStyle(
                              color: Color(0xFF62A5DF), 
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}