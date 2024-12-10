import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../constants/colors.dart';

class ExchangePage extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  final String bookPhotoUrl;
  final String bookDescription;

  const ExchangePage({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.bookPhotoUrl,
    required this.bookDescription,
  });

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  late Future<Map<String, dynamic>> _ownerProfileFuture;

  Future<Map<String, dynamic>> _loadOwnerProfile() async {
    // Usar el método combinado del servicio
    return await getBookOwnerProfileByBookId(widget.bookId);
  }

  @override
  void initState() {
    super.initState();
    _ownerProfileFuture = _loadOwnerProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Intercambio',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Información del libro
            _buildBookInfoSection(),
            const SizedBox(height: 16),
            // Información del propietario
            FutureBuilder<Map<String, dynamic>>(
              future: _ownerProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No se encontró información del propietario.'),
                  );
                }

                final ownerData = snapshot.data!;
                return _buildOwnerInfoSection(
                  ownerData['name'],
                  ownerData['photo_url'],
                  ownerData['rating']
                      as double, // Si ya es double, estará seguro aquí
                );
              },
            ),
            const SizedBox(height: 16),
            // Condiciones del intercambio
            _buildExchangeConditionsSection(),
            const SizedBox(height: 16),
            // Botón para enviar la solicitud
            _buildExchangeRequestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Libro Seleccionado:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Image.network(
            widget.bookPhotoUrl,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            widget.bookTitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.bookDescription,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoSection(String name, String photoUrl, double rating) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Propietario del Libro:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundColor:
                Colors.grey[200], // Cambia el color de fondo mientras carga
            backgroundImage: const AssetImage(
                'assets/images/placeholder.png'), // Imagen por defecto
            child: ClipOval(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png', // Imagen temporal
                image: photoUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Calificación: $rating',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeConditionsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Condiciones del Intercambio:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "- Este intercambio es permanente.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            "- Las partes acordarán la entrega en una ubicación conveniente.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRequestButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        try {
          await sendExchangeRequest(bookId: widget.bookId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud enviada exitosamente.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar la solicitud: $e')),
          );
        }
      },
      child: const Text(
        'Solicitar Intercambio',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
