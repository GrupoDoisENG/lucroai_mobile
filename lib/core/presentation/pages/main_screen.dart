import 'package:flutter/material.dart';

// Importando as páginas
import '../../../features/insumos/presentation/pages/insumos_page.dart';
import '../../../features/estoques/presentation/pages/estoques_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Começamos no índice 1, que é a aba de Insumos
  int _indiceAtual = 1;

  // A lista de páginas. O IndexedStack vai exibir a página 
  // correspondente ao número do _indiceAtual.
  final List<Widget> _paginas = [
    const Center(child: Text("Home - Em breve", style: TextStyle(color: Colors.white))),             // Índice 0
    const InsumosPage(),                                                                             // Índice 1 (A sua tela real!)
    const Center(child: Text("Receitas - Em breve", style: TextStyle(color: Colors.white))),         // Índice 2
    const Center(child: Text("Cálculo Real - Em breve", style: TextStyle(color: Colors.white))),     // Índice 3
    const Center(child: Text("Vendas - Em breve", style: TextStyle(color: Colors.white))),           // Índice 4
    const EstoquesPage(),                                                                             // Índice 5
    const Center(child: Text("Simular - Em breve", style: TextStyle(color: Colors.white))),          // Índice 6
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
      // O IndexedStack mantém o estado de todas as telas vivo, 
      // mas só exibe a que está selecionada no menu.
      body: IndexedStack(
        index: _indiceAtual,
        children: _paginas,
      ),
      // Barra de navegação inferior fixa
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

  // Construtor dos botões do menu inferior
  Widget _buildNavIcon(IconData icon, String label, int index, Color inactiveColor, Color activeColor) {
    final bool isActive = _indiceAtual == index;
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