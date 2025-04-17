import 'package:flutter/material.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['T-Shirt', 'Pant', 'Dress', 'Jacket'];
    final icons = [Icons.emoji_people, Icons.checkroom, Icons.woman, Icons.blinds];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(categories.length, (index) {
        return Column(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFD5C1B1),
              child: Icon(icons[index], color: const Color(0xFF8C4C2F)),
            ),
            const SizedBox(height: 4),
            Text(categories[index],
                style: const TextStyle(color: Color(0xFF4E2A1E))),
          ],
        );
      }),
    );
  }
}
