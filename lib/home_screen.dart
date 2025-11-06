// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_drawer.dart';
import 'font_size_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'patient_details_screen.dart';


// Constantes de color IMSS
const Color kPrimaryColor = Color(0xFF00584E);
const Color kBackgroundColor = Color(0xFFF0F0F0);
const Color kAccentColor = Color(0xFF1B8247);


// Clase Patient simple dentro del archivo para que compile la vista
class Patient {
  final String id;
  final String fullName;
  final String dateOfBirth;
  final String lastFallDate;

  Patient.fromMap(Map<String, dynamic> data, String docId)
      : id = docId,
        fullName = data['fullName'] ?? 'N/A', // Usar el campo completo para el nombre
        dateOfBirth = data['dateOfBirth'] ?? 'No registrada',
        lastFallDate = data['lastFallDate'] ?? 'Ninguna';
}
// Fin Patient class


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final String? userType; // ACEPTAR EL ROL

  const HomeScreen({super.key, this.userType}); // CONSTRUCTOR CORREGIDO

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    // Lógica de notificaciones (si es necesario)
    // _initializeNotifications();
  }

  // Función para manejar la lógica de notificaciones
  Future<void> obtenerYGuardarToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  // --- LÓGICA DE ELIMINACIÓN COMPLEJA (Corregida) ---
  Future<void> _deletePatient(String patientId, String patientName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController confirmationController = TextEditingController();
        final fontSizeProvider = Provider.of<FontSizeProvider>(context);

        return AlertDialog(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Center(
            child: Text(
              'Confirmar Eliminación',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Para eliminar a "$patientName", escribe su nombre completo para confirmar.',
                  style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.white70),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmationController,
                  style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: patientName,
                    hintStyle: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                if (confirmationController.text.trim() == patientName) {
                  Navigator.of(context).pop();
                  try {
                    await _firestore.collection('monitored_users').doc(patientId).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Paciente $patientName eliminado con éxito.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar paciente: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre ingresado no coincide. Intenta de nuevo.')),
                  );
                }
              },
              child: Text(
                'Eliminar',
                style: TextStyle(fontSize: fontSizeProvider.fontSize, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
  // --- FIN LÓGICA DE ELIMINACIÓN COMPLEJA ---

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isCaregiver = widget.userType == 'Cuidador';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCaregiver ? 'Mis Pacientes' : 'Inicio Paciente',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // *** CORRECCIÓN: INSTANCIAR EL DRAWER CORRECTAMENTE ***
      drawer: AppDrawer(
        fontSizeProvider: fontSizeProvider,
        currentRoute: HomeScreen.routeName,
        userType: widget.userType,
      ),
      // ******************************************************

      backgroundColor: kBackgroundColor,

      body: isCaregiver
          ? _buildCaregiverView(fontSizeProvider)
          : _buildPatientView(fontSizeProvider),

      // --- FAB MÁS GRANDE (Solo para cuidadores) ---
      floatingActionButton: isCaregiver
          ? Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/startReg');
          },
          label: Text(
            'Agregar Paciente',
            style: TextStyle(
              fontSize: fontSizeProvider.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: Icon(
            Icons.person_add,
            size: fontSizeProvider.fontSize + 5,
            color: Colors.white,
          ),
          backgroundColor: kAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- FIN FAB MÁS GRANDE ---
    );
  }

  // VISTA PARA PACIENTES (Mantengo la estructura simple)
  Widget _buildPatientView(FontSizeProvider fontSizeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart, size: 80, color: kPrimaryColor),
            const SizedBox(height: 20),
            Text(
              'Bienvenido, tu estado de monitoreo está activo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Utiliza el menú para acceder a tu perfil y ajustes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // VISTA PARA CUIDADORES (Lista de pacientes)
  Widget _buildCaregiverView(FontSizeProvider fontSizeProvider) {
    if (currentUser == null) {
      return const Center(child: Text('Error: Cuidador no autenticado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('monitored_users')
          .where('requestedBy', isEqualTo: currentUser!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kAccentColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar pacientes: ${snapshot.error}', style: TextStyle(fontSize: fontSizeProvider.fontSize)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No tienes pacientes registrados. Presiona "Agregar Paciente" para añadir uno.',
              style: TextStyle(fontSize: fontSizeProvider.fontSize + 2, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          );
        }

        final patients = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final personalInfo = data['personalInformation'] as Map<String, dynamic>? ?? {};

          return Patient.fromMap({
            'fullName': personalInfo['fullName'],
            'dateOfBirth': personalInfo['dateOfBirth'],
            'lastFallDate': 'Implementar lógica de última caída', // Placeholder
          }, doc.id);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return _buildPatientCard(context, patient, fontSizeProvider);
          },
        );
      },
    );
  }


  // --- TARJETA DE PACIENTE MEJORADA ---
  Widget _buildPatientCard(BuildContext context, Patient patient, FontSizeProvider fontSizeProvider) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        leading: Icon(
          Icons.healing,
          color: kPrimaryColor,
          size: fontSizeProvider.fontSize + 15,
        ),
        title: Text(
          patient.fullName,
          style: TextStyle(
              fontSize: fontSizeProvider.fontSize + 2,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor
          ),
        ),
        // Subtítulo con más detalles
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            _buildDetailRow(
                context,
                'F. Nacimiento:',
                patient.dateOfBirth,
                Icons.cake,
                fontSizeProvider.fontSize
            ),
            _buildDetailRow(
                context,
                'Última Caída:',
                patient.lastFallDate,
                Icons.warning_amber,
                fontSizeProvider.fontSize
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
              Icons.delete_forever,
              color: Colors.red.shade700,
              size: fontSizeProvider.fontSize + 5
          ),
          onPressed: () => _deletePatient(patient.id, patient.fullName),
        ),
        onTap: () {
          // Navegar a la pantalla de detalles del paciente, pasando el ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => PatientDetailsScreen(
                patientData: {}, // Se necesitaría cargar los datos aquí si no se pasan
                userId: patient.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, double baseFontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: baseFontSize, color: Colors.grey[600]),
          const SizedBox(width: 5),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontSize: baseFontSize,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' $value',
                    style: TextStyle(
                      fontSize: baseFontSize,
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}