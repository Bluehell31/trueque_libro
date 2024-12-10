import 'package:flutter/material.dart';
import 'package:trueque_libro/screens/home_page.dart';
import 'package:trueque_libro/screens/notificaciones.dart';
import 'package:trueque_libro/screens/user_personal_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // Página principal
    const UserPersonalProfilePage(), // Perfil del usuario
    const NotificationsPage(), // Notificaciones
  ];

  void _onItemTapped(int index) async {
    if (index == 3) {
      // Logout
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final user = Supabase.instance.client.auth.currentUser;

      // Verificar si el usuario está autenticado para acceder al perfil y notificaciones
      if (index != 0 && user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para acceder.')),
        );
        return;
      }

      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
