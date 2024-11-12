import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceCheckScreen extends StatefulWidget {
  static const routeName = '/check';
  @override
  _DeviceCheckScreenState createState() => _DeviceCheckScreenState();
}

class _DeviceCheckScreenState extends State<DeviceCheckScreen> {
  bool _isLoading = true;
  bool _devicesAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceAvailability();
  }

  Future<void> _checkDeviceAvailability() async {
    setState(() {
      _isLoading = true;
    });

    // Consulta para verificar si hay algún dispositivo disponible
    final devices = await FirebaseFirestore.instance
        .collection('devices')
        .where('status', isEqualTo: 'available')
        .get();

    setState(() {
      _isLoading = false;
      _devicesAvailable = devices.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verificación de Dispositivos"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Animación de carga
            : _devicesAvailable
            ? Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [


           Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
        BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),


    ],),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[

        const Icon(Icons.check_circle, color: Colors.green, size: 80),
               const SizedBox(height: 20),
               const Text(
                 "Dispositivos disponible",
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
               ),
               ElevatedButton(
                 onPressed: () {
                   // Redirige a la pantalla de agregar paciente
                   Navigator.pushNamed(context, '/addPatient');
                 },
                 child: const Text("Continuar para agregar paciente"),
               ),


         ],    ),

           ),

    ],

        )
            : Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 1,
                    offset: const Offset(0, 5),
                  ),


                ],),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[

                  const Icon(Icons.error_rounded, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    " no hay dispositivos disponibles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),



                ],    ),

            ),

          ],

        )
      ),
    );
  }
}
