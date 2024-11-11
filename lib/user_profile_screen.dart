import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'app_drawer.dart';
import 'font_size_provider.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user';
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _auth = FirebaseAuth.instance;
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
        SnackBar(content: Text('Información actualizada correctamente')),
      );
    }
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
        backgroundColor: Colors.black26,
      ),
      drawer: AppDrawer(
        fontSizeProvider: fontSizeProvider,
        currentRoute: UserProfileScreen.routeName,
      ),
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 5),
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
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
          color: Colors.black87,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      style: TextStyle(fontSize: fontSizeProvider.fontSize),
      validator: validator,
    );
  }

  Widget _buildNonEditableField({
    required String content,
    required FontSizeProvider fontSizeProvider,
  }) {
    return Container(
      padding: EdgeInsets.all(15.0),
      width: double.infinity, // Ancho completo para uniformidad
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
