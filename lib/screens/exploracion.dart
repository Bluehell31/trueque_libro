import 'package:flutter/material.dart';
import 'package:trueque_libro/constants/colors.dart';

class ExploreBooksPage extends StatelessWidget {
  const ExploreBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Libros"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por título o autor',
                fillColor: AppColors.lightGray,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Card(
                color: AppColors.lightGray,
                child: ListTile(
                  leading: const Icon(Icons.book, color: AppColors.darkGray),
                  title: Text("Libro $index",
                      style: const TextStyle(color: AppColors.darkGray)),
                  subtitle: Text("Autor $index",
                      style: const TextStyle(color: AppColors.darkGray)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue),
                    onPressed: () {},
                    child: const Text("Intercambiar"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
