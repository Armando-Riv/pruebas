// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'app_drawer.dart';
import 'font_size_provider.dart';

// Constantes de color IMSS
const Color kPrimaryColor = Color(0xFF00584E);
const Color kSecondaryColor = Color(0xFF1B8247);
const Color kBackgroundColor = Color(0xFFF0F0F0);


class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user';
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>(); // Key para validación
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        _nameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
        _addressController.text = userData.data()!.containsKey('address')
            ? userData['address']
            : '';
        _phoneController.text = userData.data()!.containsKey('phone')
            ? userData['phone']
            : '';
        _email = user.email;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'firstName': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada correctamente')),
      );
    }
  }

  // IMPLEMENTACIÓN: Diálogo de Confirmación (Se utiliza antes de _updateUserData)
  void _confirmUpdateDialog() {
    if (!_formKey.currentState!.validate()) {
      return; // Detiene la acción si la validación falla
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Cambios', style: TextStyle(color: kPrimaryColor)),
        content: const Text('¿Estás seguro de que quieres guardar las modificaciones en tu perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Cerrar diálogo
              _updateUserData(); // Proceder a guardar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información del Perfil',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // COLOR IMSS
      ),
      drawer: AppDrawer(
        fontSizeProvider: fontSizeProvider,
        currentRoute: UserProfileScreen.routeName,
      ),

      backgroundColor: kBackgroundColor, // COLOR FONDO IMSS
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Form( // Añadir Form para la validación
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco para el recuadro
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Correo', fontSizeProvider),
                  _buildNonEditableField(
                    content: _email ?? '',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  const SizedBox(height: 15.0),

                  _buildLabel('Nombre', fontSizeProvider),
                  _buildTextField(
                    controller: _nameController,
                    fontSizeProvider: fontSizeProvider,
                  ),
                  const SizedBox(height: 15.0),

                  _buildLabel('Apellido', fontSizeProvider),
                  _buildTextField(
                    controller: _lastNameController,
                    fontSizeProvider: fontSizeProvider,
                  ),
                  const SizedBox(height: 15.0),

                  _buildLabel('Teléfono', fontSizeProvider),
                  _buildTextField(
                    controller: _phoneController,
                    fontSizeProvider: fontSizeProvider,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un número de teléfono';
                      }
                      if (!RegExp(r'^\+?\d+$').hasMatch(value)) {
                        return 'Ingresa un número de teléfono válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15.0),

                  _buildLabel('Domicilio', fontSizeProvider),
                  _buildTextField(
                    controller: _addressController,
                    fontSizeProvider: fontSizeProvider,
                  ),
                  const SizedBox(height: 20.0),

                  Center(
                    child: ElevatedButton(
                      onPressed: _confirmUpdateDialog, // LLAMAR AL DIÁLOGO DE CONFIRMACIÓN
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor, // COLOR IMSS
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, FontSizeProvider fontSizeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize + 1,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor, // COLOR IMSS
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FontSizeProvider fontSizeProvider,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // IMPLEMENTACIÓN: Diseño ajustado y single-line
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: 1, // Asegura una sola línea
      decoration: InputDecoration(
        filled: true,
        fillColor: kBackgroundColor, // Fondo claro
        isDense: true, // Hace el campo más compacto
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black87),
      validator: validator,
    );
  }

  Widget _buildNonEditableField({
    required String content,
    required FontSizeProvider fontSizeProvider,
  }) {
    // IMPLEMENTACIÓN: Diseño ajustado para no editable
    return Container(
      padding: const EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kBackgroundColor, // Fondo claro para no editable
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Text(
        content,
        maxLines: 1, // Asegura que no se desborde visualmente
        overflow: TextOverflow.ellipsis, // Cortar si excede el ancho
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}