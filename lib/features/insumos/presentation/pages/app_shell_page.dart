import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../custos/presentation/pages/custos_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../estoques/presentation/cubit/estoques_cubit.dart';
import '../../../estoques/presentation/pages/estoques_page.dart';
import '../../../receitas/presentation/cubit/receitas_cubit.dart';
import '../../../receitas/presentation/pages/receitas_page.dart';
import '../../../simulacao/presentation/pages/simulacao_page.dart';
import '../../../vendas/presentation/cubit/vendas_cubit.dart';
import '../../../vendas/presentation/pages/vendas_page.dart';
import '../cubit/insumos_cubit.dart';
import '../widgets/app_bottom_nav.dart';
import 'insumos_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReceitasCubit>()),
        BlocProvider(create: (_) => sl<VendasCubit>()),
        BlocProvider(create: (_) => sl<EstoquesCubit>()),
      ],
      child: DashboardPage(onNavigate: _setCurrentIndex),
    ),
    const InsumosPage(),
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReceitasCubit>()),
        BlocProvider(create: (_) => sl<InsumosCubit>()),
      ],
      child: const ReceitasPage(),
    ),
    const CustosPage(),
    BlocProvider(
      create: (_) => sl<VendasCubit>(),
      child: VendasPage(onNavigate: _setCurrentIndex),
    ),
    BlocProvider(
      create: (_) => sl<EstoquesCubit>(),
      child: const EstoquesPage(),
    ),
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReceitasCubit>()),
        BlocProvider(create: (_) => sl<VendasCubit>()),
      ],
      child: SimulacaoPage(onNavigate: _setCurrentIndex),
    ),
  ];

  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _setCurrentIndex,
      ),
    );
  }
}
