import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fall_history_screen.dart';
import 'font_size_provider.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String userId;

  const PatientDetailsScreen({Key? key, required this.patientData, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          patientData['personalInformation']?['fullName'] ?? 'Sin Nombre',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black26,
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Información Personal', [
              _buildDetail('Nombre Completo', patientData['personalInformation']?['fullName'], fontSizeProvider),
              _buildDetail('Dirección', patientData['personalInformation']?['address'], fontSizeProvider),
              _buildDetail('Fecha de Nacimiento', patientData['personalInformation']?['dateOfBirth'], fontSizeProvider),
              _buildDetail('Género', patientData['personalInformation']?['gender'], fontSizeProvider),
            ], fontSizeProvider),
            _buildSection('Información Médica', [
              _buildDetail('Alergias', patientData['medicalInformation']?['allergies'], fontSizeProvider),
              _buildDetail('Condiciones Médicas', patientData['medicalInformation']?['medicalConditions'], fontSizeProvider),
              _buildDetail(
                'Fecha de Hospitalización',
                patientData['medicalInformation']?['hospitalizationHistory']?['date'],
                fontSizeProvider,
              ),
              _buildDetail(
                'Motivo de Hospitalización',
                patientData['medicalInformation']?['hospitalizationHistory']?['reason'],
                fontSizeProvider,
              ),
            ], fontSizeProvider),
            _buildSection('Contacto Médico', [
              _buildDetail('Nombre', patientData['medicalInformation']?['medicalContact']?['name'], fontSizeProvider),
              _buildDetail('Teléfono', patientData['medicalInformation']?['medicalContact']?['phone'], fontSizeProvider),
            ], fontSizeProvider),
            _buildSection('Información Adicional', [
              _buildDetail('Notas', patientData['additionalInformation']?['notes'], fontSizeProvider),
              _buildDetail('Recomendaciones', patientData['additionalInformation']?['recommendations'], fontSizeProvider),
            ], fontSizeProvider),
            _buildSection('Información del Dispositivo', [
              _buildDetail('ID del Dispositivo', patientData['deviceId'], fontSizeProvider),
              _buildDetail(
                'Fecha de Creación',
                patientData['additionalInformation']?['createdAt']?.toDate(),
                fontSizeProvider,
              ),
            ], fontSizeProvider),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FallHistoryScreen(
                        userId: userId,
                        userName: patientData['personalInformation']?['fullName'] ?? 'Sin Nombre',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black26,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                icon: const Icon(Icons.history, color: Colors.white),
                label: Text(
                  'Ver Historial de Caídas',
                  style: TextStyle(fontSize: fontSizeProvider.fontSize + 2, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget?> children, FontSizeProvider fontSizeProvider) {
    final filteredChildren = children.where((child) => child != null).cast<Widget>().toList();
    if (filteredChildren.isEmpty) return const SizedBox(); // Ocultar sección vacía

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 2,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        ...filteredChildren,
        const Divider(height: 20, thickness: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildDetail(String label, dynamic value, FontSizeProvider fontSizeProvider) {
    if (value == null || value.toString().isEmpty) return const SizedBox(); // Ocultar si está vacío

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSizeProvider.fontSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(fontSize: fontSizeProvider.fontSize),
          ),
        ],
      ),
    );
  }

}
