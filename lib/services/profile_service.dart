import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener el perfil de un usuario por su ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Perfil no encontrado');
      }

      return response; // Retornar directamente el perfil
    } catch (e) {
      print('Error al obtener el perfil: $e');
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  /// Cambiar la contraseña del usuario
  /// Cambiar la contraseña de un usuario
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final email = currentUser.email;

      if (email == null) {
        throw Exception("El correo del usuario no está disponible");
      }

      // Verificar la contraseña actual
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (authResponse.session == null) {
        throw Exception("La contraseña actual es incorrecta");
      }

      // Actualizar la contraseña
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception("No se pudo actualizar la contraseña");
      }
    } catch (e) {
      // Aquí no imprimimos errores, los manejamos lanzando excepciones controladas
      throw Exception("Error al cambiar la contraseña: ${e.toString()}");
    }
  }

  /// Actualizar la URL de la foto de perfil del usuario
  Future<void> updatePhotoUrl(String userId, String photoUrl) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({'photo_url': photoUrl}).eq('user_id', userId);

      print('Foto de perfil actualizada correctamente');
    } catch (e) {
      print('Error al actualizar la foto: $e');
      throw Exception('Error al actualizar la foto: $e');
    }
  }

  /// Subir una nueva foto y actualizar la URL en el perfil del usuario
  Future<String> uploadAndUpdatePhoto(String userId, String filePath) async {
    final fileName =
        'profile-$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      // Obtener el perfil del usuario para verificar la foto existente
      final userProfile = await getUserProfile(userId);
      final oldPhotoUrl = userProfile?['photo_url'];

      // Verificar y eliminar la foto previa si existe
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        final oldFileName = oldPhotoUrl.split('/').last;
        await deleteOldPhoto(oldFileName);
      }

      // Subir la nueva imagen al bucket
      final response = await _supabase.storage
          .from('profile-pictures')
          .upload(fileName, File(filePath));

      if (response.isEmpty) {
        throw Exception(
            'Error al subir la foto: No se obtuvo un identificador válido');
      }

      // Obtener la URL pública de la nueva imagen
      final publicUrl =
          _supabase.storage.from('profile-pictures').getPublicUrl(fileName);

      // Actualizar la URL en la base de datos
      await updatePhotoUrl(userId, publicUrl);

      print('Foto de perfil actualizada correctamente');
      return publicUrl; // Retornar la nueva URL pública
    } catch (e) {
      print('Error al actualizar la foto de perfil: $e');
      throw Exception('Error al actualizar la foto de perfil: $e');
    }
  }

  /// Eliminar la imagen antigua del bucket
  Future<void> deleteOldPhoto(String? fileName) async {
    if (fileName == null || fileName.isEmpty) {
      print('No hay foto anterior para eliminar.');
      return; // Salir si no hay foto previa
    }

    try {
      await _supabase.storage.from('profile-pictures').remove([fileName]);
      print('Imagen antigua eliminada correctamente');
    } catch (e) {
      print('Error al eliminar la imagen antigua: $e');
    }
  }

  /// Actualizar nombre y número de teléfono del usuario
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
  }) async {
    final updates = <String, dynamic>{};

    if (name != null && name.isNotEmpty) {
      updates['name'] = name;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      updates['phone_number'] = phoneNumber;
    }

    if (updates.isEmpty) {
      throw Exception('No hay datos para actualizar');
    }

    try {
      await _supabase
          .from('user_profiles')
          .update(updates)
          .eq('user_id', userId);

      print('Perfil actualizado correctamente');
    } catch (e) {
      print('Error al actualizar el perfil: $e');
      throw Exception('Error al actualizar el perfil: $e');
    }
  }
}
