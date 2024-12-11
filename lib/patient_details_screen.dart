import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'fall_history_screen.dart';
import 'font_size_provider.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String userId;

  const PatientDetailsScreen({
    Key? key,
    required this.patientData,
    required this.userId,
  }) : super(key: key);

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
        actions: [
          IconButton(
            onPressed: () => _generateReport(context),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generar Reporte PDF',
          ),
        ],
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

  Future<void> _generateReport(BuildContext context) async {
    final pdf = pw.Document();

    // Cargar el logo
    final logoBytes = await rootBundle.load('assets/images/logo_inicio.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Historial de caídas como tabla
    final fallHistoryTable = await _generateFallHistoryTable();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [

              pw.Text(
                'Reporte del Paciente',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
              ),
              pw.Image(logoImage, width: 120, height: 140),
            ],
          ),
          pw.SizedBox(height: 20),
          _generatePdfSection('Información Personal', patientData['personalInformation']),
          pw.Divider(color: PdfColors.grey, thickness: 0.5),
          pw.SizedBox(height: 10),
          _generatePdfSection('Información Médica', patientData['medicalInformation']),
          pw.Divider(color: PdfColors.grey, thickness: 0.5),
          pw.SizedBox(height: 10),
          _generatePdfSection('Información Adicional', patientData['additionalInformation']),
          pw.Divider(color: PdfColors.grey, thickness: 0.5),
          pw.SizedBox(height: 20),
          pw.Text(
            'Historial de Incidentes:',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
          ),
          pw.SizedBox(height: 10),
          fallHistoryTable,
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _generatePdfSection(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return pw.Text('$title: Sin datos', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
        ),
        pw.SizedBox(height: 5),
        ...data.entries.map((entry) {
          final key = _translateKey(entry.key);
          final value = entry.value is Map
              ? entry.value.entries.map((e) => '${_translateKey(e.key)}: ${e.value}').join(', ')
              : entry.value;
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text('$key: $value', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
          );
        }).toList(),
      ],
    );
  }

  Future<pw.Widget> _generateFallHistoryTable() async {
    final fallHistoryQuery = await FirebaseFirestore.instance
        .collection('monitored_users')
        .doc(userId)
        .collection('fall_history')
        .orderBy('timestamp', descending: true)
        .get();

    final fallHistoryDocs = fallHistoryQuery.docs;

    if (fallHistoryDocs.isEmpty) {
      return pw.Text(
        'No hay historial de caídas registrado.',
        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
      );
    }

    final headers = ['Tipo', 'Fecha', 'Confirmado', 'Descripción', 'Tiempo Confirmación'];
    final data = fallHistoryDocs.map((doc) {
      final record = doc.data();
      final timestamp = record['timestamp'] != null
          ? (record['timestamp'] as Timestamp).toDate().toString()
          : 'Sin fecha';
      final type = record['type'] ?? 'Desconocido';
      final description = record['description'] ?? 'Sin descripción';
      final confirmed = record['confirmed'] == true ? 'Sí' : 'No';
      final timeToConfirm = _formatTimeToConfirm(record['timeToConfirm'] ?? 0);
      return [type, timestamp, confirmed, description, timeToConfirm];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
      cellStyle: pw.TextStyle(fontSize: 12, color: PdfColors.black),
      cellHeight: 25,
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FixedColumnWidth(140),
        3: const pw.FixedColumnWidth(200), // Fija el ancho de la columna de descripción

      },
    );
  }


  String _formatTimeToConfirm(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  String _translateKey(String key) {
    const translations = {
      'address': 'Dirección',
      'gender': 'Género',
      'fullName': 'Nombre Completo',
      'dateOfBirth': 'Fecha de Nacimiento',
      'allergies': 'Alergias',
      'medicalConditions': 'Condiciones Médicas',
      'hospitalizationHistory': 'Historial de Hospitalización',
      'date': 'Fecha',
      'reason': 'Motivo',
      'medicalContact': 'Contacto Médico',
      'name': 'Nombre',
      'phone': 'Teléfono',
      'notes': 'Notas',
      'recommendations': 'Recomendaciones',
      'type': 'Tipo',
      'timestamp': 'Fecha',
      'confirmed': 'Confirmado',
      'description': 'Descripción',
      'timeToConfirm': 'Tiempo de Confirmación',
    };
    return translations[key] ?? key;
  }



}
