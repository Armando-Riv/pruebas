import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';

class FallHistoryScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const FallHistoryScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de  $userName',
          style: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('monitored_users')
            .doc(userId)
            .collection('fall_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay registros de eventos para este usuario.',
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
            );
          }

          final fallHistory = snapshot.data!.docs;

          return ListView.builder(
            itemCount: fallHistory.length,
            itemBuilder: (ctx, index) {
              final fall = fallHistory[index].data() as Map<String, dynamic>;
              final timestamp = fall['timestamp']?.toDate();
              final description = fall['description'] ?? '';
              final confirmed = fall['confirmed'] ?? false;
              final confirmedBy = fall['confirmedBy'] ?? 'N/A';
              final timeToConfirm = fall['timeToConfirm'] ?? 0;
              final type = fall['type'] ?? 'Sin tipo';

              final adjustedTimestamp = timestamp?.subtract(const Duration(hours: 1));
              final formattedDate = adjustedTimestamp != null
                  ? '${adjustedTimestamp.day.toString().padLeft(2, '0')} '
                  '${_monthName(adjustedTimestamp.month)} '
                  '${adjustedTimestamp.year}, ${adjustedTimestamp.hour.toString().padLeft(2, '0')}:${adjustedTimestamp.minute.toString().padLeft(2, '0')} ${adjustedTimestamp.hour < 12 ? 'AM' : 'PM'}'
                  : 'Sin fecha';

              IconData icon;
              Color iconColor;

              if (confirmed) {
                if (confirmedBy == 'Paciente' && description.isEmpty) {
                  icon = Icons.hourglass_empty;
                  iconColor = Colors.yellow;
                } else {
                  icon = Icons.check_circle;
                  iconColor = Colors.green;
                }
              } else {
                icon = Icons.warning;
                iconColor = Colors.red;
              }

              IconData confirmedByIcon = confirmedBy == 'Paciente'
                  ? Icons.accessible_forward_outlined
                  : Icons.account_circle;

              Color confirmedByColor = confirmedBy == 'Paciente'
                  ? Colors.blue
                  : Colors.orange;

              final String timeToConfirmText = _formatTimeToConfirm(timeToConfirm);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Ícono principal centrado verticalmente
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: iconColor,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeProvider.fontSize,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (confirmed && description.isEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Descripción pendiente',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: fontSizeProvider.fontSize - 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (description.isNotEmpty)
                              Text(
                                description,
                                style: TextStyle(fontSize: fontSizeProvider.fontSize - 5),
                              ),
                            const SizedBox(height: 8),
                            if (confirmed)
                              Row(
                                children: [
                                  Icon(
                                    confirmedByIcon,
                                    color: confirmedByColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Confirmado en $timeToConfirmText',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: fontSizeProvider.fontSize - 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: fontSizeProvider.fontSize - 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Botón dinámico basado en el estado
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!confirmed)
                            IconButton(
                              onPressed: () => _handleAction(
                                context,
                                fallHistory[index].id,
                                confirmed,
                                description,
                                timestamp,
                              ),
                              icon: const Icon(
                                Icons.thumb_up_rounded,
                                color: Colors.green,
                              ),
                              tooltip: 'Confirmar caída',
                            ),
                          if (confirmed && description.isEmpty)
                            IconButton(
                              onPressed: () => _handleAction(
                                context,
                                fallHistory[index].id,
                                confirmed,
                                description,
                                timestamp,
                              ),
                              icon: const Icon(
                                CupertinoIcons.pencil,
                                color: Colors.purple,
                              ),
                              tooltip: 'Agregar descripción',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeToConfirm(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      final int minutes = seconds ~/ 60;
      final int remainingSeconds = seconds % 60;
      return '${minutes} min ${remainingSeconds} sec';
    }
  }

  String _monthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month - 1];
  }
  Future<void> _handleAction(
      BuildContext context,
      String eventId,
      bool confirmed,
      String description,
      DateTime? timestamp,
      ) async {
    // Pedir al usuario una nueva descripción
    String? newDescription = await _askForDescription(context);
    if (newDescription == null || newDescription.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción es obligatoria.')),
      );
      return;
    }

    try {
      // Obtenemos el documento actual del evento para verificar sus valores
      final eventDoc = await FirebaseFirestore.instance
          .collection('monitored_users')
          .doc(userId)
          .collection('fall_history')
          .doc(eventId)
          .get();

      final eventData = eventDoc.data();

      if (eventData == null) {
        throw Exception("El evento no existe.");
      }

      // Mantener valores actuales si ya están definidos
      final existingConfirmationTimestamp =
      eventData['confirmationTimestamp']?.toDate();
      final existingTimeToConfirm = eventData['timeToConfirm'];

      // Si no hay timestamp previo, calcular el tiempo de confirmación
      final now = DateTime.now();
      final int newTimeToConfirm = timestamp != null
          ? now.difference(timestamp).inSeconds
          : 0;

      await FirebaseFirestore.instance
          .collection('monitored_users')
          .doc(userId)
          .collection('fall_history')
          .doc(eventId)
          .update({
        'description': newDescription,
        'confirmed': true,
        'confirmationTimestamp': existingConfirmationTimestamp ?? now,
        'confirmedBy': 'Usuario',
        'timeToConfirm': existingTimeToConfirm ?? newTimeToConfirm,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento confirmado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar evento: $e')),
      );
    }
  }


  Future<String?> _askForDescription(BuildContext context) async {
    String? description;
    await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Agregar descripción'),
          content: TextField(
            onChanged: (value) {
              description = value;
            },
            decoration: const InputDecoration(hintText: 'Ingresa la descripción'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(description);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return description;
  }
}
