import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';
import 'font_size_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicio',
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
        currentRoute: HomeScreen.routeName,
      ),
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.currentUser != null
            ? Future.value(FirebaseAuth.instance.currentUser)
            : Future.error('Usuario no autenticado'),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const Center(
              child: Text('Usuario no autenticado.'),
            );
          }

          final userEmail = authSnapshot.data!.email;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('monitored_users')
                .where('requestedBy', isEqualTo: userEmail)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar los datos: ${snapshot.error}',
                    style: TextStyle(fontSize: fontSizeProvider.fontSize),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No hay usuarios monitoreados.',
                    style: TextStyle(fontSize: fontSizeProvider.fontSize),
                  ),
                );
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.person, size: fontSizeProvider.fontSize + 10),
                      title: Text(
                        user['personalInformation']['fullName'] ?? 'Sin Nombre',
                        style: TextStyle(fontSize: fontSizeProvider.fontSize),
                      ),
                      subtitle: Text(
                        'Presiona para más detalles',
                        style: TextStyle(fontSize: fontSizeProvider.fontSize - 2),
                      ),
                      onTap: () => _showUserDetails(context, user, fontSizeProvider),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/startReg');
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Registrar Nuevo Usuario',
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user,
      FontSizeProvider fontSizeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  'Detalles del Usuario',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 4,
                    fontWeight: FontWeight.bold,


                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildUserDetail(
                  'Nombre Completo',
                  user['personalInformation']['fullName'],
                  fontSizeProvider,
                ),
                _buildUserDetail(
                  'Fecha de Nacimiento',
                  user['personalInformation']['dateOfBirth'],
                  fontSizeProvider,
                ),
                _buildUserDetail(
                  'Género',
                  user['personalInformation']['gender'],
                  fontSizeProvider,
                ),
                _buildUserDetail(
                  'Domicilio',
                  user['personalInformation']['address'],
                  fontSizeProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  'Información Médica',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildUserDetail(
                  'Condiciones Médicas',
                  user['medicalInformation']['medicalConditions'],
                  fontSizeProvider,
                ),
                _buildUserDetail(
                  'Alergias',
                  user['medicalInformation']['allergies'],
                  fontSizeProvider,
                ),
                if (user['medicalInformation']['medications'] != null &&
                    (user['medicalInformation']['medications'] as List<dynamic>).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Medicamentos:',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._buildMedicationsDetails(
                        user['medicalInformation']['medications'] as List<dynamic>,
                        fontSizeProvider,
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Text(
                  'Información Adicional',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildUserDetail(
                  'Notas',
                  user['additionalInformation']['notes'],
                  fontSizeProvider,
                ),
                _buildUserDetail(
                  'Recomendaciones',
                  user['additionalInformation']['recommendations'],
                  fontSizeProvider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserDetail(
      String label, dynamic value, FontSizeProvider fontSizeProvider) {
    // Maneja valores que pueden ser una lista o un string
    String displayValue;
    if (value is List<dynamic>) {
      displayValue = value.isNotEmpty ? value.join(', ') : 'No especificado';
    } else if (value is String) {
      displayValue = value.isNotEmpty ? value : 'No especificado';
    } else {
      displayValue = 'No especificado';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: fontSizeProvider.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(fontSize: fontSizeProvider.fontSize),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMedicationsDetails(
      List<dynamic> medications, FontSizeProvider fontSizeProvider) {
    return medications.map((medication) {
      final name = medication['name'] ?? 'Sin Nombre';
      final dosage = medication['dosage'] ?? 'Sin Dosis';
      final frequency = medication['frequency'] ?? 'Sin Frecuencia';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          '- $name (Dosis: $dosage, Frecuencia: $frequency)',
          style: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      );
    }).toList();
  }
}
