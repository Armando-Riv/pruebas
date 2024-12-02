import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pruebas/patient_reg_screen.dart';
import 'about_screen.dart';
import 'font_size_provider.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final FontSizeProvider fontSizeProvider;
  final String currentRoute;

  AppDrawer({required this.fontSizeProvider, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(250, 137, 215, 249),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey[700]),
            child: Text(
              'Opciones',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 5,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            leading: const Icon(Icons.format_size),
            title: Text(
              'Ajustar tamaño de letra',
              style: TextStyle(fontSize: fontSizeProvider.fontSize),
            ),
            onTap: () => _showFontSizeDialog(context, fontSizeProvider),
          ),
          // Cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: fontSizeProvider.fontSize),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: const Text('Cerrar Sesión'),
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
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      tileColor: isSelected ? Colors.blueGrey : null,
      selected: isSelected,
      selectedTileColor: Colors.blueGrey[700],
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
              backgroundColor: Colors.black26,
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
                    activeColor: Colors.blueAccent,
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
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
