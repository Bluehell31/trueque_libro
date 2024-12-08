import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'book_images'; // Nombre del bucket correcto

  // Subir imagen de libro
  Future<String> uploadBookImage(File imageFile, String filePath) async {
    try {
      final response =
          await _supabase.storage.from(bucketName).upload(filePath, imageFile);

      if (response.isNotEmpty) {
        // Devuelve la URL pública de la imagen
        return _supabase.storage.from(bucketName).getPublicUrl(filePath);
      } else {
        throw Exception('Error al subir la imagen: Respuesta vacía.');
      }
    } catch (e) {
      throw Exception(
          'Error al subir la imagen: Verifica que el bucket "$bucketName" existe y es público. Detalles: $e');
    }
  }

  // Insertar un libro
  Future<void> insertBook({
    required String title,
    required String description,
    required String author,
    required int year,
    required int categoryId,
    required File imageFile,
  }) async {
    try {
      // Genera un filePath único para la imagen
      final String filePath =
          'book_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final imageUrl = await uploadBookImage(imageFile, filePath);

      // Datos a insertar
      final insertData = {
        'title': title,
        'description': description,
        'author': author,
        'year': year,
        'category_id': categoryId,
        'photo_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'owner_id': _supabase
            .auth.currentUser!.id, // Incluye el ID del usuario autenticado
      };

      // Realiza la inserción en la base de datos
      final response =
          await _supabase.from('books').insert(insertData).select();

      if (response.isEmpty) {
        throw Exception('Error al insertar el libro: Respuesta vacía.');
      }
    } catch (e) {
      throw Exception('Error al insertar el libro: $e');
    }
  }

  // Actualizar libro
  Future<void> updateBook({
    required int bookId,
    required String title,
    required String description,
    required String author,
    required int year,
    required int categoryId,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Si hay una nueva imagen, súbela al bucket
      if (imageFile != null) {
        final String filePath =
            'book_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        imageUrl = await uploadBookImage(imageFile, filePath);
      }

      // Datos a actualizar
      final updateData = {
        'title': title,
        'description': description,
        'author': author,
        'year': year,
        'category_id': categoryId,
        if (imageUrl != null) 'photo_url': imageUrl,
      };

      // Realiza la actualización
      final response = await _supabase
          .from('books')
          .update(updateData)
          .eq('id', bookId)
          .select();

      if (response.isEmpty) {
        throw Exception('Error al actualizar el libro: Respuesta vacía.');
      }
    } catch (e) {
      throw Exception('Error al actualizar el libro: $e');
    }
  }

  // Obtener categorías
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }
}
