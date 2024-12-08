import 'package:flutter/material.dart';
import 'package:trueque_libro/constants/colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitudes de intercambio"),
        backgroundColor: AppColors.primaryColor, // Título
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          color: const Color.fromARGB(
              255, 243, 242, 242), // Tarjeta de notificaciones
          child: ListTile(
            title: Text("Solicitud $index",
                style: const TextStyle(color: AppColors.darkGray)),
            subtitle: const Text("Estado: Pendiente",
                style: TextStyle(color: AppColors.darkGray)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  color: AppColors.positiveGreen,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Solicitud de intercambio $index aprobada"),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.negativeRed,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Solicitud de intercambio $index rechazada"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
