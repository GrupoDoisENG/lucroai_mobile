import 'package:flutter/material.dart';

class ReceitaFormPage extends StatelessWidget {
  const ReceitaFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Receita'),
      ),
      body: const Center(
        child: Text(
          'Tela antiga desativada.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
