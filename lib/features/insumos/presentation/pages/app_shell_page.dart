import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../custos/presentation/pages/custos_page.dart';
import '../../../receitas/presentation/cubit/receitas_cubit.dart';
import '../../../receitas/presentation/pages/receitas_page.dart';
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
    BlocProvider(
      create: (_) => sl<ReceitasCubit>(),
      child: const ReceitasPage(),
    ),
    const CustosPage(),
    const _PlaceholderPage(title: 'Vendas'),
    const _PlaceholderPage(title: 'Estoque'),
    const _PlaceholderPage(title: 'Simular'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
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
