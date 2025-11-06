// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';

// Constantes de color IMSS
const Color kPrimaryColor = Color(0xFF00584E);
const Color kBackgroundColor = Color(0xFFF0F0F0);
const Color kAccentColor = Color(0xFF1B8247); // Verde secundario para acentos

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;

// Función para iniciar sesión
  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(_getSpanishErrorMessage(e.toString()));
    }
  }

// Función para mostrar mensajes de error en español
  String _getSpanishErrorMessage(String errorCode) {
    final errorMessages = {
      'user-not-found': 'Usuario no encontrado. Por favor, verifica tu correo.',
      'wrong-password': 'Contraseña incorrecta. Inténtalo de nuevo.',
      'invalid-email': 'Correo electrónico no válido. Introdúcelo de nuevo.',
    };

    // Iteramos sobre las claves para encontrar el mensaje adecuado.
    for (var key in errorMessages.keys) {
      if (errorCode.contains(key)) {
        return errorMessages[key]!;
      }
    }

    // Mensaje genérico en caso de error desconocido.
    return 'Credenciales incorrectas. favor de ingresar con un usuario válido..';
  }

// Diálogo de error estilizado que limpia los campos cuando se cierra
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColor, // Fondo con color primario
          // Fondo oscuro y opaco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bordes redondeados
          ),
          title: const Center(
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors
                    .redAccent, // Color del título en rojo para denotar error
              ),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              // Tamaño de texto uniforme y fijo para accesibilidad
              color: Colors
                  .white, // Texto en blanco para buen contraste
            ),
            textAlign: TextAlign.center, // Centrado para mejor legibilidad
          ),
          actionsAlignment: MainAxisAlignment.center,
          // Centra el botón de cerrar
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _emailController.clear(); // Limpiar campo de correo
                _passwordController.clear(); // Limpiar campo de contraseña
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 18, // Tamaño del botón de cerrar
                  fontWeight: FontWeight.bold,
                  color: kAccentColor, // Color secundario para hacer contraste
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Inicio de Sesión',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Color primario
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus(); // Cierra el teclado
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () {
              _showFontSizeDialog(context, fontSizeProvider);
            },
          ),
        ],
      ),
      backgroundColor: kBackgroundColor, // Fondo IMSS
      body: Center( // CENTRADO: Envuelve el contenido principal
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RECUADRO DE LOGIN
              Container(
                constraints: const BoxConstraints(maxWidth: 400), // Limitar el ancho para pantallas grandes
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco para el recuadro
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [ // CORRECCIÓN: Usar boxShadow
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO DENTRO DEL RECUADRO
                    Center(
                      child: Image.asset(
                        'assets/images/logo_inicio.png',
                        height: 180, // Altura ajustada
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // INPUT CORREO
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Ingresa tu correo',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeProvider.fontSize,
                        ),
                        filled: true,
                        fillColor: kBackgroundColor, // Fondo de campo
                        prefixIcon:
                        const Icon(Icons.email, color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: kAccentColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // INPUT CONTRASEÑA
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Ingresa tu contraseña',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeProvider.fontSize,
                        ),
                        filled: true,
                        fillColor: kBackgroundColor, // Fondo de campo
                        prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kPrimaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: kAccentColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // BOTÓN INICIAR SESIÓN
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // BOTÓN OLVIDASTE CONTRASEÑA
                    TextButton(
                      onPressed: _resetPasswordDialog,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: kPrimaryColor.withOpacity(0.8),
                          fontSize: fontSizeProvider.fontSize - 2,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context,
      FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kPrimaryColor, // Color primario
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Center(
                child: Text(
                  'Ajustar tamaño de letra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tamaño actual: ${fontSizeProvider.fontSize.toStringAsFixed(
                        1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Slider(
                    min: 16.0,
                    max: 26.0,
                    value: fontSizeProvider.fontSize,
                    activeColor: kAccentColor, // Color secundario
                    inactiveColor: Colors.grey,
                    onChanged: (newSize) {
                      fontSizeProvider.setFontSize(newSize);
                      setState(() {});
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kAccentColor, // Color secundario
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _resetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _emailController = TextEditingController();
        return AlertDialog(
          title: Text('Restablecer Contraseña', textAlign: TextAlign.center, style: TextStyle(color: kPrimaryColor)),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Ingresa tu correo electrónico',
              prefixIcon: const Icon(Icons.email, color: kPrimaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                  Navigator.of(context).pop();
                  _showInfoDialog('Correo de restablecimiento enviado. Revisa tu bandeja de entrada.');
                } catch (e) {
                  Navigator.of(context).pop();
                  _showErrorDialog('Error al enviar el correo de restablecimiento. Verifica el correo ingresado.');
                }
              },
              child: const Text('Enviar', style: TextStyle(color: kAccentColor)),
            ),
          ],
        );
      },
    );
  }
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              'Información',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 18,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}