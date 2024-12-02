import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app_drawer.dart';
import 'fall_history_screen.dart';
import 'font_size_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Solicitar permisos (para iOS principalmente)
    FirebaseMessaging.instance.requestPermission();

    // Manejar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notificación en primer plano: ${message.notification?.title}");
      _mostrarDialogo(
        title: message.notification?.title,
        body: message.notification?.body,
      );
    });

    // Manejar notificaciones cuando se abre desde segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notificación abierta: ${message.notification?.title}");
      // Puedes redirigir a una pantalla específica aquí si es necesario
    });

    // Obtener y guardar el token de FCM
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await obtenerYGuardarToken(user.uid);
    }

    // Manejar cuando la app se abre desde una notificación inicial
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Notificación al abrir la app: ${initialMessage.notification?.title}");
      // Maneja datos iniciales aquí si es necesario
    }

    // Actualizar token automáticamente si cambia
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("Token actualizado: $newToken");
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': newToken,
        });
      }
    });
  }

  void _mostrarDialogo({String? title, String? body}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title ?? "Notificación"),
        content: Text(body ?? "Sin contenido"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
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
                  final userId = snapshot.data!.docs[index].id;

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
                      onTap: () => _showUserDetails(context, user, userId, fontSizeProvider),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteUser(userId),
                      ),
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

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _deleteUser(userId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('monitored_users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user, String userId,
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
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize + 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
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
                  'Dirección',
                  user['personalInformation']['address'],
                  fontSizeProvider,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FallHistoryScreen(
                            userId: userId,
                            userName: user['personalInformation']['fullName'],
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver Historial de Caídas'),
                  ),
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
    String displayValue = value is String && value.isNotEmpty
        ? value
        : (value is List && value.isNotEmpty ? value.join(', ') : 'No especificado');

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
}

Future<void> obtenerYGuardarToken(String userId) async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("Token FCM: $token");

  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
    });
    print("Token guardado en Firestore.");
  }
}
