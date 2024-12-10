import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../widgets/main_navigation.dart';

class NotificationDetailPage extends StatefulWidget {
  final int exchangeId;
  final int bookId;
  final String fromUserId;
  final String requestedDate;

  const NotificationDetailPage({
    Key? key,
    required this.exchangeId,
    required this.bookId,
    required this.fromUserId,
    required this.requestedDate,
  }) : super(key: key);

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late Future<Map<String, dynamic>> _userDetails;
  late Future<List<Map<String, dynamic>>> _userBooks;
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userDetails = getFromUserDetails(widget.fromUserId);
    _userBooks = getFromUserBooks(widget.fromUserId);
  }

  Future<void> _handleAcceptExchange() async {
    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un libro para aceptar.')),
      );
      return;
    }

    try {
      // Llamada al servicio para aceptar el intercambio
      await acceptExchangeRequest(
        exchangeId: widget.exchangeId,
        selectedBookId: int.parse(_selectedBookId!),
      );

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intercambio aceptado exitosamente.')),
      );

      // Redirigir usando MainNavigation
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar el intercambio: $e')),
      );
    }
  }

  Future<void> _handleRejectExchange() async {
    try {
      // Llamada al servicio para rechazar el intercambio
      await rejectExchangeRequest(widget.exchangeId);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intercambio rechazado.')),
      );

      // Redirigir usando MainNavigation
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar el intercambio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de la Solicitud',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2196F3),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Libro Solicitado'),
            FutureBuilder<Map<String, dynamic>>(
              future: getBookDetailById(widget.bookId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return const Text(
                      'No se encontró información del libro solicitado.');
                }

                final bookDetails = snapshot.data!;
                return _buildBookInfoCard(
                  title: bookDetails['title'],
                  photoUrl: bookDetails['photo_url'],
                  description: bookDetails['description'],
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Información del Solicitante'),
            FutureBuilder<Map<String, dynamic>>(
              future: _userDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return const Text(
                      'No se pudo cargar la información del solicitante.');
                }

                final userDetails = snapshot.data!;
                return _buildUserInfoCard(
                  name: userDetails['name'],
                  photoUrl: userDetails['photo_url'],
                  rating: (userDetails['rating'] as num).toDouble(),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Seleccionar un Libro'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _userBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                      'El usuario no tiene libros disponibles para el intercambio.');
                }

                final books = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _selectedBookId,
                  decoration: InputDecoration(
                    labelText: 'Selecciona un libro',
                    labelStyle: const TextStyle(color: Color(0xFF2196F3)),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2196F3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1976D2)),
                    ),
                  ),
                  items: books.map((book) {
                    return DropdownMenuItem<String>(
                      value: book['id'].toString(),
                      child: Text(book['title']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBookId = value;
                    });
                  },
                );
              },
            ),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Aceptar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _selectedBookId == null ? null : _handleAcceptExchange,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Rechazar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _handleRejectExchange,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2)),
      ),
    );
  }

  Widget _buildBookInfoCard({
    required String title,
    required String photoUrl,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photoUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, size: 50, color: Colors.grey);
            },
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildUserInfoCard({
    required String name,
    required String photoUrl,
    required double rating,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(photoUrl),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Calificación: ${rating.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
