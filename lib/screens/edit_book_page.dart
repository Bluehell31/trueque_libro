import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para usar FilteringTextInputFormatter
import '../services/book_service.dart';

class EditBookPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const EditBookPage({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _yearController = TextEditingController();
  int? selectedCategoryId;
  List<Map<String, dynamic>> categories = [];
  final BookService _bookService = BookService();
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController.text = widget.book['title'] ?? '';
    _descriptionController.text = widget.book['description'] ?? '';
    _authorController.text = widget.book['author'] ?? '';
    _yearController.text = widget.book['year']?.toString() ?? '';
    selectedCategoryId = widget.book['category_id'];
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await _bookService.getCategories();
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;

        if (!categories
            .any((category) => category['id'] == selectedCategoryId)) {
          selectedCategoryId =
              categories.isNotEmpty ? categories.first['id'] : null;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _bookService.updateBook(
          bookId: widget.book['id'],
          title: _titleController.text,
          description: _descriptionController.text,
          author: _authorController.text,
          year: int.parse(_yearController.text),
          categoryId: selectedCategoryId!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro actualizado correctamente')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el libro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Libro',
          style: TextStyle(color: Colors.lightBlue),
        ),
        backgroundColor: Colors.white, // Fondo blanco
        centerTitle: true,
        iconTheme:
            const IconThemeData(color: Colors.lightBlue), // Íconos lightBlue
        elevation: 0,
      ),
      backgroundColor: Colors.white, // Fondo blanco
      body: isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: 'Título del Libro'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el título del libro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(labelText: 'Autor(es)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el autor o autores';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                          labelText: 'Año de Publicación'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Solo números
                        LengthLimitingTextInputFormatter(4), // Máximo 4 dígitos
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) < 1990 ||
                            int.parse(value) > 2025) {
                          return 'Por favor, ingresa un año válido entre 1990 y 2025';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateBook,
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
