import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pruebas/device_check_screen.dart';
import 'about_screen.dart';
import 'font_size_provider.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'device_check_screen.dart';

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
          _buildDrawerItem(
            context,
            icon: Icons.wheelchair_pickup,
            text: 'Pacientes Monitoreados',
            targetRoute: HomeScreen.routeName,
            onTap: () => Navigator.of(context).pushNamed(HomeScreen.routeName),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_add,
            text: 'Agregar Paciente',
            targetRoute: DeviceCheckScreen.routeName,
            onTap: () => Navigator.of(context).pushNamed(DeviceCheckScreen.routeName),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.text_fields,
            text: 'Ajustar Tamaño de Letra',
            onTap: () => _showFontSizeDialog(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            text: 'Datos Personales',
            targetRoute: UserProfileScreen.routeName,
            onTap: () => Navigator.of(context).pushNamed(UserProfileScreen.routeName),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            text: 'Cerrar Sesión',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            text: 'Acerca de',
            targetRoute: AboutScreen.routeName,
            onTap: () => Navigator.of(context).pushNamed(AboutScreen.routeName),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        String? targetRoute,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: TextStyle(fontSize: fontSizeProvider.fontSize, color: Colors.black87),
      ),
      onTap: () {
        // Si la ruta actual es la misma que la de destino, solo cierra el Drawer.
        if (targetRoute != null && targetRoute == currentRoute) {
          Navigator.of(context).pop();
        } else {
          onTap();
        }
      },
    );
  }

  void _showFontSizeDialog(BuildContext context) {
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
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
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

  void _showUnderConstructionDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'En construcción',
            style: TextStyle(
              fontSize: fontSizeProvider.fontSize + 4,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'La funcionalidad "$featureName" aún está en desarrollo.',
            style: TextStyle(fontSize: fontSizeProvider.fontSize),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
