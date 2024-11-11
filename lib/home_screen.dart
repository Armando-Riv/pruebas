import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        drawer: AppDrawer(fontSizeProvider: fontSizeProvider, currentRoute: HomeScreen.routeName),
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: Center(
        child: Text(
          'Usuarios Monitoreados - Página principal',
          style: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
    );
  }
}
