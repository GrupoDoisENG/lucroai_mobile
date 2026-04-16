import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'insumos_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _currentIndex = 1;

  late final List<Widget> _pages = [
    const _PlaceholderPage(title: 'Home'),
    const InsumosPage(),
    const _PlaceholderPage(title: 'Receitas'),
    const _PlaceholderPage(title: 'Custos'),
    const _PlaceholderPage(title: 'Vendas'),
    const _PlaceholderPage(title: 'Estoque'),
    const _PlaceholderPage(title: 'Simular'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}