import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_book_page.dart';

class PersonalBooksPage extends StatefulWidget {
  const PersonalBooksPage({super.key});

  @override
  _PersonalBooksPageState createState() => _PersonalBooksPageState();
}

class _PersonalBooksPageState extends State<PersonalBooksPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> userBooks = [];
  bool isLoading = true;
  bool isSelecting = false;
  Set<int> selectedBooks = {};

  @override
  void initState() {
    super.initState();
    _fetchUserBooks();
  }

  Future<void> _fetchUserBooks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response =
          await _supabase.from('books').select('*').eq('owner_id', user.id);

      setState(() {
        userBooks = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los libros: $e')),
      );
    }
  }

  Future<void> _deleteSelectedBooks() async {
    try {
      for (int bookId in selectedBooks) {
        await _supabase.from('books').delete().eq('id', bookId);
      }

      setState(() {
        userBooks.removeWhere((book) => selectedBooks.contains(book['id']));
        selectedBooks.clear();
        isSelecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libros eliminados exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar los libros: $e')),
      );
    }
  }

  void _editBook(Map<String, dynamic> book) async {
    final updatedBook = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookPage(book: book),
      ),
    );

    if (updatedBook != null && updatedBook is Map<String, dynamic>) {
      setState(() {
        final index = userBooks.indexWhere((b) => b['id'] == book['id']);
        if (index != -1) {
          userBooks[index] = updatedBook;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mis Libros',
          style: TextStyle(color: Colors.lightBlue),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
        elevation: 0,
        leading: isSelecting
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: selectedBooks.isEmpty
                    ? null
                    : () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text(
                                '¿Estás seguro de que deseas eliminar los libros seleccionados?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          _deleteSelectedBooks();
                        }
                      },
              )
            : null,
        actions: [
          if (isSelecting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSelecting = false;
                  selectedBooks.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  isSelecting = true;
                });
              },
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userBooks.isEmpty
              ? const Center(
                  child: Text(
                    'No has añadido ningún libro.',
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: userBooks.length,
                  itemBuilder: (context, index) {
                    final book = userBooks[index];
                    final imageUrl =
                        book['photo_url'] ?? 'https://via.placeholder.com/150';

                    final isSelected = selectedBooks.contains(book['id'] ?? 0);

                    return GestureDetector(
                      onTap: isSelecting
                          ? () {
                              setState(() {
                                final bookId = book['id'] as int;
                                if (isSelected) {
                                  selectedBooks.remove(bookId);
                                } else {
                                  selectedBooks.add(bookId);
                                }
                              });
                            }
                          : () => _editBook(book),
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            color: isSelected
                                ? Colors.lightBlue[50]
                                : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    book['title'] ?? 'Título no disponible',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelecting)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    final bookId = book['id'] as int;
                                    if (value == true) {
                                      selectedBooks.add(bookId);
                                    } else {
                                      selectedBooks.remove(bookId);
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
