import 'package:flutter/material.dart';
import '../viewmodels/insumo_viewmodel.dart';
import '../models/insumo_model.dart'; // Necessário para instanciar um novo Insumo no modal

// --- TELA PRINCIPAL ---
class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});

  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  // Instanciando a ViewModel
  final InsumoViewModel _viewModel = InsumoViewModel();

  // Cores do layout
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    // Inicia a busca de dados assim que a tela é aberta
    _viewModel.buscarInsumos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Insumos",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Gerencie seus materiais e custos",
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Barra de Busca
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: textSecondary,
                    size: 20,
                  ),
                  hintText: "Buscar insumo...",
                  hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista Reativa (ListenableBuilder)
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  // 1. Estado: Carregando
                  if (_viewModel.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    );
                  }

                  // 2. Estado: Erro
                  if (_viewModel.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        _viewModel.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // 3. Estado: Lista Vazia
                  if (_viewModel.insumos.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhum insumo cadastrado.",
                        style: TextStyle(color: textSecondary),
                      ),
                    );
                  }

                  // 4. Estado: Sucesso (Monta a lista)
                  return ListView.builder(
                    itemCount: _viewModel.insumos.length,
                    itemBuilder: (context, index) {
                      final item = _viewModel.insumos[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Ícone do cubo
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1C18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: primaryOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Textos Centrais
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.detalheFormatado,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Custo e Lixeira
                            // Custo e Lixeira
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.custoUnitarioFormatado,
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Lixeira com ação de clique
                                GestureDetector(
                                  onTap: () {
                                    _viewModel.removerInsumo(item.id);

                                    // (Opcional) Mostra um aviso rápido na tela
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${item.nome} removido."),
                                        backgroundColor: cardDark,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: textSecondary,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Botão Flutuante
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryOrange,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            // Passamos a viewModel para o modal poder adicionar itens
            builder: (context) => NovoInsumoModal(viewModel: _viewModel),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // Barra de Navegação Inferior
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFF050505),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(
              Icons.grid_view,
              "Home",
              false,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.inventory_2_outlined,
              "Insumos",
              true,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.restaurant_menu,
              "Receitas",
              false,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.receipt_long,
              "Custos",
              false,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.show_chart,
              "Vendas",
              false,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.inventory,
              "Estoque",
              false,
              textSecondary,
              primaryOrange,
            ),
            _buildNavIcon(
              Icons.science_outlined,
              "Simular",
              false,
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
    bool isActive,
    Color inactiveColor,
    Color activeColor,
  ) {
    final color = isActive ? activeColor : inactiveColor;
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

// --- MODAL DE NOVO INSUMO ---
class NovoInsumoModal extends StatefulWidget {
  final InsumoViewModel viewModel;

  const NovoInsumoModal({super.key, required this.viewModel});

  @override
  State<NovoInsumoModal> createState() => _NovoInsumoModalState();
}

class _NovoInsumoModalState extends State<NovoInsumoModal> {
  // Controladores para capturar o texto digitado
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  String _unidadeSelecionada = 'g';

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _salvarInsumo() {
    // Validação básica
    if (_nomeController.text.isEmpty ||
        _quantidadeController.text.isEmpty ||
        _precoController.text.isEmpty)
      return;

    // Cria o objeto Insumo com os dados do form
    final novoInsumo = Insumo(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID provisório
      nome: _nomeController.text,
      quantidade: double.parse(_quantidadeController.text),
      unidade: _unidadeSelecionada,
      precoCusto: double.parse(_precoController.text.replaceAll(',', '.')),
    );

    // Chama o método da ViewModel para adicionar
    widget.viewModel.adicionarInsumo(novoInsumo);

    // Fecha o modal
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color cardDark = Color(0xFF151515);
    const Color inputDark = Color(0xFF1E1E1E);
    const Color primaryOrange = Color(0xFFE85D33);
    const Color textSecondary = Color(0xFF888888);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Novo Insumo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // NOME DO INSUMO
            Container(
              decoration: BoxDecoration(
                color: inputDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryOrange, width: 1),
              ),
              child: TextField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Nome do insumo",
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // QUANTIDADE E UNIDADE
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Quantidade",
                        hintStyle: TextStyle(color: textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: inputDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _unidadeSelecionada,
                        dropdownColor: inputDark,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: textSecondary,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: <String>['g', 'Kg', 'ml', 'L', 'un'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _unidadeSelecionada = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PREÇO DE CUSTO
            Container(
              decoration: BoxDecoration(
                color: inputDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _precoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Preço de custo (R\$)",
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // BOTÃO ADICIONAR INSUMO
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _salvarInsumo, // Chama a função de salvar
                child: const Text(
                  "Adicionar Insumo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
