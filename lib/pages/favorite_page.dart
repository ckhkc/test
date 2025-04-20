import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contact_mail, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          const Text('Contact Us', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 24),
          const Text('Email: contact@example.com'),
          const SizedBox(height: 8),
          const Text('Phone: (123) 456-7890'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Send Message')),
        ],
      ),
    );
  }
}
