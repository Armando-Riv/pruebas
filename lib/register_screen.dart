import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'font_size_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
        backgroundColor: Colors.black26,
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
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      context,
                      hintText: 'Ingresa tu nombre',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'El nombre solo debe contener letras';
                        }
                        if (value.length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      context,
                      hintText: 'Ingresa tu apellido',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu apellido';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'El apellido solo debe contener letras';
                        }
                        if (value.length < 2) {
                          return 'El apellido debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      context,
                      hintText: 'Ingresa tu correo',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                          return 'Debe contener al menos una letra mayúscula';
                        }
                        if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                          return 'Debe contener al menos un número';
                        }
                        if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
                          return 'Debe contener al menos un carácter especial (@\$!%*?&)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registrado exitosamente!')),
                          );
                          Timer(const Duration(seconds: 2), () {
                            Navigator.pushReplacementNamed(context, '/login');
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26,
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
    );
  }

  void _showFontSizeDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black26,
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
                    activeColor: Colors.blueAccent,
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
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
          title: const Center(
            child: Text(
              'Ayuda para el registro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                backgroundColor: Colors.blueAccent,
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

  Widget _buildTextField(
      BuildContext context, {
        required String hintText,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize - 1, // Ajusta el tamaño de los mensajes de error
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
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize - 1,
          color: Colors.red,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black54,
          ),
          onPressed: togglePasswordVisibility,
        ),
      ),
      obscureText: !isPasswordVisible,
      validator: validator,
    );
  }
}
