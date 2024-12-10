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

  // Verificar si el usuario autenticado tiene libros insertados
  final userBooks = await Supabase.instance.client
      .from('books')
      .select('id')
      .eq('owner_id', fromUserId);

  if (userBooks.isEmpty) {
    throw Exception(
        'No puedes realizar un intercambio porque no tienes ningún libro registrado.');
  }

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

  // Evitar que el usuario solicite intercambio consigo mismo
  if (fromUserId == toUserId) {
    throw Exception(
        'No puedes enviar una solicitud de intercambio a ti mismo.');
  }

  try {
    // Intentar insertar la solicitud de intercambio
    final insertResponse =
        await Supabase.instance.client.from('exchanges').insert({
      'book_id': bookId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      // 'status' y 'requested_date' no se incluyen porque ya tienen valores por defecto
    }).select();

    if (insertResponse.isEmpty) {
      throw Exception('Error desconocido al enviar la solicitud.');
    }
  } on PostgrestException catch (e) {
    if (e.code == '23505') {
      // Código de error para violación de restricción única
      throw Exception(
          'Ya has enviado una solicitud pendiente para este libro.');
    } else {
      throw Exception('Error al enviar la solicitud: ${e.message}');
    }
  } catch (e) {
    throw Exception('Error inesperado: $e');
  }
}

/// Obtener el perfil del propietario del libro usando el `bookId`
Future<Map<String, dynamic>> getBookOwnerProfileByBookId(int bookId) async {
  // Paso 1: Obtener el `owner_id` del libro
  final bookResponse = await Supabase.instance.client
      .from('books')
      .select('owner_id')
      .eq('id', bookId)
      .maybeSingle();

  if (bookResponse == null || bookResponse['owner_id'] == null) {
    throw Exception(
        'Error al obtener el propietario del libro. El libro no existe o no tiene propietario.');
  }

  final ownerId = bookResponse['owner_id'];

  // Paso 2: Obtener el perfil del propietario con el `owner_id`
  return await getBookOwnerProfile(ownerId);
}

/// Obtener el perfil del dueño del libro
Future<Map<String, dynamic>> getBookOwnerProfile(String ownerId) async {
  final response = await Supabase.instance.client
      .from('user_profiles')
      .select(
          'name, photo_url, average_rating') // Usamos el campo calculado `average_rating`
      .eq('user_id', ownerId)
      .maybeSingle();

  if (response == null) {
    throw Exception(
        'Error al obtener la información del propietario del libro.');
  }

  return {
    'name': response['name'],
    'photo_url': response['photo_url'] ??
        'https://qhmgujujntvfbaapplwy.supabase.co/storage/v1/object/public/profile-pictures/default.png?t=2024-12-10T07%3A16%3A59.460Z',
    'rating': (response['average_rating'] as num?)?.toDouble() ??
        0.0, // Asegura que sea un double
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
    // Consulta combinada para obtener solicitudes, usuario y libros
    final response = await Supabase.instance.client
        .from('exchanges')
        .select('''
          id,
          book_id,
          requested_date,
          user_profiles!from_user_id (
            name,
            photo_url
          ),
          books!from_user_id (
            id,
            title,
            photo_url
          )
        ''')
        .eq('to_user_id', toUserId)
        .eq('status', 'Pendiente')
        .order('requested_date', ascending: false);

    if (response.isEmpty) {
      return [];
    }

    // Mapear y estructurar la respuesta
    return List<Map<String, dynamic>>.from(response).map((exchange) {
      final userProfile = exchange['user_profiles'] ?? {};
      final books = exchange['books'] ?? [];

      return {
        'exchange_id': exchange['id'],
        'book_id': exchange['book_id'],
        'requested_date': exchange['requested_date'],
        'from_user': {
          'name': userProfile['name'] ?? 'Nombre no disponible',
          'photo_url': userProfile['photo_url'] ??
              'https://ruta_de_imagen_default.com/default.png',
        },
        'user_books': List<Map<String, dynamic>>.from(books).map((book) {
          return {
            'id': book['id'],
            'title': book['title'],
            'photo_url': book['photo_url'] ??
                'https://ruta_de_imagen_default.com/book_default.png',
          };
        }).toList(),
      };
    }).toList();
  } catch (e) {
    throw Exception('Error al obtener los detalles de las solicitudes: $e');
  }
}

Future<void> rejectExchangeRequest(int exchangeId) async {
  try {
    final response = await Supabase.instance.client
        .from('exchanges')
        .update({'status': 'Rechazado'})
        .eq('id', exchangeId)
        .select(); // Asegúrate de usar select() para obtener la respuesta.

    if (response == null || response.isEmpty) {
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
    final response = await Supabase.instance.client
        .from('exchanges')
        .update({
          'status': 'Aceptado',
          'selected_book_id': selectedBookId,
          'confirmed_date': DateTime.now().toIso8601String(),
        })
        .eq('id', exchangeId)
        .select(); // Asegúrate de usar select() para obtener la respuesta.

    if (response == null || response.isEmpty) {
      throw Exception('Error al aceptar la solicitud de intercambio.');
    }
  } catch (e) {
    throw Exception('Error al procesar la aceptación: $e');
  }
}

//obtener usuario al que se le envio la solicitud
Future<Map<String, dynamic>> getFromUserDetails(String userId) async {
  final response = await Supabase.instance.client
      .from('user_profiles')
      .select('name, photo_url, average_rating')
      .eq('user_id', userId)
      .maybeSingle();

  if (response == null) {
    throw Exception('No se encontró información para el usuario.');
  }

  return {
    'name': response['name'],
    'photo_url': response['photo_url'] ?? 'https://default.url',
    'rating': response['average_rating'] ??
        0.0, // Usa el promedio calculado por el trigger
  };
}

//obtener
Future<List<Map<String, dynamic>>> getFromUserBooks(String userId) async {
  try {
    // Consulta para obtener los libros del usuario con el `userId` especificado
    final response = await Supabase.instance.client
        .from('books')
        .select('id, title, photo_url')
        .eq('owner_id', userId);

    // Validar si hay datos
    if (response.isEmpty) {
      return [];
    }

    // Mapear la respuesta a una lista de mapas
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw Exception('Error al obtener los libros del usuario: $e');
  }
}

/// Obtener los detalles de un libro por su ID
Future<Map<String, dynamic>> getBookDetailById(int bookId) async {
  final response = await Supabase.instance.client
      .from('books')
      .select('title, photo_url, description, owner_id')
      .eq('id', bookId)
      .maybeSingle();

  if (response == null) {
    throw Exception('No se encontraron detalles para el libro con ID $bookId.');
  }

  return {
    'title': response['title'] ?? 'Título no disponible',
    'photo_url':
        response['photo_url'] ?? 'https://ruta_default.com/book_default.png',
    'description': response['description'] ?? 'Sin descripción disponible',
    'owner_id':
        response['owner_id'], // Este puede ser útil para otras operaciones
  };
}
