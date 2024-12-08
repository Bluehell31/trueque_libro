import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  //sign in
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Credenciales incorrectas o usuario no verificado.');
      }

      return true; // Indica éxito
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  //sign up
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String name,
    String phoneNumber,
    int institutionId,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        try {
          await _supabase.from('user_profiles').insert({
            'user_id': userId,
            'name': name,
            'phone_number': phoneNumber,
            'institution_id': institutionId,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          throw Exception('Error al crear el perfil del usuario: $e');
        }
      } else {
        throw Exception('No se pudo registrar el usuario.');
      }
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

// Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

//get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('No se pudo obtener el perfil del usuario: $e');
    }
  }
}
