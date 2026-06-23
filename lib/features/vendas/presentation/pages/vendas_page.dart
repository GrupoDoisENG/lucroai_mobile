import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receitas/domain/entities/receita.dart';
import '../cubit/vendas_cubit.dart';
import '../cubit/vendas_state.dart';
import '../widgets/venda_card.dart';
import '../widgets/venda_summary_card.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  Receita? _receitaSelecionada;

  @override
  void initState() {
    super.initState();
    _quantidadeController.addListener(_refreshTotal);
    _precoController.addListener(_refreshTotal);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<VendasCubit>();
      if (cubit.state.status == VendasStatus.initial) {
        cubit.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _quantidadeController.removeListener(_refreshTotal);
    _precoController.removeListener(_refreshTotal);
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _refreshTotal() {
    setState(() {});
  }

  double get _quantidade => _parseDouble(_quantidadeController.text);
  double get _precoUnitario => _parseDouble(_precoController.text);
  double get _total => _quantidade * _precoUnitario;

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
                      'Registre vendas e acompanhe o historico',
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        if (state.status == VendasStatus.loading && state.receitas.isEmpty) ...[
          const SizedBox(height: 120),
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B3D)),
          ),
        ] else ...[
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReceitaDropdown(state.receitas),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: _quantidadeController,
                    label: 'Quantidade',
                    validator: (value) =>
                        _validatePositiveNumber(value, 'Informe a quantidade'),
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: _precoController,
                    label: 'Preco unitario real',
                    validator: (value) =>
                        _validatePositiveNumber(value, 'Informe o preco'),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF272727)),
                    ),
                    child: Text(
                      'Total: ${_formatCurrency(_total)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B3D),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => _registrarVenda(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B3D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF4A2A21),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Registrar Venda'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistorico(BuildContext context, VendasState state) {
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
                  state.errorMessage ?? 'Nao foi possivel carregar as vendas.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ] else if (state.vendas.isEmpty) ...[
            const SizedBox(height: 80),
            const Center(
              child: Text(
                'Nenhuma venda encontrada no periodo.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ] else ...[
            ...state.vendas.map(
              (venda) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VendaCard(venda: venda),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceitaDropdown(List<Receita> receitas) {
    return DropdownButtonFormField<Receita>(
      initialValue: receitas.contains(_receitaSelecionada)
          ? _receitaSelecionada
          : null,
      onChanged: (value) {
        setState(() {
          _receitaSelecionada = value;
        });
      },
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

  Future<void> _registrarVenda(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _receitaSelecionada == null) {
      return;
    }

    final cubit = context.read<VendasCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.registrarVenda(
      receitaId: _receitaSelecionada!.id,
      quantidade: _quantidade,
      precoUnitarioReal: _precoUnitario,
    );

    if (!mounted) return;

    if (success) {
      _formKey.currentState!.reset();
      _quantidadeController.clear();
      _precoController.clear();
      setState(() {
        _receitaSelecionada = null;
      });

      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1B1B1B),
          content: Text(
            'Venda registrada com sucesso.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
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

  String _friendlyError(String error) {
    if (error.contains('401') || error.toLowerCase().contains('unauthorized')) {
      return 'Sessao expirada. Faca login novamente.';
    }

    return error.replaceFirst('Exception: ', '');
  }
}

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
