import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    this.textSize = 20.0,
    this.backgroundColor = const Color.fromARGB(255, 0, 39, 152),
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
      backgroundColor: const Color.fromARGB(198, 137, 215, 249),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isHorizontal = constraints.maxWidth > constraints.maxHeight;

          return Center(
            child: isHorizontal
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Image.asset(
                    'assets/images/logo_inicio.png',
                    height: 300,
                    width: 300,
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
                      backgroundColor: Colors.black38,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 60),
                    CustomButton(
                      icon: CupertinoIcons.person_add,
                      text: 'Registrarse',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      backgroundColor: Colors.white,
                      textColor: Colors.blueGrey,
                    ),
                  ],
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset(
                    'assets/images/logo_inicio.png',
                    height: 500,
                    width: 500,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  icon: Icons.login_rounded,
                  text: 'Iniciar sesión',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  backgroundColor: Colors.black38,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  icon: CupertinoIcons.person_add,
                  text: 'Registrarse',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  backgroundColor: Colors.white,
                  textColor: Colors.blueGrey,
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
