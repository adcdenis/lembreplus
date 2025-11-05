import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembre+'),
      ),
      body: const Center(
        child: Text(
          'Lembre+',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}