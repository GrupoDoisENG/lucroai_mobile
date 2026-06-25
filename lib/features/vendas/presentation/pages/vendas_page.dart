import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receitas/domain/entities/receita.dart';
import '../../domain/entities/venda.dart';
import '../cubit/vendas_cubit.dart';
import '../cubit/vendas_state.dart';
import '../widgets/venda_card.dart';
import '../widgets/venda_summary_card.dart';

class VendasPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const VendasPage({super.key, this.onNavigate});

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  Receita? _receitaSelecionada;

  final List<ItemCarrinho> _carrinho = [];

  @override
  void initState() {
    super.initState();
    _quantidadeController.addListener(_refresh);
    _precoController.addListener(_refresh);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<VendasCubit>();
      if (cubit.state.status == VendasStatus.initial) {
        cubit.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _quantidadeController.removeListener(_refresh);
    _precoController.removeListener(_refresh);
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  double get _quantidade => _parseDouble(_quantidadeController.text);
  double get _precoUnitario => _parseDouble(_precoController.text);

  double get _totalCarrinho =>
      _carrinho.fold(0, (sum, item) => sum + item.subtotal);

  void _onReceitaChanged(Receita? receita) {
    setState(() {
      _receitaSelecionada = receita;
      if (receita?.precoSugerido != null && receita!.precoSugerido! > 0) {
        _precoController.text = receita.precoSugerido!
            .toStringAsFixed(2)
            .replaceAll('.', ',');
      } else {
        _precoController.clear();
      }
    });
  }

  void _adicionarAoCarrinho() {
    if (!_formKey.currentState!.validate() || _receitaSelecionada == null) {
      return;
    }

    setState(() {
      _carrinho.add(
        ItemCarrinho(
          receita: _receitaSelecionada!,
          quantidade: _quantidade,
          precoUnitario: _precoUnitario,
        ),
      );
      _formKey.currentState!.reset();
      _quantidadeController.clear();
      _precoController.clear();
      _receitaSelecionada = null;
    });
  }

  void _removerItem(int index) {
    setState(() => _carrinho.removeAt(index));
  }

  Future<void> _registrarVenda(BuildContext context) async {
    if (_carrinho.isEmpty) return;

    final cubit = context.read<VendasCubit>();
    final itensCopy = List<ItemCarrinho>.from(_carrinho);
    final venda = await cubit.registrarVenda(itensCopy);

    if (!mounted) return;

    if (venda != null) {
      setState(() => _carrinho.clear());
      // ignore: use_build_context_synchronously
      await _showConfirmacaoSheet(context, venda);
    }
  }

  Future<void> _showConfirmacaoSheet(BuildContext context, Venda venda) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConfirmacaoSheet(
        venda: venda,
        cubit: context.read<VendasCubit>(),
        onFinalizado: (mensagem) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1B1B1B),
              content: Text(
                mensagem,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: BlocConsumer<VendasCubit, VendasState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.errorMessage!.trim().isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1B1B1B),
                  content: Text(
                    _friendlyError(state.errorMessage!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  action: _isStockError(state.errorMessage!)
                      ? SnackBarAction(
                          label: 'Produção',
                          textColor: const Color(0xFFFF6B3D),
                          onPressed: () => widget.onNavigate?.call(6),
                        )
                      : null,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Text(
                      'Vendas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 14),
                    child: Text(
                      'Registre vendas e acompanhe o histórico',
                      style: TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: TabBar(
                      indicatorColor: Color(0xFFFF6B3D),
                      labelColor: Color(0xFFFF6B3D),
                      unselectedLabelColor: Color(0xFF858585),
                      tabs: [
                        Tab(text: 'Registrar'),
                        Tab(text: 'Historico'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRegistro(context, state),
                        _buildHistorico(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegistro(BuildContext context, VendasState state) {
    if (state.status == VendasStatus.loading && state.receitas.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B3D)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        _buildAddItemForm(state.receitas, state.isSubmitting),
        if (_carrinho.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildCarrinho(state.isSubmitting),
        ],
      ],
    );
  }

  Widget _buildAddItemForm(List<Receita> receitas, bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar produto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildReceitaDropdown(receitas),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    controller: _quantidadeController,
                    label: 'Quantidade',
                    validator: (v) =>
                        _validatePositiveNumber(v, 'Informe a quantidade'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInput(
                    controller: _precoController,
                    label: 'Preço unitário real',
                    validator: (value) =>
                        _validatePositiveNumber(value, 'Informe o preço'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : _adicionarAoCarrinho,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B3D),
                  side: const BorderSide(color: Color(0xFFFF6B3D)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar ao carrinho'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrinho(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Carrinho',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_carrinho.length} ${_carrinho.length == 1 ? 'item' : 'itens'}',
                style: const TextStyle(
                  color: Color(0xFF858585),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_carrinho.length, (i) {
            final item = _carrinho[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.receita.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatQty(item.quantidade)} × ${_formatCurrency(item.precoUnitario)}',
                          style: const TextStyle(
                            color: Color(0xFF858585),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(item.subtotal),
                    style: const TextStyle(
                      color: Color(0xFFFF6B3D),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: isSubmitting ? null : () => _removerItem(i),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF858585),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Color(0xFF1E1E1E), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatCurrency(_totalCarrinho),
                style: const TextStyle(
                  color: Color(0xFFFF6B3D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () => _registrarVenda(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B3D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF4A2A21),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Registrar Venda',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorico(BuildContext context, VendasState state) {
    final receitaNomeById = {
      for (final receita in state.receitas) receita.id: receita.nome,
    };

    return RefreshIndicator(
      color: const Color(0xFFFF6B3D),
      backgroundColor: const Color(0xFF111111),
      onRefresh: () => context.read<VendasCubit>().carregarHistorico(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: _DateFilterButton(
                  label: 'Data inicial',
                  value: state.dataInicio,
                  onTap: () => _selectDate(
                    context,
                    initialDate: state.dataInicio,
                    onSelected: (date) {
                      context.read<VendasCubit>().atualizarPeriodo(
                        dataInicio: date,
                        dataFim: state.dataFim,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateFilterButton(
                  label: 'Data final',
                  value: state.dataFim,
                  onTap: () => _selectDate(
                    context,
                    initialDate: state.dataFim,
                    onSelected: (date) {
                      context.read<VendasCubit>().atualizarPeriodo(
                        dataInicio: state.dataInicio,
                        dataFim: date,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          VendaSummaryCard(resumo: state.resumo),
          const SizedBox(height: 16),
          if (state.status == VendasStatus.loading && state.vendas.isEmpty) ...[
            const SizedBox(height: 80),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B3D)),
            ),
          ] else if (state.status == VendasStatus.error &&
              state.vendas.isEmpty) ...[
            const SizedBox(height: 80),
            Center(
              child: Text(
                _friendlyError(
                  state.errorMessage ?? 'Não foi possível carregar as vendas.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ] else if (state.vendas.isEmpty) ...[
            const SizedBox(height: 80),
            const Center(
              child: Text(
                'Nenhuma venda encontrada no período.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ] else ...[
            ...state.vendas.map(
              (venda) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VendaCard(
                  venda: venda,
                  produtoNome: _resolveProdutoNome(venda, receitaNomeById),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _resolveProdutoNome(Venda venda, Map<int, String> receitaNomeById) {
    if (venda.produto.trim().isNotEmpty && venda.produto != 'Venda') {
      return venda.produto;
    }

    if (venda.itens.isEmpty) return null;

    return venda.itens
        .map((item) {
          if (item.produto.trim().isNotEmpty) return item.produto;
          return receitaNomeById[item.receitaId] ?? '';
        })
        .where((nome) => nome.trim().isNotEmpty)
        .join(', ');
  }

  Widget _buildReceitaDropdown(List<Receita> receitas) {
    return DropdownButtonFormField<Receita>(
      initialValue: receitas.contains(_receitaSelecionada)
          ? _receitaSelecionada
          : null,
      onChanged: _onReceitaChanged,
      validator: (value) {
        if (value == null) return 'Selecione um produto';
        return null;
      },
      dropdownColor: const Color(0xFF171717),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFFFF6B3D),
      decoration: _inputDecoration('Produto/Receita'),
      items: receitas
          .map(
            (receita) => DropdownMenuItem<Receita>(
              value: receita,
              child: Text(receita.nome, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
      filled: true,
      fillColor: const Color(0xFF171717),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF272727)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF272727)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B3D)),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B3D),
              surface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  String? _validatePositiveNumber(String? value, String message) {
    final parsed = _parseDouble(value ?? '');
    if (parsed <= 0) return message;
    return null;
  }

  double _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return 'R\$ ${parts[0]},${parts[1]}';
  }

  String _formatQty(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _friendlyError(String error) {
    if (error.contains('401') || error.toLowerCase().contains('unauthorized')) {
      return 'Sessão expirada. Faça login novamente.';
    }

    if (_isStockError(error)) {
      return 'Estoque insuficiente para registrar a venda. Cadastre a produção do item em Produções.';
    }
    return error.replaceFirst('Exception: ', '');
  }

  bool _isStockError(String error) {
    final normalized = error
        .toLowerCase()
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ã', 'a')
        .replaceAll('ç', 'c');

    return normalized.contains('estoque') &&
        (normalized.contains('insuficiente') ||
            normalized.contains('indisponivel') ||
            normalized.contains('nao ha') ||
            normalized.contains('sem estoque'));
  }
}

// ─── Confirmation bottom sheet ───────────────────────────────────────────────

class _ConfirmacaoSheet extends StatefulWidget {
  final Venda venda;
  final VendasCubit cubit;
  final void Function(String mensagem) onFinalizado;

  const _ConfirmacaoSheet({
    required this.venda,
    required this.cubit,
    required this.onFinalizado,
  });

  @override
  State<_ConfirmacaoSheet> createState() => _ConfirmacaoSheetState();
}

class _ConfirmacaoSheetState extends State<_ConfirmacaoSheet> {
  bool _loading = false;

  Future<void> _concluirComValidacao() async {
    setState(() => _loading = true);
    final erro = await widget.cubit.verificarEstoqueParaVenda(widget.venda);
    if (!mounted) return;

    if (erro != null) {
      setState(() => _loading = false);
      // ignore: use_build_context_synchronously
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1B1B1B),
          title: const Text(
            'Estoque insuficiente',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(erro, style: const TextStyle(color: Color(0xFFCCCCCC))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFFE85D33)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    await _acao('CONCLUIDA', 'Venda concluída com sucesso.');
  }

  Future<void> _acao(String status, String mensagem) async {
    setState(() => _loading = true);
    final ok = await widget.cubit.atualizarStatus(widget.venda.id, status);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (ok) widget.onFinalizado(mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.venda.itens;
    final total = widget.venda.total;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirmar venda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Revise os itens antes de concluir',
            style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (itens.isEmpty)
            Text(
              widget.venda.produto,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            )
          else
            ...itens.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.produto.isNotEmpty
                                ? item.produto
                                : 'Produto #${item.receitaId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${_fmtQty(item.quantidade)} × ${_fmtCur(item.precoUnitarioReal)}',
                                style: const TextStyle(
                                  color: Color(0xFF858585),
                                  fontSize: 11.5,
                                ),
                              ),
                              if (item.margemRealizada != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${(item.margemRealizada! * 100).toStringAsFixed(1)}% margem',
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _fmtCur(item.quantidade * item.precoUnitarioReal),
                      style: const TextStyle(
                        color: Color(0xFFFF6B3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(color: Color(0xFF1E1E1E)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _fmtCur(total),
                style: const TextStyle(
                  color: Color(0xFFFF6B3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _concluirComValidacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B3D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF4A2A21),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Concluir Venda',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _acao('CANCELADA', 'Venda cancelada.'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancelar Venda'),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtCur(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return 'R\$ ${parts[0]},${parts[1]}';
  }

  static String _fmtQty(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}

// ─── Date filter button ───────────────────────────────────────────────────────

class _DateFilterButton extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF858585), fontSize: 10.5),
            ),
            const SizedBox(height: 5),
            Text(
              _formatDate(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
