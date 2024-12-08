import 'package:flutter/material.dart';
import 'package:trueque_libro/auth/auth_gate.dart';
import 'package:trueque_libro/screens/login_page.dart';
import 'package:trueque_libro/screens/register_page.dart';
import 'package:trueque_libro/screens/notificaciones.dart';
import 'package:trueque_libro/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueque_libro/screens/user_personal_profile_page.dart';
import 'package:trueque_libro/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://qhmgujujntvfbaapplwy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFobWd1anVqbnR2ZmJhYXBwbHd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI1OTY1MTUsImV4cCI6MjA0ODE3MjUxNX0.cP1PdSEEr9lY4JjJm9SMeAAGJLgd390aHArypapIoe0",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trueque de Libros',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          surface: AppColors.backgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 255, 245, 104),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textColor),
          bodyMedium: TextStyle(color: AppColors.textColor),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.actionButtonColor,
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainNavigation(),
        '/notificaciones': (context) => const NotificationsPage(),
        '/perfil': (context) => const UserPersonalProfilePage(),
      },
    );
  }
}
