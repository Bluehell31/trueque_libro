import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueque_libro/screens/login_page.dart';
import 'package:trueque_libro/widgets/main_navigation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Muestra un indicador de carga mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Obtiene la sesión actual
        final session = Supabase.instance.client.auth.currentSession;

        // Redirige al usuario según el estado de autenticación
        if (session != null) {
          return const MainNavigation(); // Usuario autenticado
        } else {
          return const LoginPage(); // Usuario no autenticado
        }
      },
    );
  }
}
