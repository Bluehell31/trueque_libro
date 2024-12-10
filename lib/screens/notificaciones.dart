import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import 'notification_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<Map<String, dynamic>>> _fetchPendingRequests() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    return await getPendingRequests(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitudes de Intercambio',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future:
            _fetchPendingRequests(), // Llama al futuro cada vez que se reconstruye el widget
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tienes solicitudes pendientes.'),
            );
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                child: ListTile(
                  title: Text('Solicitud ${request['id']}'),
                  subtitle: Text('Estado: Pendiente'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          exchangeId: request['id'],
                          bookId: request['book_id'],
                          fromUserId: request['from_user_id'],
                          requestedDate: request['requested_date'],
                        ),
                      ),
                    ).then((_) {
                      // Actualiza la lista cuando se regrese de la página de detalles
                      setState(() {});
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
