// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/main.dart

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pruebas/patient_reg_screen.dart';
import 'about_screen.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:pruebas/font_size_provider.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'user_profile_screen.dart';
import 'patient_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importación necesaria

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Maneja notificaciones cuando la app está en segundo plano
  print("Notificación en segundo plano: ${message.notification?.title}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase inicializado con éxito");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  // Inicializar el proveedor de tamaño de fuente y cargar preferencias
  final fontSizeProvider = FontSizeProvider();
  await fontSizeProvider.loadFontSize(); // Carga el tamaño de fuente persistido

  runApp(
    ChangeNotifierProvider.value(
      value: fontSizeProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              // Lógica: Verificar el rol del usuario para dirigir a HomeScreen
              final user = snapshot.data!;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final userType = userData['userType'];

                    // Pasar el rol a HomeScreen
                    return HomeScreen(userType: userType);
                  }

                  // Si el usuario está autenticado pero falta el doc de usuario, regresa a la bienvenida
                  return WelcomeScreen();
                },
              );
            } else {
              return WelcomeScreen(); // Muestra WelcomeScreen si no hay usuario autenticado
            }
          },
        ),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/about': (context) => AboutScreen(),
        '/user': (context) => UserProfileScreen(),
        '/startReg': (context) => PatientRegistrationScreen(),

      },
    );
  }
}