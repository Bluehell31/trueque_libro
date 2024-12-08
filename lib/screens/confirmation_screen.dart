import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ConfirmationScreen extends StatelessWidget {
  final String ownerName;
  final String ownerEmail;
  final String telegramUsername;

  const ConfirmationScreen({
    super.key,
    required this.ownerName,
    required this.ownerEmail,
    required this.telegramUsername,
  });

  void _contactByTelegram(BuildContext context) {
    // Acción para contactar por Telegram
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactando a $ownerName por Telegram...'),
      ),
    );
    // Aquí puedes implementar la lógica para abrir la app de Telegram con el usuario específico
  }

  void _contactByEmail(BuildContext context) {
    // Acción para contactar por Correo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactando a $ownerName por Correo...'),
      ),
    );
    // Aquí puedes implementar la lógica para abrir la app de correo o enviar un email
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmación de Intercambio',
          style: TextStyle(color: AppColors.secondaryColor),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Intercambio Confirmado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ahora puedes contactar al propietario del libro para coordinar la entrega.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Botón de Contactar por Telegram
            // Botón de Contactar por Telegram
            ElevatedButton.icon(
              icon: const Icon(Icons.telegram, color: Colors.white),
              label: const Text(
                'Contactar por Telegram',
                style:
                    TextStyle(color: Colors.white), // Cambiado a color blanco
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _contactByTelegram(context),
            ),

            const SizedBox(height: 16),
            // Botón de Contactar por Correo
            ElevatedButton.icon(
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text(
                'Contactar por Correo',
                style: TextStyle(
                    color: Color.fromRGBO(
                        255, 255, 255, 1)), // Cambiado a color blanco
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.secondaryColor, // Cambiado a secondaryColor
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _contactByEmail(context),
            ),
          ],
        ),
      ),
    );
  }
}
