import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/gastos_indiretos/domain/entities/gasto_indireto.dart';
import '../../../../features/receitas/domain/entities/receita.dart';
import '../../domain/entities/producao.dart';
import '../cubit/producoes_cubit.dart';
import '../cubit/producoes_state.dart';

class ProducoesPage extends StatefulWidget {
  const ProducoesPage({super.key});

  @override
  State<ProducoesPage> createState() => _ProducoesPageState();
}

class _ProducoesPageState extends State<ProducoesPage> {
  static const _bgDark = Color(0xFF0A0A0A);
  static const _cardDark = Color(0xFF151515);
  static const _orange = Color(0xFFE85D33);
  static const _textSecondary = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProducoesCubit>();
      if (cubit.state.status == ProducoesStatus.initial) {
        cubit.loadInitial();
      }
    });
  }

  void _openRegistrarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProducoesCubit>(),
        child: const _RegistrarProducaoSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProducoesCubit, ProducoesState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ));
        }
        if (state.errorMessage != null && !state.isSubmitting) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _bgDark,
          appBar: AppBar(
            backgroundColor: _bgDark,
            elevation: 0,
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produções',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registre e acompanhe suas produções',
                  style: TextStyle(fontSize: 14, color: _textSecondary),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.status == ProducoesStatus.loading
                ? null
                : () => _openRegistrarModal(context),
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nova Produção'),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProducoesState state) {
    if (state.status == ProducoesStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: _orange),
      );
    }

    if (state.status == ProducoesStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar produções',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _orange),
              onPressed: () => context.read<ProducoesCubit>().loadInitial(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final producoes = state.producoes;

    if (producoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.precision_manufacturing_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma produção registrada',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre sua primeira produção\ntocando no botão abaixo',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _orange),
              onPressed: () => _openRegistrarModal(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nova Produção', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final receitas = {for (final r in state.receitas) r.id: r};

    return RefreshIndicator(
      color: _orange,
      backgroundColor: _cardDark,
      onRefresh: () => context.read<ProducoesCubit>().reloadProducoes(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: producoes.length,
        itemBuilder: (_, index) {
          final p = producoes[index];
          final receita = receitas[p.receitaId];
          return _ProducaoCard(producao: p, receitaNome: receita?.nome);
        },
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ProducaoCard extends StatelessWidget {
  final Producao producao;
  final String? receitaNome;

  const _ProducaoCard({required this.producao, this.receitaNome});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D33).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.precision_manufacturing_outlined,
              color: Color(0xFFE85D33),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receitaNome ?? 'Receita #${producao.receitaId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${producao.quantidade} lote${producao.quantidade != 1 ? 's' : ''}  ·  ${_formatDate(producao.dataProducao)}',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(producao.custoTotal),
                style: const TextStyle(
                  color: Color(0xFFE85D33),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatCurrency(producao.custoUnitario)}/un',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return 'R\$ ${parts[0]},${parts[1]}';
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _RegistrarProducaoSheet extends StatefulWidget {
  const _RegistrarProducaoSheet();

  @override
  State<_RegistrarProducaoSheet> createState() => _RegistrarProducaoSheetState();
}

class _RegistrarProducaoSheetState extends State<_RegistrarProducaoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController();

  Receita? _receitaSelecionada;
  final Set<int> _gastosSelecionados = {};
  bool _selecionarTodosGastos = true;

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submeter(ProducoesState state) async {
    if (!_formKey.currentState!.validate() || _receitaSelecionada == null) return;

    final quantidade = int.tryParse(_quantidadeCtrl.text.trim()) ?? 0;
    final gastoIndiretoIds = _selecionarTodosGastos
        ? null
        : _gastosSelecionados.toList();

    final ok = await context.read<ProducoesCubit>().registrar(
          receitaId: _receitaSelecionada!.id,
          quantidade: quantidade,
          gastoIndiretoIds: gastoIndiretoIds,
        );

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProducoesCubit, ProducoesState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  'Registrar Produção',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Informe quantos lotes foram produzidos',
                  style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildReceitaDropdown(state.receitas),
                const SizedBox(height: 12),
                _buildQuantidadeField(),
                const SizedBox(height: 16),
                _buildGastosSection(state.gastosIndiretos),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : () => _submeter(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D33),
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
                        : const Text(
                            'Registrar Produção',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceitaDropdown(List<Receita> receitas) {
    return DropdownButtonFormField<Receita>(
      initialValue: receitas.contains(_receitaSelecionada) ? _receitaSelecionada : null,
      onChanged: (r) => setState(() => _receitaSelecionada = r),
      validator: (v) => v == null ? 'Selecione uma receita' : null,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFFE85D33),
      decoration: _inputDecoration('Receita'),
      items: receitas
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.nome, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
    );
  }

  Widget _buildQuantidadeField() {
    return TextFormField(
      controller: _quantidadeCtrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Quantidade de lotes'),
      validator: (v) {
        final n = int.tryParse(v?.trim() ?? '');
        if (n == null || n <= 0) return 'Informe a quantidade de lotes';
        return null;
      },
    );
  }

  Widget _buildGastosSection(List<GastoIndireto> gastos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Gastos indiretos',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
            ),
            const Spacer(),
            Switch(
              value: _selecionarTodosGastos,
              onChanged: (v) => setState(() {
                _selecionarTodosGastos = v;
                if (v) _gastosSelecionados.clear();
              }),
              activeThumbColor: const Color(0xFFE85D33),
            ),
            const Text(
              'Todos',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
            ),
          ],
        ),
        if (!_selecionarTodosGastos && gastos.isNotEmpty)
          Wrap(
            spacing: 8,
            children: gastos.map((g) {
              final selected = _gastosSelecionados.contains(g.id);
              return FilterChip(
                label: Text(g.descricao),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _gastosSelecionados.add(g.id);
                  } else {
                    _gastosSelecionados.remove(g.id);
                  }
                }),
                selectedColor: const Color(0xFFE85D33).withAlpha(50),
                checkmarkColor: const Color(0xFFE85D33),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFFE85D33) : const Color(0xFF8A8A8A),
                  fontSize: 12,
                ),
                backgroundColor: const Color(0xFF1A1A1A),
                side: BorderSide(
                  color: selected ? const Color(0xFFE85D33) : const Color(0xFF2E2E2E),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
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
        borderSide: const BorderSide(color: Color(0xFFE85D33)),
      ),
    );
  }
}
