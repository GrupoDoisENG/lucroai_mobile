import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/estoques/presentation/cubit/estoques_cubit.dart';
import '../../../features/estoques/presentation/pages/estoques_page.dart';
import '../../../features/gastos_indiretos/presentation/cubit/gastos_indiretos_cubit.dart';
import '../../../features/gastos_indiretos/presentation/pages/gastos_indiretos_page.dart';
import '../../../features/insumos/presentation/cubit/insumos_cubit.dart';
import '../../../features/insumos/presentation/pages/calculo_real_screen.dart';
import '../../../features/insumos/presentation/pages/insumos_page.dart';
import '../../../features/producoes/presentation/cubit/producoes_cubit.dart';
import '../../../features/producoes/presentation/pages/producoes_page.dart';
import '../../../features/receitas/presentation/cubit/receitas_cubit.dart';
import '../../../features/receitas/presentation/pages/receitas_page.dart';
import '../../../features/vendas/presentation/cubit/vendas_cubit.dart';
import '../../../features/vendas/presentation/pages/vendas_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceAtual = 0;

  void _aoTocarNoMenu(int index) {
    setState(() => _indiceAtual = index);
    _refreshTab(index);
  }

  void _refreshTab(int index) {
    switch (index) {
      case 0:
        context.read<VendasCubit>().carregarHistorico();
        context.read<ReceitasCubit>().loadReceitas(showLoader: false);
        context.read<EstoquesCubit>().loadEstoques();
      case 1:
        context.read<InsumosCubit>().loadInsumos(showLoader: false);
      case 2:
        context.read<ReceitasCubit>().loadReceitas(showLoader: false);
      case 3:
        context.read<InsumosCubit>().loadInsumos(showLoader: false);
        context.read<ReceitasCubit>().loadReceitas(showLoader: false);
      case 4:
        context.read<VendasCubit>().carregarHistorico();
      case 5:
        context.read<EstoquesCubit>().loadEstoques();
      case 6:
        context.read<ProducoesCubit>().loadInitial();
      case 7:
        context.read<GastosIndiretosCubit>().loadGastos();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE85D33);
    const textSecondary = Color(0xFF888888);
    final paginas = [
      DashboardPage(onNavigate: _aoTocarNoMenu),
      const InsumosPage(),
      const ReceitasPage(),
      const CalculoRealScreen(),
      VendasPage(onNavigate: _aoTocarNoMenu),
      const EstoquesPage(),
      const ProducoesPage(),
      const GastosIndiretosPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(index: _indiceAtual, children: paginas),
      bottomNavigationBar: Container(
        color: const Color(0xFF050505),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 65,
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
              Icons.precision_manufacturing_outlined,
              'Produção',
              6,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.receipt_long_outlined,
              'Gastos',
              7,
              textSecondary,
              primaryOrange,
            ),
              ],
            ),
          ),
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
