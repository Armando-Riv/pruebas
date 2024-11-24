import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'app_drawer.dart';
import 'font_size_provider.dart';

class PatientRegistrationScreen extends StatefulWidget {
  static const routeName = '/startReg';


  @override
  _PatientRegistrationScreenState createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> {

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
  int _currentStep = 0;

  bool _fillMedicalContact = false;
  bool _fillHospitalizationInfo = false;
  bool _fillAdditionalInfo = false;

  bool _loadingDevices = true; // Variable para cargar los dispositivos
  bool _hasDevices = true; // Verifica si hay dispositivos disponibles

  @override
  void initState() {
    super.initState();
    _fetchAvailableDevices();
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

  void _nextStep() async {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _validatePersonalInformation();
        break;
      case 1:
        isValid = _validateMedicalInformation();
        break;
      case 2:
        isValid = await _validateDeviceAssignment();
        break;
    }

    if (isValid) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        } else {
          _submitPatientData();
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
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
            'Por favor, complete todos los campos obligatorios en Información Médica.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> _validateDeviceAssignment() async {
    if (_selectedDeviceId == null || _securityCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar un dispositivo y completar el código de seguridad.',
          ),
        ),
      );
      return false;
    }

    final isValidCode = await _validateSecurityCode();
    if (!isValidCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El código de seguridad es incorrecto.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> _validateSecurityCode() async {
    final deviceDoc = _availableDevices.firstWhere(
          (device) => device.id == _selectedDeviceId,
      orElse: () => throw Exception('Dispositivo no encontrado'),
    );
    return deviceDoc['securityCode'] == _securityCodeController.text.trim();
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
        ),
        drawer: AppDrawer(
          fontSizeProvider: fontSizeProvider,
          currentRoute: PatientRegistrationScreen.routeName,
        ),
        body: const Center(
          child: Text(
            'No hay dispositivos disponibles para asignar. Por favor, inténtelo más tarde.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Paciente'),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        fontSizeProvider: fontSizeProvider,
        currentRoute: PatientRegistrationScreen.routeName,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          steps: [
            Step(
              title: const Text('Información Personal'),
              content: _buildPersonalInformation(),
              isActive: _currentStep >= 0,
              state: _currentStep == 0 ? StepState.editing : StepState.complete,
            ),
            Step(
              title: const Text('Información Médica'),
              content: _buildMedicalInformation(),
              isActive: _currentStep >= 1,
              state: _currentStep == 1
                  ? StepState.editing
                  : (_currentStep > 1 ? StepState.complete : StepState.indexed),
            ),
            Step(
              title: const Text('Asignar Dispositivo'),
              content: _buildDeviceAssignment(),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.editing : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Column(
      children: [
        _buildTextField('Nombre Completo', _controllers['fullName']!),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickDate(_controllers['dateOfBirth']!),
          child: AbsorbPointer(
            child: _buildTextField('Fecha de Nacimiento', _controllers['dateOfBirth']!),
          ),
        ),
        const SizedBox(height: 10),
        _buildGenderDropdown(),
        const SizedBox(height: 10),
        _buildTextField('Dirección', _controllers['address']!),
      ],
    );
  }

  Widget _buildMedicalInformation() {
    return Column(
      children: [
        _buildTextField('Condiciones Médicas', _controllers['medicalConditions']!),
        const SizedBox(height: 10),
        _buildTextField('Alergias', _controllers['allergies']!),
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text('Información de Hospitalización'),
          value: _fillHospitalizationInfo,
          onChanged: (value) {
            setState(() {
              _fillHospitalizationInfo = value ?? false;
            });
          },
        ),
        if (_fillHospitalizationInfo) ...[
          _buildTextField('Fecha de Hospitalización', _controllers['hospitalizationDate']!),
          const SizedBox(height: 10),
          _buildTextField('Razón de Hospitalización', _controllers['hospitalizationReason']!),
        ],
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text('Contacto Médico'),
          value: _fillMedicalContact,
          onChanged: (value) {
            setState(() {
              _fillMedicalContact = value ?? false;
            });
          },
        ),
        if (_fillMedicalContact) ...[
          _buildTextField('Nombre del Contacto Médico', _controllers['medicalContactName']!),
          const SizedBox(height: 10),
          _buildTextField('Teléfono del Contacto Médico', _controllers['medicalContactPhone']!),
        ],
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text('Información Adicional'),
          value: _fillAdditionalInfo,
          onChanged: (value) {
            setState(() {
              _fillAdditionalInfo = value ?? false;
            });
          },
        ),
        if (_fillAdditionalInfo) ...[
          _buildTextField('Notas', _controllers['notes']!),
          const SizedBox(height: 10),
          _buildTextField('Recomendaciones', _controllers['recommendations']!),
        ],
      ],
    );
  }

  Widget _buildDeviceAssignment() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedDeviceId,
          items: _availableDevices.map((device) {
            return DropdownMenuItem(
              value: device.id,
              child: Text(device.id),
            );
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Seleccionar Dispositivo',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _selectedDeviceId = value;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildTextField('Código de Seguridad', _securityCodeController),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio.';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Género',
        border: OutlineInputBorder(),
      ),
      items: ['Masculino', 'Femenino', 'Otro']
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }
}
