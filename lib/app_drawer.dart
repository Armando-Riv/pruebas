import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pruebas/patient_reg_screen.dart';
import 'about_screen.dart';
import 'font_size_provider.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'patient_reg_screen.dart';

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
                        Navigator.of(context).pushReplacementNamed('/login');
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
}
