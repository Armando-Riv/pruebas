import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _activityNotifications = true;
  bool _reminderNotifications = true;
  bool _offlineMode = false;
  bool _highContrast = false;
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración', style: TextStyle(fontSize: fontSizeProvider.fontSize)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Ajustes de Personalización',
              style: TextStyle(fontSize: fontSizeProvider.fontSize + 4, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Modo oscuro
            SwitchListTile(
              title: Text('Modo oscuro', style: TextStyle(fontSize: fontSizeProvider.fontSize)),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),

            // Tamaño de fuente
            ListTile(
              title: Text('Tamaño de fuente', style: TextStyle(fontSize: fontSizeProvider.fontSize)),
              trailing: Text('${fontSizeProvider.fontSize.toStringAsFixed(0)}'),
            ),
            Slider(
              min: 16.0,
              max: 24.0,
              value: fontSizeProvider.fontSize,
              onChanged: (newSize) {
                fontSizeProvider.setFontSize(newSize);
              },
            ),

            // Notificaciones
            SwitchListTile(
              title: Text('Activar notificaciones', style: TextStyle(fontSize: fontSizeProvider.fontSize)),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),

            // Selector de idioma
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Icon(Icons.language),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Idioma',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      value: _selectedLanguage,
                      items: [
                        DropdownMenuItem(child: Text("Español"), value: "es"),
                        DropdownMenuItem(child: Text("Inglés"), value: "en"),
                      ],
                      onChanged: (String? newLanguage) {
                        setState(() {
                          _selectedLanguage = newLanguage;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Botón para restablecer ajustes
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onPressed: () {
                  // Confirmación y restablecimiento de ajustes
                },
                child: Text(
                  'Restablecer Ajustes',
                  style: TextStyle(fontSize: fontSizeProvider.fontSize),
                ),
              ),
            ),

            // Botón de volver
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Volver',
                  style: TextStyle(fontSize: fontSizeProvider.fontSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
