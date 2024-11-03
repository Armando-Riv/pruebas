import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color.fromARGB(198, 137, 215, 249),

      body: Center(
        
        
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Custos',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
