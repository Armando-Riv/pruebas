// armando-riv/pruebas/pruebas-38caa71216303abb0a7200dd8da65615cd041ce8/lib/welcome_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


// Constantes de color IMSS (Verde principal y fondo claro)
const Color kPrimaryColor = Color(0xFF00584E);
const Color kBackgroundColor = Color(0xFFF0F0F0);


// Widget personalizado para los botones
class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final double textSize;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.textSize =25,
    this.backgroundColor = kPrimaryColor, // Aplicar color primario por defecto
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: textColor,
      ),
      label: Text(
        text,
        style: TextStyle(
          fontSize: textSize, // Aplicar el tamaño del texto
          color: textColor, // Cambiar el color del texto
        ),

      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Aplicar el color de fondo
        minimumSize: const Size(300, 60), // Tamaño mínimo del botón
      ),
    );
  }
}

// Pantalla principal que usa los botones personalizados
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor, // Fondo IMSS
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isHorizontal = constraints.maxWidth > constraints.maxHeight;

          return Center(

            child: isHorizontal
                ? Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Image.asset(
                    'assets/images/logo_inicio.png',
                    height: 300,
                    width: 300,
                    color: kPrimaryColor, // Color al logo
                  ),
                ),
                const SizedBox(height: 100),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      icon: Icons.login_rounded,
                      text: 'Iniciar sesión',
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      backgroundColor: kPrimaryColor, // Color primario
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 60),
                    CustomButton(
                      icon: CupertinoIcons.person_add,
                      text: 'Registrarse',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      backgroundColor: Colors.white24,
                      textColor: kPrimaryColor, // Color primario
                    ),
                  ],
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset(
                    'assets/images/logo_inicio.png',
                    height: 300, // Se redujo el tamaño del logo para mejor ajuste en vertical
                    width: 300,
                    color: kPrimaryColor, // Color al logo
                  ),
                ),
                const SizedBox(height: 50),
                CustomButton(
                  icon: Icons.login_rounded,
                  text: 'Iniciar sesión',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  backgroundColor: kPrimaryColor, // Color primario
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  icon: CupertinoIcons.person_add,
                  text: 'Registrarse',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  backgroundColor: Colors.white60,
                  textColor: kPrimaryColor, // Color primario
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}