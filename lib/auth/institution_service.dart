import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getInstitutions() async {
    try {
      // Realiza la consulta a la tabla 'institutions' y ordena por 'name'
      final List<dynamic> data = await _supabase
          .from('institutions')
          .select('id, name')
          .order('name', ascending: true);

      // Convierte los datos a una lista de mapas
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      // Maneja cualquier error que ocurra durante la consulta
      throw Exception('Error al obtener instituciones: $e');
    }
  }
}
