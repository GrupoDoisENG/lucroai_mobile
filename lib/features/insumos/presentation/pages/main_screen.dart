// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'insumos_screen.dart';
import 'calculo_real_screen.dart';
// import 'receitas_screen.dart'; // Descomente quando criar a tela de receitas oficial

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceAtual = 1; // Começa na aba Insumos (índice 1)

  // Lista das telas reais do seu app. A ordem importa!
  final List<Widget> _telas = [
    const Center(child: Text("Home - Em breve", style: TextStyle(color: Colors.white))), // 0: Home
    const InsumosScreen(),                                                                 // 1: Insumos
    const Center(child: Text("Receitas - Em breve", style: TextStyle(color: Colors.white))), // 2: Receitas
    const CalculoRealScreen(),                                                             // 3: Custos
    const Center(child: Text("Vendas - Em breve", style: TextStyle(color: Colors.white))),   // 4: Vendas
    const Center(child: Text("Estoque - Em breve", style: TextStyle(color: Colors.white))),  // 5: Estoque
    const Center(child: Text("Simular - Em breve", style: TextStyle(color: Colors.white))),  // 6: Simular
  ];

  void _aoTocarNoMenu(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFE85D33);
    const Color textSecondary = Color(0xFF888888);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // IndexedStack mantém o estado das telas ao navegar
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      // O menu agora fica centralizado aqui, e não dentro de cada tela
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFF050505),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(Icons.grid_view, "Home", 0, textSecondary, primaryOrange),
            _buildNavIcon(Icons.inventory_2_outlined, "Insumos", 1, textSecondary, primaryOrange),
            _buildNavIcon(Icons.restaurant_menu, "Receitas", 2, textSecondary, primaryOrange),
            _buildNavIcon(Icons.calculate, "Custos", 3, textSecondary, primaryOrange),
            _buildNavIcon(Icons.show_chart, "Vendas", 4, textSecondary, primaryOrange),
            _buildNavIcon(Icons.inventory, "Estoque", 5, textSecondary, primaryOrange),
            _buildNavIcon(Icons.science_outlined, "Simular", 6, textSecondary, primaryOrange),
          ],
        ),
      ),
    );
  }

  // Widget do ícone que agora tem ação de clique
  Widget _buildNavIcon(IconData icon, String label, int index, Color inactiveColor, Color activeColor) {
    final bool isActive = _indiceAtual == index;
    final color = isActive ? activeColor : inactiveColor;
    
    return GestureDetector(
      onTap: () => _aoTocarNoMenu(index), // Altera a tela ao clicar
      behavior: HitTestBehavior.opaque, // Melhora a área de clique
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