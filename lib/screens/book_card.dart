import 'package:flutter/material.dart';
import 'package:trueque_libro/constants/colors.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onDetailsPressed;
  final VoidCallback onExchangePressed;

  const BookCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onDetailsPressed,
    required this.onExchangePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: onDetailsPressed,
                      child: const Text('Detalles',
                          style: TextStyle(color: AppColors.primaryColor)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz,
                          color: AppColors.actionButtonColor),
                      onPressed: onExchangePressed,
                      tooltip: 'Intercambiar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
