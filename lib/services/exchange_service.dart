import 'package:supabase_flutter/supabase_flutter.dart';

/// Enviar una solicitud de intercambio
/*Future<void> sendExchangeRequest({
  required int bookId,
}) async {
  final fromUserId = Supabase.instance.client.auth.currentUser!.id;

  // Obtener el propietario del libro seleccionado
  final response = await Supabase.instance.client
      .from('books')
      .select('owner_id')
      .eq('id', bookId)
      .maybeSingle();

  // Validar si `response` tiene datos
  if (response == null || response['owner_id'] == null) {
    throw Exception(
        'Error al obtener el propietario del libro. El libro no existe o no tiene propietario.');
  }

  final toUserId = response['owner_id'];

  // Insertar la solicitud de intercambio
  final insertResponse = await Supabase.instance.client
      .from('exchanges')
      .insert({
        'book_id': bookId,
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'status': 'Pendiente',
        'requested_date': DateTime.now().toIso8601String(),
      })
      .select(); // Esto devuelve los datos insertados.

  // Validar si hubo un error en la inserción
  if (insertResponse.isEmpty) {
    throw Exception('Error al enviar la solicitud de intercambio.');
  }
}*/
/// Enviar una solicitud de intercambio
Future<void> sendExchangeRequest({
  required int bookId,
}) async {
  // Obtener el ID del usuario autenticado
  final fromUserId = Supabase.instance.client.auth.currentUser!.id;

  // Obtener el propietario del libro seleccionado
  final bookResponse = await Supabase.instance.client
      .from('books')
      .select('owner_id')
      .eq('id', bookId)
      .maybeSingle();

  if (bookResponse == null || bookResponse['owner_id'] == null) {
    throw Exception(
        'Error al obtener el propietario del libro. El libro no existe o no tiene propietario.');
  }

  final toUserId = bookResponse['owner_id'];

  // Insertar la solicitud de intercambio
  final insertResponse =
      await Supabase.instance.client.from('exchanges').insert({
    'book_id': bookId,
    'from_user_id': fromUserId,
    'to_user_id': toUserId,
    // 'status' y 'requested_date' no se incluyen porque ya tienen valores por defecto
  }).select(); // Esto devuelve los datos insertados.

  if (insertResponse.isEmpty) {
    throw Exception('Error al enviar la solicitud de intercambio.');
  }
  if (fromUserId == toUserId) {
    throw Exception(
        'No puedes enviar una solicitud de intercambio a ti mismo.');
  }
}

/// Obtener el perfil del dueño del libro
Future<Map<String, dynamic>> getBookOwnerProfile(String ownerId) async {
  final response = await Supabase.instance.client
      .from('user_profiles')
      .select('name, photo_url, user_reviews(stars)')
      .eq('user_id', ownerId)
      .maybeSingle();

  if (response == null) {
    throw Exception(
        'Error al obtener la información del propietario del libro.');
  }

  // Calcular la calificación promedio
  final reviews = response['user_reviews'] as List<dynamic>? ?? [];
  double averageRating = 0.0;

  if (reviews.isNotEmpty) {
    averageRating = reviews
            .map((review) => review['stars'] as double)
            .reduce((a, b) => a + b) /
        reviews.length;
  }

  return {
    'name': response['name'],
    'photo_url': response['photo_url'] ??
        'https://ruta_de_imagen_default.com/default.png',
    'rating': averageRating,
  };
}

/// Obtener solicitudes pendientes
Future<List<Map<String, dynamic>>> getPendingRequests(String toUserId) async {
  final response = await Supabase.instance.client
      .from('exchanges')
      .select('id, book_id, from_user_id, requested_date')
      .eq('to_user_id', toUserId)
      .eq('status', 'Pendiente')
      .order('requested_date', ascending: false);

  // Validar si hay datos
  if (response.isEmpty) {
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
}

Future<List<Map<String, dynamic>>> getRequestDetails(String toUserId) async {
  try {
    // 1. Obtener solicitudes pendientes
    final exchangeResponse = await Supabase.instance.client
        .from('exchanges')
        .select('''
          id,
          book_id,
          requested_date,
          user_profiles!from_user_id (
            name,
            photo_url
          )
        ''')
        .eq('to_user_id', toUserId)
        .eq('status', 'Pendiente')
        .order('requested_date', ascending: false);

    if (exchangeResponse.isEmpty) {
      return [];
    }

    // 2. Mapear solicitudes y obtener libros por separado
    final List<Map<String, dynamic>> requests = [];
    for (final exchange in exchangeResponse) {
      // Información básica del intercambio
      final userProfile = exchange['user_profiles'] ?? {};
      final fromUserId = exchange['from_user_id'];

      // 3. Obtener libros del usuario (consulta independiente)
      final bookResponse = await Supabase.instance.client
          .from('books')
          .select('id, title, photo_url')
          .eq('owner_id', fromUserId);

      final userBooks = bookResponse.isNotEmpty
          ? List<Map<String, dynamic>>.from(bookResponse)
          : [];

      // 4. Agregar la solicitud completa a la lista
      requests.add({
        'exchange_id': exchange['id'],
        'book_id': exchange['book_id'],
        'requested_date': exchange['requested_date'],
        'from_user': {
          'name': userProfile['name'] ?? 'Nombre no disponible',
          'photo_url': userProfile['photo_url'] ??
              'https://ruta_de_imagen_default.com/default.png',
        },
        'user_books': userBooks,
      });
    }

    return requests;
  } catch (e) {
    throw Exception('Error al obtener los detalles de las solicitudes: $e');
  }
}

Future<void> rejectExchangeRequest(int exchangeId) async {
  try {
    final response = await Supabase.instance.client
        .from('exchanges')
        .update({'status': 'Rechazado'}).eq('id', exchangeId);

    if (response.isEmpty) {
      throw Exception('Error al rechazar la solicitud de intercambio.');
    }
  } catch (e) {
    throw Exception('Error al procesar el rechazo: $e');
  }
}

Future<void> acceptExchangeRequest({
  required int exchangeId,
  required int selectedBookId,
}) async {
  try {
    final response = await Supabase.instance.client.from('exchanges').update({
      'status': 'Aceptado',
      'selected_book_id': selectedBookId,
      'confirmed_date': DateTime.now().toIso8601String(),
    }).eq('id', exchangeId);

    if (response.isEmpty) {
      throw Exception('Error al aceptar la solicitud de intercambio.');
    }
  } catch (e) {
    throw Exception('Error al procesar la aceptación: $e');
  }
}
