// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'font_size_provider.dart';

// Constantes de color IMSS
const Color kPrimaryColor = Color(0xFF00584E);
const Color kBackgroundColor = Color(0xFFF0F0F0);
const Color kAccentColor = Color(0xFF1B8247);


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _userType; // Campo para el tipo de usuario

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _registerUser() async {
    // Validar el formulario y el tipo de usuario
    if (_formKey.currentState!.validate() && _userType != null) {
      try {
        // Crea el usuario en Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Obtén el UID del usuario creado
        String uid = userCredential.user!.uid;

        // Almacena la información del usuario en Firestore, incluyendo el rol
        await _firestore.collection('users').doc(uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': _userType, // GUARDAR ROL
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Muestra un mensaje de éxito y redirige a la pantalla de inicio
        _showSuccessDialog(); // Muestra la alerta de éxito
      } catch (e) {
        _showErrorDialog('Error al registrar: ${e.toString()}');
      }
    } else if (_userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona si eres Cuidador o Paciente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize,
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
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () {
              _showFontSizeDialog(context, fontSizeProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
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
              // RECUADRO DE REGISTRO
              Container(
                constraints: const BoxConstraints(maxWidth: 400), // Limitar el ancho
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [ // Campo correcto
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LOGO DENTRO DEL RECUADRO
                      Center(
                        child: Image.asset(
                          'assets/images/logo_inicio.png',
                          height: 250, // Altura ajustada
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 4,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),


                      // CAMPO ROL
                      _buildUserTypeDropdown(context),
                      const SizedBox(height: 15),

                      // INPUT NOMBRE
                      _buildTextField(
                        context,
                        controller: _firstNameController,
                        hintText: 'Ingresa tu nombre',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // INPUT APELLIDO
                      _buildTextField(
                        context,
                        controller: _lastNameController,
                        hintText: 'Ingresa tu apellido',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // INPUT CORREO
                      _buildTextField(
                        context,
                        controller: _emailController,
                        hintText: 'Ingresa tu correo',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // INPUT CONTRASEÑA
                      _buildPasswordField(
                        context,
                        controller: _passwordController,
                        hintText: 'Crea una contraseña',
                        icon: Icons.lock,
                        isPasswordVisible: _isPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // INPUT CONFIRMAR CONTRASEÑA
                      _buildPasswordField(
                        context,
                        controller: _confirmPasswordController,
                        hintText: 'Repite tu contraseña',
                        icon: Icons.lock_outline,
                        confirmPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // BOTÓN REGISTRARSE
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor, // Color primario
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          'Registrarse',
                          style: TextStyle(fontSize: fontSizeProvider.fontSize + 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Center(
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text('Cerrar', style: TextStyle(color: kAccentColor)),
              onPressed: () {
                _passwordController.clear();
                _confirmPasswordController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTypeDropdown(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return DropdownButtonFormField<String>(
      // Alinea el texto seleccionado al centro (por defecto) y usa la fuente grande
      alignment: Alignment.center,
      style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.black87,
          fontWeight: FontWeight.bold // Para que se vea similar a la fuente grande del hint
      ),
      iconSize: fontSizeProvider.fontSize + 8, // Aumenta el tamaño del ícono de la flecha
      decoration: InputDecoration(
        filled: true,
        fillColor: kBackgroundColor,
        // ÍCONO REINCORPORADO
        prefixIcon: const Icon(Icons.group, color: kPrimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: kAccentColor, width: 2),
        ),
        // AJUSTE CLAVE: Reducir el padding vertical a un valor fijo para mantener la altura constante.
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        // Usar hintStyle con el mismo color que los otros campos
        hintStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
      isExpanded: true,
      value: _userType,
      hint: Text(
        'Selecciona si eres Cuidador o Paciente', // Hint más corto ya con la etiqueta de rol arriba
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: fontSizeProvider.fontSize,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      items: ['Cuidador', 'Paciente']
          .map((label) => DropdownMenuItem(
        value: label,
        child: Text(
          label,
          style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _userType = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Debes seleccionar un rol.';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String hintText,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: kBackgroundColor,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: kAccentColor, width: 2),
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize - 1,
          color: Colors.red,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField(
      BuildContext context, {
        required TextEditingController controller,
        required String hintText,
        required IconData icon,
        bool confirmPassword = false,
        required bool isPasswordVisible,
        required VoidCallback togglePasswordVisibility,
        String? Function(String?)? validator,
      }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: kBackgroundColor,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: kAccentColor, width: 2),
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize - 1,
          color: Colors.red,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: kPrimaryColor,
          ),
          onPressed: togglePasswordVisibility,
        ),
      ),
      obscureText: !isPasswordVisible,
      validator: validator,
    );
  }
  void _showFontSizeDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kPrimaryColor,
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
                    'Tamaño actual: ${fontSizeProvider.fontSize.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Slider(
                    min: 16.0,
                    max: 26.0,
                    value: fontSizeProvider.fontSize,
                    activeColor: kAccentColor,
                    inactiveColor: Colors.grey,
                    onChanged: (newSize) {
                      fontSizeProvider.setFontSize(newSize);
                      setState(() {}); // Actualiza visualmente el diálogo
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
                      color: kAccentColor,
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              'Ayuda para el registro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpText('Rol: Debes seleccionar si eres "Cuidador" o "Paciente". Solo los Cuidadores pueden registrar pacientes.'),
              _buildHelpText('Nombre y Apellido: Solo letras, mínimo 2 caracteres.'),
              _buildHelpText('Correo Electrónico: Debe tener un formato válido.'),
              _buildHelpText(
                  'Contraseña: Mínimo 6 caracteres, incluyendo una letra mayúscula, un número y un carácter especial.'),
              _buildHelpText('Confirmar Contraseña: Asegúrate de que coincida con la contraseña ingresada anteriormente.'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Center(
            child: Text(
              'Registro Exitoso',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: const Text(
            'Tu cuenta ha sido creada exitosamente.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                // Redirige al Home (que manejará la vista de Cuidador/Paciente)
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


}