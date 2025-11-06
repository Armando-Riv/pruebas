// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pruebas/patient_reg_screen.dart';
import 'about_screen.dart';
import 'font_size_provider.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';

// Constantes de color IMSS
const Color kPrimaryColor = Color(0xFF00584E);
const Color kSecondaryColor = Color(0xFF1B8247); // Verde Secundario
const Color kBackgroundColor = Color(0xFFF0F0F0);


class AppDrawer extends StatelessWidget {
  final FontSizeProvider fontSizeProvider;
  final String currentRoute;
  final String? userType; // Campo para el rol del usuario

  AppDrawer({required this.fontSizeProvider, required this.currentRoute, this.userType});

  @override
  Widget build(BuildContext context) {
    final isCaregiver = userType == 'Cuidador'; // Determinar si es cuidador

    return Drawer(
      backgroundColor: kBackgroundColor, // Fondo institucional
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: kPrimaryColor, // Color primario
            height: 100, // 👈 Control the height here
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Opciones',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 5,
                color: Colors.white,
                fontWeight: FontWeight.bold,

              ),
            ),
          ),
          const SizedBox(height: 10,),
          // Opciones del menú
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Inicio',
            route: HomeScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Perfil',
            route: UserProfileScreen.routeName,
          ),
          // Mostrar solo si es Cuidador
          if (isCaregiver)
            _buildDrawerItem(
              context,
              icon: Icons.person_add,
              title: 'Registrar Paciente',
              route: PatientRegistrationScreen.routeName,
            ),

          _buildDrawerItem(
            context,
            icon: Icons.info,
            title: 'Acerca de',
            route: AboutScreen.routeName,
          ),
          // Ajustar tamaño de letra
          ListTile(
            leading: const Icon(Icons.format_size, color: kPrimaryColor),
            title: Text(
              'Ajustar tamaño de letra',
              style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black87),
            ),
            onTap: () => _showFontSizeDialog(context, fontSizeProvider),
          ),
          // Cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black87),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Cerrar Sesión', style: TextStyle(color: kPrimaryColor)),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        // Asegura que la ruta de inicio maneje la redirección después de cerrar sesión
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                      },
                      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required String route}) {
    final bool isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : kPrimaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      tileColor: isSelected ? kPrimaryColor : null,
      selected: isSelected,
      selectedTileColor: kPrimaryColor, // Color primario
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kPrimaryColor, // Color primario
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Center(
                child: Text(
                  'Ajustar tamaño de letra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tamaño actual: ${fontSizeProvider.fontSize.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Slider(
                    min: 16.0,
                    max: 26.0,
                    value: fontSizeProvider.fontSize,
                    activeColor: kSecondaryColor, // Color secundario
                    inactiveColor: Colors.grey,
                    onChanged: (newSize) {
                      fontSizeProvider.setFontSize(newSize);
                      setState(() {});
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kSecondaryColor, // Color secundario
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}