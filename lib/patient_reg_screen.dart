// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/patient_reg_screen.dart

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


class PatientRegistrationScreen extends StatefulWidget {
  static const routeName = '/startReg';


  @override
  _PatientRegistrationScreenState createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> with SingleTickerProviderStateMixin { // Se añade Mixin

  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'fullName': TextEditingController(),
    'dateOfBirth': TextEditingController(),
    'address': TextEditingController(),
    'medicalConditions': TextEditingController(),
    'allergies': TextEditingController(),
    'hospitalizationDate': TextEditingController(),
    'hospitalizationReason': TextEditingController(),
    'medicalContactName': TextEditingController(),
    'medicalContactPhone': TextEditingController(),
    'notes': TextEditingController(),
    'recommendations': TextEditingController(),
  };

  String? _selectedDeviceId;
  final TextEditingController _securityCodeController = TextEditingController();
  List<QueryDocumentSnapshot> _availableDevices = [];
  String? _selectedGender;

  bool _fillMedicalContact = false;
  bool _fillHospitalizationInfo = false;
  bool _fillAdditionalInfo = false;

  bool _loadingDevices = true;
  bool _hasDevices = true;

  // NUEVOS CAMPOS PARA EL TABBAR
  late TabController _tabController;
  final List<String> _tabTitles = ['Personal', 'Médica', 'Dispositivo'];


  @override
  void initState() {
    super.initState();
    // Inicialización del TabController
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _fetchAvailableDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.forEach((key, controller) => controller.dispose());
    _securityCodeController.dispose();
    super.dispose();
  }


  Future<void> _fetchAvailableDevices() async {
    try {
      final devicesSnapshot = await FirebaseFirestore.instance
          .collection('devices')
          .where('status', isEqualTo: 'available')
          .get();

      setState(() {
        _availableDevices = devicesSnapshot.docs;
        _hasDevices = _availableDevices.isNotEmpty;
        _loadingDevices = false;
      });
    } catch (e) {
      setState(() {
        _loadingDevices = false;
        _hasDevices = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar dispositivos: $e')),
      );
    }
  }

  Future<void> _submitPatientData() async {
    if (!_hasDevices) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay dispositivos disponibles para asignar.')),
      );
      return;
    }

    // 1. Validar la última pestaña (Asignación de Dispositivo)
    if (_selectedDeviceId == null || _securityCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un dispositivo y completar el código de seguridad.')),
      );
      return;
    }

    final isValidCode = await _validateSecurityCode();
    if (!isValidCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código de seguridad es incorrecto.')),
      );
      return;
    }

    // Si todas las validaciones pasan, se procede con el registro
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final patientData = {
        'requestedBy': user.email,
        'personalInformation': {
          'fullName': _controllers['fullName']!.text.trim(),
          'dateOfBirth': _controllers['dateOfBirth']!.text.trim(),
          'gender': _selectedGender ?? "",
          'address': _controllers['address']!.text.trim(),
        },
        'medicalInformation': {
          'medicalConditions': _controllers['medicalConditions']!.text.trim().isNotEmpty
              ? _controllers['medicalConditions']!.text.trim()
              : "",
          'allergies': _controllers['allergies']!.text.trim().isNotEmpty
              ? _controllers['allergies']!.text.trim()
              : "",
          'hospitalizationHistory': _fillHospitalizationInfo
              ? {
            'date': _controllers['hospitalizationDate']!.text.trim().isNotEmpty
                ? _controllers['hospitalizationDate']!.text.trim()
                : "",
            'reason': _controllers['hospitalizationReason']!.text.trim().isNotEmpty
                ? _controllers['hospitalizationReason']!.text.trim()
                : "",
          }
              : {
            'date': "",
            'reason': "",
          },
          'medicalContact': _fillMedicalContact
              ? {
            'name': _controllers['medicalContactName']!.text.trim().isNotEmpty
                ? _controllers['medicalContactName']!.text.trim()
                : "",
            'phone': _controllers['medicalContactPhone']!.text.trim().isNotEmpty
                ? _controllers['medicalContactPhone']!.text.trim()
                : "",
          }
              : {
            'name': "",
            'phone': "",
          },
        },
        'additionalInformation': _fillAdditionalInfo
            ? {
          'notes': _controllers['notes']!.text.trim().isNotEmpty
              ? _controllers['notes']!.text.trim()
              : "",
          'recommendations': _controllers['recommendations']!.text.trim().isNotEmpty
              ? _controllers['recommendations']!.text.trim()
              : "",
        }
            : {
          'notes': "",
          'recommendations': "",
        },
        'deviceId': _selectedDeviceId ?? "",
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Registrar paciente en la colección
      final patientDoc = await FirebaseFirestore.instance
          .collection('monitored_users')
          .add(patientData);

      // Actualizar el estado del dispositivo en Firestore
      if (_selectedDeviceId != null) {
        await FirebaseFirestore.instance.collection('devices').doc(_selectedDeviceId).update({
          'assignedTo': patientDoc.id,
          'status': 'assigned',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente registrado exitosamente.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _goToNextTab() async {
    if (_tabController.index < _tabTitles.length - 1) {
      // 1. Validar la pestaña actual antes de avanzar
      bool isValid = false;

      switch (_tabController.index) {
        case 0:
          isValid = _validatePersonalInformation();
          break;
        case 1:
          isValid = _validateMedicalInformation();
          break;
      }

      if (isValid) {
        _tabController.animateTo(_tabController.index + 1);
      }
    } else {
      // Estamos en la última pestaña (Dispositivo), procedemos al submit
      _submitPatientData();
    }
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  bool _validatePersonalInformation() {
    if (_controllers['fullName']!.text.isEmpty ||
        _controllers['dateOfBirth']!.text.isEmpty ||
        _selectedGender == null ||
        _controllers['address']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, complete todos los campos obligatorios en Información Personal.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateMedicalInformation() {
    if (_controllers['medicalConditions']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, complete al menos las "Condiciones Médicas" en Información Médica.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> _validateSecurityCode() async {
    if (_selectedDeviceId == null || _securityCodeController.text.isEmpty) {
      return false;
    }

    try {
      final deviceDoc = _availableDevices.firstWhere(
            (device) => device.id == _selectedDeviceId,
      );
      return deviceDoc['securityCode'] == _securityCodeController.text.trim();
    } catch (e) {
      // Manejar el caso si el dispositivo seleccionado ya no está en _availableDevices (poco probable pero seguro)
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    if (_loadingDevices) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasDevices) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Paciente'),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
        ),
        drawer: AppDrawer(
          fontSizeProvider: fontSizeProvider,
          currentRoute: PatientRegistrationScreen.routeName,
        ),
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor, size: 80, color: kPrimaryColor),
                const SizedBox(height: 20),
                Text(
                  'No hay dispositivos disponibles para asignar. Por favor, inténtelo más tarde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 2,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // VISTA PRINCIPAL CON TABBAR
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Paciente',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Color Primario
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: kSecondaryColor, // Color Secundario
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          // Deshabilitar el deslizamiento para evitar saltos sin validar
          onTap: (index) {
            if (index < _tabController.index) {
              _tabController.animateTo(index); // Permitir regresar
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(context, fontSizeProvider), // Añadir ayuda
          ),
        ],
      ),
      drawer: AppDrawer(
        fontSizeProvider: fontSizeProvider,
        currentRoute: PatientRegistrationScreen.routeName,
      ),
      backgroundColor: kBackgroundColor, // Color de Fondo
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe
                children: [
                  _buildTabContent(_buildPersonalInformation()),
                  _buildTabContent(_buildMedicalInformation()),
                  _buildTabContent(_buildDeviceAssignment()),
                ],
              ),
            ),
            _buildNavigationButtons(fontSizeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: content,
    );
  }

  Widget _buildNavigationButtons(FontSizeProvider fontSizeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Anterior
          if (_tabController.index > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _goToPreviousTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                child: Text(
                  'Anterior',
                  style: TextStyle(fontSize: fontSizeProvider.fontSize),
                ),
              ),
            ),
          const SizedBox(width: 10),
          // Botón Siguiente / Registrar
          Expanded(
            child: ElevatedButton(
              onPressed: _goToNextTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabController.index == _tabTitles.length - 1
                    ? kSecondaryColor // Color verde para finalizar
                    : kPrimaryColor, // Color primario para avanzar
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text(
                _tabController.index == _tabTitles.length - 1 ? 'Registrar' : 'Siguiente',
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPersonalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Image.asset('assets/images/logo_inicio.png', height: 100, color: kPrimaryColor)),
        const SizedBox(height: 20),
        Text('Información Personal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const Divider(color: kPrimaryColor),
        _buildTextField('Nombre Completo', _controllers['fullName']!),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => _pickDate(_controllers['dateOfBirth']!),
          child: AbsorbPointer(
            child: _buildTextField('Fecha de Nacimiento (YYYY-MM-DD)', _controllers['dateOfBirth']!),
          ),
        ),
        const SizedBox(height: 15),
        _buildGenderDropdown(),
        const SizedBox(height: 15),
        _buildTextField('Dirección', _controllers['address']!),
      ],
    );
  }

  Widget _buildMedicalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información Médica', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const Divider(color: kPrimaryColor),
        _buildTextField('Condiciones Médicas (Obligatorio)', _controllers['medicalConditions']!, maxLines: 3),
        const SizedBox(height: 15),
        _buildTextField('Alergias', _controllers['allergies']!, maxLines: 3),
        const SizedBox(height: 15),

        _buildSectionToggle('Información de Hospitalización (Opcional)', _fillHospitalizationInfo, (value) {
          setState(() { _fillHospitalizationInfo = value ?? false; });
        }),
        if (_fillHospitalizationInfo) ...[
          const SizedBox(height: 10),
          _buildTextField('Fecha de Hospitalización (YYYY-MM-DD)', _controllers['hospitalizationDate']!),
          const SizedBox(height: 15),
          _buildTextField('Razón de Hospitalización', _controllers['hospitalizationReason']!, maxLines: 3),
          const SizedBox(height: 15),
        ],

        _buildSectionToggle('Contacto Médico (Opcional)', _fillMedicalContact, (value) {
          setState(() { _fillMedicalContact = value ?? false; });
        }),
        if (_fillMedicalContact) ...[
          const SizedBox(height: 10),
          _buildTextField('Nombre del Contacto Médico', _controllers['medicalContactName']!),
          const SizedBox(height: 15),
          _buildTextField('Teléfono del Contacto Médico', _controllers['medicalContactPhone']!),
          const SizedBox(height: 15),
        ],

        _buildSectionToggle('Información Adicional (Opcional)', _fillAdditionalInfo, (value) {
          setState(() { _fillAdditionalInfo = value ?? false; });
        }),
        if (_fillAdditionalInfo) ...[
          const SizedBox(height: 10),
          _buildTextField('Notas', _controllers['notes']!, maxLines: 3),
          const SizedBox(height: 15),
          _buildTextField('Recomendaciones', _controllers['recommendations']!, maxLines: 3),
        ],
      ],
    );
  }

  Widget _buildSectionToggle(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor)),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDeviceAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asignar Dispositivo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const Divider(color: kPrimaryColor),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedDeviceId,
          items: _availableDevices.map((device) {
            return DropdownMenuItem(
              value: device.id,
              child: Text('Dispositivo ID: ${device.id}', style: TextStyle(color: Colors.black87)),
            );
          }).toList(),
          decoration: _inputDecoration('Seleccionar Dispositivo', Icons.device_hub),
          onChanged: (value) {
            setState(() {
              _selectedDeviceId = value;
            });
          },
          validator: (value) => value == null ? 'Por favor, seleccione un dispositivo.' : null,
        ),
        const SizedBox(height: 15),
        _buildTextField('Código de Seguridad', _securityCodeController),
        const SizedBox(height: 20),
        // Sección de Ayuda Visual
        _buildHelpSection(context),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                'Nota Importante',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'El código de seguridad se encuentra en la parte posterior del dispositivo de monitoreo.',
            style: TextStyle(color: Colors.black87),
          ),
          const Text(
            'Asegúrese de ingresarlo correctamente para vincular el paciente.',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }


  InputDecoration _inputDecoration(String label, IconData icon) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: kPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: fontSizeProvider.fontSize,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: kPrimaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorStyle: TextStyle(
        fontSize: fontSizeProvider.fontSize - 1,
        color: Colors.red,
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, _getIconForLabel(label)),
      validator: (value) {
        if (value == null || value.isEmpty && (label.contains('Nombre Completo') || label.contains('Dirección') || label.contains('Condiciones Médicas'))) {
          return 'Este campo es obligatorio.';
        }
        return null;
      },
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.contains('Nombre')) return Icons.person;
    if (label.contains('Fecha')) return Icons.calendar_today;
    if (label.contains('Dirección')) return Icons.location_on;
    if (label.contains('Condiciones')) return Icons.medical_services;
    if (label.contains('Alergias')) return Icons.no_food;
    if (label.contains('Razón')) return Icons.local_hospital;
    if (label.contains('Teléfono')) return Icons.phone;
    if (label.contains('Notas')) return Icons.notes;
    if (label.contains('Recomendaciones')) return Icons.recommend;
    if (label.contains('Código')) return Icons.security;
    return Icons.short_text;
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: _inputDecoration('Género', Icons.wc),
      items: ['Masculino', 'Femenino', 'Otro']
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender, style: TextStyle(color: Colors.black87))))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) => value == null ? 'Por favor, seleccione el género.' : null,
    );
  }

  void _showHelpDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
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
              'Ayuda de Registro de Paciente',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpText('Información Personal: Todos los campos son obligatorios. La fecha se selecciona en el calendario.'),
              _buildHelpText('Información Médica: Las "Condiciones Médicas" son obligatorias. Los demás bloques son opcionales y se expanden con el check.'),
              _buildHelpText('Asignar Dispositivo: Seleccione el ID del dispositivo y el código de seguridad que está en el monitor. El registro solo procede si el código es correcto.'),
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

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: kPrimaryColor, // Color primario para el picker
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      // Formato yyyy-MM-dd
      setState(() {
        controller.text = "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }
}