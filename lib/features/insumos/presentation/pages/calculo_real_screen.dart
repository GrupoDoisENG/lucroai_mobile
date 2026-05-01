// lib/screens/calculo_real_screen.dart
import 'package:flutter/material.dart';
import '../../viewmodels/calculo_real_viewmodel.dart';
import '../../models/receita_resumo_model.dart';

class CalculoRealScreen extends StatefulWidget {
  const CalculoRealScreen({super.key});

  @override
  State<CalculoRealScreen> createState() => _CalculoRealScreenState();
}

class _CalculoRealScreenState extends State<CalculoRealScreen> {
  final CalculoRealViewModel _viewModel = CalculoRealViewModel();

  // Controladores para sincronizar o texto digitado
  final _rendimentoCtrl = TextEditingController();

  // Cores do protótipo
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color inputDark = const Color(0xFF1E1E1E);
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _atualizarControladores();
  }

  void _atualizarControladores() {
    _rendimentoCtrl.text = _viewModel.rendimento != null ? _viewModel.rendimento.toString() : "";
  }

  @override
  void dispose() {
    _rendimentoCtrl.dispose();
    super.dispose();
  }

  // Função auxiliar para converter vírgula em ponto no input brasileiro
  double? _parseBR(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cálculo Real", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Custo verdadeiro incluindo custos invisíveis", style: TextStyle(fontSize: 12, color: textSecondary)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          // Texto a ser exibido no card de Ingredientes
          String textoIngredientes = _viewModel.custoIngredientes != null 
              ? "R\$ ${_viewModel.custoIngredientes!.toStringAsFixed(2)}"
              : "Selecionar ou Digitar...";

          if (!_viewModel.isModoManual && _viewModel.receitaSelecionada != null) {
            textoIngredientes = "${_viewModel.receitaSelecionada!.nome} (R\$ ${_viewModel.custoIngredientes!.toStringAsFixed(2)})";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CARD PRINCIPAL: RESULTADO DO CÁLCULO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text("CUSTO POR UNIDADE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text("R\$ ${_viewModel.custoPorUnidade.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryOrange)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text("R\$ ${_viewModel.custoTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text("Custo Total", style: TextStyle(fontSize: 10, color: textSecondary)),
                            ],
                          ),
                          Container(height: 30, width: 1, color: Colors.white10),
                          Column(
                            children: [
                              Text("${_viewModel.percentualInvisivel.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFFB74D))),
                              Text("Custos Invisíveis", style: TextStyle(fontSize: 10, color: textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. CARD: CUSTO DOS INGREDIENTES (Seletor)
                _buildCard(
                  title: "CUSTO DOS INGREDIENTES",
                  icon: Icons.receipt_long,
                  child: GestureDetector(
                    onTap: () => _abrirModalReceitas(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: inputDark, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              textoIngredientes, 
                              style: TextStyle(color: _viewModel.custoIngredientes != null ? Colors.white : textSecondary, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. CARD: CUSTOS INVISÍVEIS
                _buildCard(
                  title: "CUSTOS INVISÍVEIS",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildInput("Energia", Icons.flash_on, _viewModel.energia?.toStringAsFixed(2), (v) => _viewModel.atualizarInvisiveis(e: _parseBR(v)))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput("Água", Icons.water_drop, _viewModel.agua?.toStringAsFixed(2), (v) => _viewModel.atualizarInvisiveis(a: _parseBR(v)))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInput("Gás", Icons.local_fire_department, _viewModel.gas?.toStringAsFixed(2), (v) => _viewModel.atualizarInvisiveis(g: _parseBR(v)))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput("Horas", Icons.schedule, _viewModel.horas?.toStringAsFixed(1), (v) => _viewModel.atualizarInvisiveis(h: _parseBR(v)))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Valor/hora mão de obra (R\$)", style: TextStyle(color: textSecondary, fontSize: 11)),
                      const SizedBox(height: 6),
                      _buildInputSemIcone(_viewModel.valorHora?.toStringAsFixed(2), (v) => _viewModel.atualizarInvisiveis(vh: _parseBR(v))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. CARD: RENDIMENTO
                _buildCard(
                  title: "RENDIMENTO (UNIDADES)",
                  child: TextField(
                    controller: _rendimentoCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => _viewModel.atualizarInvisiveis(r: int.tryParse(v)),
                    decoration: InputDecoration(
                      hintText: "Ex: 12",
                      hintStyle: TextStyle(color: textSecondary),
                      filled: true,
                      fillColor: inputDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- FUNÇÃO QUE ABRE O MODAL E TRATA O INPUT MANUAL ---
  void _abrirModalReceitas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalSelecaoReceita(
        aoSelecionarReceita: (receita) {
          _viewModel.selecionarReceita(receita);
          _atualizarControladores();
          Navigator.pop(context);
        },
        aoSelecionarManual: () {
          _viewModel.ativarModoManual();
          Navigator.pop(context);
          _abrirDialogoCustoManual(context); // Abre o input pra digitar o valor
        },
      ),
    );
  }

  // --- DIALOG PARA QUANDO ESCOLHER "DIGITAR CUSTO" ---
  void _abrirDialogoCustoManual(BuildContext context) {
    final TextEditingController manualCtrl = TextEditingController(
      text: _viewModel.custoIngredientes?.toStringAsFixed(2) ?? ""
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text("Custo Manual", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: manualCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Digite o custo total (R\$)",
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: inputDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
            onPressed: () {
              final valor = _parseBR(manualCtrl.text);
              if (valor != null) {
                _viewModel.atualizarCustoManual(valor);
              }
              Navigator.pop(context);
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildCard({required String title, IconData? icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: primaryOrange, size: 16), const SizedBox(width: 6)],
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, String? initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: textSecondary, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        _buildInputSemIcone(initialValue, onChanged),
      ],
    );
  }

  Widget _buildInputSemIcone(String? initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue ?? "",
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "0.00",
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
        filled: true,
        fillColor: inputDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 65,
      color: const Color(0xFF050505),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.grid_view, "Home", false),
          _navIcon(Icons.inventory_2_outlined, "Insumos", false),
          _navIcon(Icons.restaurant_menu, "Receitas", false),
          _navIcon(Icons.calculate, "Custos", true),
          _navIcon(Icons.show_chart, "Vendas", false),
          _navIcon(Icons.inventory, "Estoque", false),
          _navIcon(Icons.science_outlined, "Simular", false),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, bool isActive) {
    final color = isActive ? primaryOrange : textSecondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 9)),
      ],
    );
  }
}

// --- WIDGET DO MODAL DE SELEÇÃO ---
class ModalSelecaoReceita extends StatelessWidget {
  final Function(ReceitaResumo) aoSelecionarReceita;
  final VoidCallback aoSelecionarManual;

  const ModalSelecaoReceita({super.key, required this.aoSelecionarReceita, required this.aoSelecionarManual});

  @override
  Widget build(BuildContext context) {
    // 🔗 INTEGRAÇÃO BACKEND:
    // Aqui você listará as receitas buscando da API.
    final List<ReceitaResumo> receitasCadastradas = [
      ReceitaResumo(id: '1', nome: 'Bolo de Chocolate', custoIngredientes: 24.50, rendimento: 12),
      ReceitaResumo(id: '2', nome: 'Brigadeiro', custoIngredientes: 15.00, rendimento: 50),
    ];

    const Color modalBg = Color(0xFF151515);
    const Color btnDark = Color(0xFF1E1E1E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: modalBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOpcaoBotao("Digitar Custo", btnDark, aoSelecionarManual),
          const SizedBox(height: 20),
          
          const Text("Receitas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: receitasCadastradas.length,
              itemBuilder: (context, index) {
                final receita = receitasCadastradas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildOpcaoBotao(receita.nome, btnDark, () => aoSelecionarReceita(receita)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoBotao(String texto, Color cor, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}