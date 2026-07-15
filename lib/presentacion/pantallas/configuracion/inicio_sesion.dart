import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Persistencia local
import 'package:url_launcher/url_launcher.dart'; // <-- Para abrir el navegador web
import 'registro.dart'; //
import 'package:clean_stock/presentacion/pantallas/inicio/inicio_home_screen.dart'; //

// =========================================================================
// CONFIGURACIÓN: Reemplaza este enlace con tu URL de GitHub Pages una vez creada.
// Mantén el final sin la barra "/" para evitar errores al concatenar el correo.
// =========================================================================
const String url_recuperacion_web = 'https://tu-usuario.github.io/cleanstock';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(); // Regresamos a ID empleado
  final _passwordController = TextEditingController(); //
  bool _isPasswordVisible = false; //
  bool _isLoading = false; //

  @override
  void dispose() {
    _idController.dispose(); //
    _passwordController.dispose(); //
    super.dispose(); //
  }

  // --- FUNCIÓN PARA EL MODAL DE RECUPERAR CONTRASEÑA ---
  void _mostrarModalRecuperarContrasena() {
    final TextEditingController correoRecuperarController = TextEditingController();
    final GlobalKey<FormState> modalFormKey = GlobalKey<FormState>();
    bool modalCargando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFF62A5DF), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Recuperar acceso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2E40),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: modalFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingresa tu correo registrado para redirigirte a la web de cambio de contraseña.',
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
                  ],
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
                            final correo = correoRecuperarController.text.trim();

                            // 1. Validamos en Supabase si el correo realmente existe
                            final List<dynamic> response = await Supabase.instance.client
                                .from('usuarios')
                                .select('id_empleado')
                                .eq('correo', correo);

                            if (response.isEmpty) {
                              throw 'Este correo electrónico no está registrado.';
                            }

                            // 2. Si existe, abrimos la web en el navegador enviando el correo como parámetro
                            final String urlCompleta = '$url_recuperacion_web?correo=$correo';
                            final Uri uri = Uri.parse(urlCompleta);

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                              
                              if (context.mounted) {
                                Navigator.pop(context); // Cierra el modal de recuperación
                              }
                            } else {
                              throw 'No se pudo abrir el sitio web de recuperación.';
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
                      : const Text(
                          'Ir a restablecer',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    if (!_formKey.currentState!.validate()) return; //

    setState(() {
      _isLoading = true; //
    });

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('id_empleado', _idController.text.trim()); //

      if (response.isEmpty) {
        throw 'El ID de empleado no está registrado.'; //
      }

      final usuario = response.first; //

      if (usuario['contrasena_hash'] != _passwordController.text.trim()) {
        throw 'La contraseña es incorrecta.'; //
      }

      final prefs = await SharedPreferences.getInstance(); //
      await prefs.setString('id_empleado', usuario['id_empleado'] ?? ''); //
      await prefs.setString('nombre_completo', usuario['nombre_completo'] ?? ''); //

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido, ${usuario['nombre_completo']}'), //
            backgroundColor: const Color(0xFF2E9E8A), //
            behavior: SnackBarBehavior.floating, //
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), //
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CleanStockHomeScreen()), //
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()), //
            backgroundColor: Colors.redAccent, //
            behavior: SnackBarBehavior.floating, //
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), //
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; //
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF2FA), //
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), //
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), //
              child: Form(
                key: _formKey, //
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10), //
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF62A5DF), //
                        borderRadius: BorderRadius.circular(22), //
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF62A5DF).withOpacity(0.3), //
                            blurRadius: 16, //
                            offset: const Offset(0, 8), //
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), //
                    const Text(
                      'CLEANSTOCK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5E8A), //
                        letterSpacing: 3.0, //
                      ),
                    ),
                    const SizedBox(height: 6), //
                    const Text(
                      'Inicio de sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E2E40), //
                        letterSpacing: -0.5, //
                      ),
                    ),
                    const SizedBox(height: 32), //
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, //
                        borderRadius: BorderRadius.circular(18), //
                        border: Border.all(
                          color: const Color(0xFFD0E1F4), //
                          width: 1.5, //
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2E40).withOpacity(0.03), //
                            blurRadius: 10, //
                            offset: const Offset(0, 4), //
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), //
                            child: TextFormField(
                              controller: _idController, //
                              keyboardType: TextInputType.text, //
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E2E40), //
                                  fontWeight: FontWeight.w500, //
                              ),
                              decoration: const InputDecoration(
                                labelText: 'ID empleado',
                                labelStyle: TextStyle(
                                  color: Color(0xFF62A5DF), //
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                                border: InputBorder.none, //
                                floatingLabelBehavior: FloatingLabelBehavior.always, //
                                hintText: 'Ingresa tu ID de empleado', //
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14), //
                                isDense: true, //
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa tu ID de empleado'; //
                                }
                                return null; //
                              },
                            ),
                          ),
                          const Divider(
                            height: 1, //
                            thickness: 1, //
                            color: Color(0xFFEBF2FA), //
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), //
                            child: TextFormField(
                              controller: _passwordController, //
                              obscureText: !_isPasswordVisible, //
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E2E40), //
                                fontWeight: FontWeight.w500, //
                              ),
                              decoration: InputDecoration(
                                labelText: 'Contraseña', //
                                labelStyle: const TextStyle(
                                  color: Color(0xFF62A5DF), //
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                                border: InputBorder.none, //
                                floatingLabelBehavior: FloatingLabelBehavior.always, //
                                hintText: '••••••••', //
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14), //
                                isDense: true, //
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.zero, //
                                  constraints: const BoxConstraints(), //
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off, //
                                    color: const Color(0xFF62A5DF), //
                                    size: 20, //
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible; //
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña'; //
                                }
                                return null; //
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24), //
                    SizedBox(
                      width: double.infinity, //
                      height: 54, //
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm, //
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF62A5DF), //
                          foregroundColor: Colors.white, //
                          elevation: 0, //
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18), //
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5), //
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
                    const SizedBox(height: 20), //
                    TextButton(
                      onPressed: _mostrarModalRecuperarContrasena, // <-- Llama al modal
                      child: const Text(
                        '¿Olvidaste tu contraseña?', //
                        style: TextStyle(
                          color: Color(0xFF62A5DF), //
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), //
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, //
                      children: [
                        const Text(
                          '¿No tienes cuenta? ', //
                          style: TextStyle(color: Colors.grey, fontSize: 14), //
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistroPantalla()), //
                            );
                          },
                          child: const Text(
                            'Regístrate aquí', //
                            style: TextStyle(
                              color: Color(0xFF62A5DF), //
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