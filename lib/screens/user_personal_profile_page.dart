import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueque_libro/constants/colors.dart';
import '../services/profile_service.dart';
import '../auth/auth_service.dart';
import 'change_password_page.dart'; // Nueva pantalla de cambio de contraseña
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPersonalProfilePage extends StatefulWidget {
  const UserPersonalProfilePage({super.key});

  @override
  _UserPersonalProfilePageState createState() =>
      _UserPersonalProfilePageState();
}

class _UserPersonalProfilePageState extends State<UserPersonalProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final profile = await ProfileService().getUserProfile(userId);

      if (mounted) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: $e')),
        );
      }
    }
  }

  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('Usuario no autenticado');
        }

        // Subir y actualizar la foto
        final photoUrl =
            await ProfileService().uploadAndUpdatePhoto(userId, image.path);

        if (mounted) {
          setState(() {
            userProfile?['photo_url'] =
                photoUrl; // Actualiza la UI con la nueva URL
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto actualizada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la foto: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Perfil de Usuario',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                bottom: const TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primaryColor,
                  tabs: [
                    Tab(text: 'Info de Cuenta'),
                    Tab(text: 'Términos y Condiciones'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildAccountInfoTab(),
                  _buildTermsTab(),
                ],
              ),
            ),
          );
  }

  Widget _buildAccountInfoTab() {
    final photoUrl = userProfile?['photo_url'] ??
        'https://ruta_de_imagen_default.com/default.png';
    final name = userProfile?['name'] ?? 'Nombre no disponible';
    final phoneNumber = userProfile?['phone_number'] ?? 'Número no disponible';
    final email = _authService.getCurrentUserEmail() ?? 'Correo no disponible';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _updatePhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Información Básica',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildUserInfoTile("Nombre", name),
          const Divider(),
          _buildUserInfoTile("Número de Teléfono", phoneNumber),
          const Divider(),
          _buildUserInfoTile("Correo Electrónico", email, isVerified: true),
          const Divider(),
          _buildPasswordTile(), // Nuevo campo para cambiar contraseña
        ],
      ),
    );
  }

  Widget _buildTermsTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Términos y Condiciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '* La aplicación está diseñada para el intercambio de libros.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            '* No se permite el intercambio de libros en mal estado.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoTile(String title, String subtitle,
      {bool isVerified = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: isVerified
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : null,
    );
  }

  Widget _buildPasswordTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Contraseña",
          style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            ),
          );
        },
        child: const Text("Cambiar"),
      ),
    );
  }
}
