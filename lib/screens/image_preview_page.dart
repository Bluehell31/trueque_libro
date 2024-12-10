import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vista previa de la imagen',
          style: TextStyle(color: Colors.lightBlue), // Letras lightBlue
        ),
        backgroundColor: Colors.white, // Fondo blanco
        iconTheme:
            const IconThemeData(color: Colors.lightBlue), // Iconos lightBlue
        elevation: 0, // Sin sombra
      ),
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: Hero(
          tag: 'bookImage',
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
