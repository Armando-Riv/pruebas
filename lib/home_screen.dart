import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';


class HomeScreen extends StatefulWidget {
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
      drawer: _buildDrawer(context, fontSizeProvider),
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: Center(
        child: Text(
          'Usuarios Monitoreados - Página principal',
          style: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, FontSizeProvider fontSizeProvider) {
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
            text: 'Usuarios Monitoreados',
            fontSizeProvider: fontSizeProvider,
            onTap: () =>
                _navigateToUnderConstruction(context, 'Usuarios Monitoreados'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_add,
            text: 'Agregar Usuario',
            fontSizeProvider: fontSizeProvider,
            onTap: () =>
                _navigateToUnderConstruction(context, 'Agregar Usuario'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.settings,
            text: 'Configuración',
            fontSizeProvider: fontSizeProvider,
            onTap: () => _navigateToUnderConstruction(context, 'Configuración'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            text: 'Preferencias del Perfil',
            fontSizeProvider: fontSizeProvider,
            onTap: () =>
                _navigateToUnderConstruction(
                    context, 'Preferencias del Perfil'),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.logout,
            text: 'Cerrar Sesión',
            fontSizeProvider: fontSizeProvider,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            text: 'Acerca de',
            fontSizeProvider: fontSizeProvider,
            onTap: () => _navigateToUnderConstruction(context, 'Acerca de'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String text,
    required FontSizeProvider fontSizeProvider,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: TextStyle(
            fontSize: fontSizeProvider.fontSize, color: Colors.black87),
      ),
      onTap: onTap,
    );
  }

  void _navigateToUnderConstruction(BuildContext context, String title) {
    Navigator.of(context).pop(); // Cierra el drawer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UnderConstructionScreen(title: title),
      ),
    );
  }

}

class UnderConstructionScreen extends StatelessWidget {
  final String title;

  const UnderConstructionScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      body: Center(
        child: Text(
          '$title está en construcción',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
