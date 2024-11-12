import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pruebas/device_check_screen.dart';
import 'about_screen.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart'; // Crea esta pantalla a continuación
import 'package:pruebas/font_size_provider.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'user_profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase inicializado con éxito"); // Mensaje de verificación
  runApp(
    ChangeNotifierProvider(
      create: (context) => FontSizeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomeScreen(); // Redirige a HomeScreen si el usuario está autenticado
          } else {
            return WelcomeScreen(); // Muestra WelcomeScreen si no hay usuario autenticado
          }
        },
      ),
      '/login': (context) => LoginScreen(),
      '/register': (context) => RegisterScreen(),
      '/home': (context) => HomeScreen(), // Agrega HomeScreen a las rutas
      '/about': (context) => AboutScreen(), // Define la ruta para AboutScreen
      '/user':(context)=>UserProfileScreen(),
      '/check': (context)=>DeviceCheckScreen(),
    },
  );
}
}
