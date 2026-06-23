import 'package:flutter/material.dart';

import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/estoques/presentation/pages/estoques_page.dart';
import '../../../features/gastos_indiretos/presentation/pages/gastos_indiretos_page.dart';
import '../../../features/insumos/presentation/pages/insumos_page.dart';
import '../../../features/receitas/presentation/pages/receitas_page.dart';
import '../../../features/simulacao/presentation/pages/simulacao_page.dart';
import '../../../features/vendas/presentation/pages/vendas_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceAtual = 0;

  void _aoTocarNoMenu(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE85D33);
    const textSecondary = Color(0xFF888888);
    final paginas = [
      DashboardPage(onNavigate: _aoTocarNoMenu),
      const InsumosPage(),
      const ReceitasPage(),
      const GastosIndiretosPage(),
      const VendasPage(),
      const EstoquesPage(),
      const SimulacaoPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(index: _indiceAtual, children: paginas),
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFF050505),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(
              Icons.grid_view,
              'Home',
              0,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.inventory_2_outlined,
              'Insumos',
              1,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.restaurant_menu,
              'Receitas',
              2,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.calculate,
              'Custos',
              3,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.show_chart,
              'Vendas',
              4,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.inventory,
              'Estoque',
              5,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.science_outlined,
              'Simular',
              6,
              textSecondary,
              primaryOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    IconData icon,
    String label,
    int index,
    Color inactiveColor,
    Color activeColor,
  ) {
    final isActive = _indiceAtual == index;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _aoTocarNoMenu(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 9)),
        ],
      ),
    );
  }
}
