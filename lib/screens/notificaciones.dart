import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueque_libro/constants/colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Solicitudes de intercambio",
          style: TextStyle(color: Colors.lightBlue),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount:
            5, // Aquí deberías usar el número real de solicitudes desde tu backend
        itemBuilder: (context, index) => Card(
          color: Colors.white,
          child: ListTile(
            title: Text("Solicitud $index",
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            subtitle: const Text("Estado: Pendiente",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExchangeDetailPage(requestId: index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ExchangeDetailPage extends StatefulWidget {
  final int requestId;

  const ExchangeDetailPage({super.key, required this.requestId});

  @override
  State<ExchangeDetailPage> createState() => _ExchangeDetailPageState();
}

class _ExchangeDetailPageState extends State<ExchangeDetailPage> {
  String? selectedBook;
  List<String> userBooks = []; // Lista de libros subidos por el usuario dueño
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserBooks();
  }

  Future<void> _fetchUserBooks() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('books')
          .select('title')
          .eq('owner_id', userId); // Obtiene libros del usuario dueño

      setState(() {
        userBooks = List<String>.from(
            response.map((book) => book['title'])); // Solo títulos
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar libros: $e')),
      );
    }
  }

  void _acceptExchange() {
    if (selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe seleccionar un libro.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Intercambio aceptado con el libro: $selectedBook")),
      );
      Navigator.pop(context); // Volver a la pantalla anterior
    }
  }

  void _rejectExchange() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Intercambio rechazado.")),
    );
    Navigator.pop(context); // Volver a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle de solicitud de intercambio",
          style: TextStyle(color: Colors.lightBlue),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: const NetworkImage(
                            "https://via.placeholder.com/150"),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Usuario Solicitante", // Debes reemplazar con el nombre real desde la BDD
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedBook,
                    decoration: const InputDecoration(
                      labelText: "Selecciona un libro",
                      border: OutlineInputBorder(),
                    ),
                    items: userBooks.map((book) {
                      return DropdownMenuItem<String>(
                        value: book,
                        child: Text(
                          book,
                          style: const TextStyle(color: Colors.lightBlue),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBook = value;
                      });
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _acceptExchange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.positiveGreen,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _rejectExchange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.negativeRed,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
