import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueque_libro/constants/colors.dart';
import '../services/profile_service.dart';
import '../auth/auth_service.dart';
import 'change_password_page.dart';
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

        final photoUrl =
            await ProfileService().uploadAndUpdatePhoto(userId, image.path);

        if (mounted) {
          setState(() {
            userProfile?['photo_url'] = photoUrl;
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
        : Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text(
                'Perfil de Usuario',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildAccountInfoCard(),
                ],
              ),
            ),
          );
  }

  Widget _buildProfileHeader() {
    final photoUrl = userProfile?['photo_url'] ??
        'https://ruta_de_imagen_default.com/default.png';

    return Center(
      child: GestureDetector(
        onTap: _updatePhoto,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(photoUrl),
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, size: 20, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    final name = userProfile?['name'] ?? 'Nombre no disponible';
    final phoneNumber = userProfile?['phone_number'] ?? 'Número no disponible';
    final email = _authService.getCurrentUserEmail() ?? 'Correo no disponible';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildUserInfoTile("Nombre", name),
            const Divider(),
            _buildUserInfoTile("Número de Teléfono", phoneNumber),
            const Divider(),
            _buildUserInfoTile("Correo Electrónico", email, isVerified: true),
            const Divider(),
            _buildPasswordTile(),
          ],
        ),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            ),
          );
        },
        child: const Text(
          "Cambiar",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
