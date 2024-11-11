import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';
import 'app_drawer.dart';

class AboutScreen extends StatelessWidget {
  @override
  static const routeName = '/about';
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acerca de',
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize + 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      drawer: AppDrawer(fontSizeProvider: fontSizeProvider, currentRoute: AboutScreen.routeName),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información de la aplicación', fontSizeProvider),
              _buildInfoText(
                'Esta aplicación ha sido desarrollada para ayudar en el monitoreo de personas con problemas de movilidad y evitar accidentes.',
                fontSizeProvider,
              ),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Desarrollador', fontSizeProvider),
              _buildInfoText(
                'Desarrollada por Armando Rivera',
                fontSizeProvider,
              ),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Versión', fontSizeProvider),
              _buildInfoText(
                'Versión 1.0.0',
                fontSizeProvider,
              ),
              const SizedBox(height: 25.0),
              _buildSectionTitle('Política de privacidad', fontSizeProvider),
              InkWell(
                onTap: () => _showPrivacyPolicyDialog(context, fontSizeProvider),
                child: Text(
                  'Consulta nuestra política de privacidad',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: Colors.blueAccent[700],
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 15.0),

              _buildSectionTitle('Términos y condiciones', fontSizeProvider),
              InkWell(
                onTap: () => _showTermsDialog(context, fontSizeProvider),
                child: Text(
                  'Consulta nuestros términos y condiciones',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: Colors.blueAccent[700],
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 4,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            height: 300, // Altura fija para asegurar el scroll
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Color de fondo distinto para indicar que se puede hacer scroll
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Esta es nuestra política de privacidad:\n\n'
                      '1. Recopilación de información: Solo recolectamos los datos necesarios para el funcionamiento de la aplicación.\n\n'
                      '2. Uso de datos: Sus datos solo se usan para proporcionar y mejorar los servicios ofrecidos.\n\n'
                      '3. Seguridad: Implementamos medidas de seguridad para proteger su información.\n\n'
                      '4. Terceros: No compartimos su información con terceros sin su consentimiento, salvo que sea necesario para cumplir con la ley.\n\n'
                      '5. Derechos del usuario: Puede solicitar la eliminación de sus datos en cualquier momento.\n\n'
                      'Para más detalles, contáctenos a través de nuestra app.\n\n'
                      'Gracias por confiar en nosotros.',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blueAccent[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizeProvider.fontSize + 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context, FontSizeProvider fontSizeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              'Términos y condiciones',
              style: TextStyle(
                fontSize: fontSizeProvider.fontSize + 4,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            height: 300, // Altura fija para asegurar el scroll
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Color de fondo distinto para indicar que se puede hacer scroll
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Estos son nuestros términos y condiciones:\n\n'
                      '1. Aceptación de términos: Al utilizar esta aplicación, usted acepta nuestros términos y condiciones.\n\n'
                      '2. Uso permitido: La aplicación está destinada solo para su uso personal y no comercial.\n\n'
                      '3. Propiedad intelectual: Todo el contenido es propiedad de la empresa y está protegido por derechos de autor.\n\n'
                      '4. Limitación de responsabilidad: No somos responsables de ningún daño derivado del uso de la aplicación.\n\n'
                      '5. Cambios en los términos: Nos reservamos el derecho de modificar estos términos en cualquier momento.\n\n'
                      'Para cualquier pregunta, contáctenos a través de la app.\n\n'
                      'Gracias por utilizar nuestra aplicación.',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blueAccent[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizeProvider.fontSize + 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, FontSizeProvider fontSizeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSizeProvider.fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[700],
      ),
    );
  }

  Widget _buildInfoText(String text, FontSizeProvider fontSizeProvider) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSizeProvider.fontSize + 1,
        color: Colors.black87,
      ),
    );
  }
}
