import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gasto_indireto.dart';
import '../cubit/gastos_indiretos_cubit.dart';
import '../cubit/gastos_indiretos_state.dart';

class GastosIndiretosPage extends StatefulWidget {
  const GastosIndiretosPage({super.key});

  @override
  State<GastosIndiretosPage> createState() => _GastosIndiretosPageState();
}

class _GastosIndiretosPageState extends State<GastosIndiretosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<GastosIndiretosCubit>();
      if (cubit.state.status == GastosIndiretosStatus.initial) {
        cubit.loadGastos();
      }
    });
  }

  Future<void> _openFormDialog({GastoIndireto? gasto}) async {
    final cubit = context.read<GastosIndiretosCubit>();

    final descricaoController =
        TextEditingController(text: gasto?.descricao ?? '');
    final valorController = TextEditingController(
      text: gasto != null ? gasto.valor.toStringAsFixed(2) : '',
    );
    MetodoRateio metodoRateio = gasto?.metodoRateio ?? MetodoRateio.fixo;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gasto == null
                              ? 'Novo gasto indireto'
                              : 'Editar gasto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Este gasto será rateado em todas as receitas.',
                          style: TextStyle(
                            color: Color(0xFF7C7C7C),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildField(
                          controller: descricaoController,
                          label: 'Descricao',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe a descricao';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: valorController,
                          label: 'Valor (R\$)',
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final parsed = _parseDouble(v ?? '');
                            if (parsed == null || parsed < 0) {
                              return 'Informe um valor valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<MetodoRateio>(
                          initialValue: metodoRateio,
                          dropdownColor: const Color(0xFF171717),
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: const Color(0xFFFF6B3D),
                          decoration: InputDecoration(
                            labelText: 'Metodo de rateio',
                            labelStyle:
                                const TextStyle(color: Color(0xFF8A8A8A)),
                            filled: true,
                            fillColor: const Color(0xFF171717),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF272727)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF272727)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFFF6B3D)),
                            ),
                          ),
                          items: MetodoRateio.values
                              .map(
                                (m) => DropdownMenuItem<MetodoRateio>(
                                  value: m,
                                  child: Text(
                                    m.label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => metodoRateio = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2B2B2B),
                                  ),
                                  foregroundColor: Colors.white70,
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final navigator =
                                      Navigator.of(dialogContext);
                                  final descricao =
                                      descricaoController.text.trim();
                                  final valor =
                                      _parseDouble(valorController.text) ?? 0;

                                  if (gasto == null) {
                                    await cubit.criar(
                                      descricao: descricao,
                                      valor: valor,
                                      metodoRateio: metodoRateio,
                                    );
                                  } else {
                                    await cubit.atualizar(
                                      id: gasto.id,
                                      descricao: descricao,
                                      valor: valor,
                                      metodoRateio: metodoRateio,
                                    );
                                  }

                                  if (dialogContext.mounted) {
                                    navigator.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B3D),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(46),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  gasto == null ? 'Salvar' : 'Atualizar',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    descricaoController.dispose();
    valorController.dispose();
  }

  Future<void> _confirmDelete(GastoIndireto gasto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Excluir gasto',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja excluir "${gasto.descricao}"?\nIsso afetara o custo de todas as receitas.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Color(0xFFFF6B3D)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<GastosIndiretosCubit>().deletar(gasto.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: BlocConsumer<GastosIndiretosCubit, GastosIndiretosState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty &&
              !state.isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1B1B1B),
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFFFF6B3D),
              backgroundColor: const Color(0xFF111111),
              onRefresh: () =>
                  context.read<GastosIndiretosCubit>().loadGastos(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gastos Indiretos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Custos rateados automaticamente nas receitas',
                              style: TextStyle(
                                color: Color(0xFF7C7C7C),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.status == GastosIndiretosStatus.loading &&
                          state.gastos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF6B3D),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildImpactBanner(),
                  const SizedBox(height: 16),
                  if (state.gastos.isNotEmpty) ...[
                    _buildTotalCard(state.totalGastos, state.gastos.length),
                    const SizedBox(height: 16),
                  ],
                  if (state.status == GastosIndiretosStatus.error &&
                      state.gastos.isEmpty) ...[
                    const SizedBox(height: 60),
                    const Center(
                      child: Text(
                        'Nao foi possivel carregar os gastos.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else if (state.status == GastosIndiretosStatus.success &&
                      state.gastos.isEmpty) ...[
                    const SizedBox(height: 60),
                    _buildEmptyState(),
                  ] else ...[
                    ...state.gastos.map(
                      (gasto) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _GastoCard(
                          gasto: gasto,
                          onEdit: () => _openFormDialog(gasto: gasto),
                          onDelete: () => _confirmDelete(gasto),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFormDialog(),
        backgroundColor: const Color(0xFFFF6B3D),
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Novo gasto',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildImpactBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1400),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3D3000)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: Color(0xFFFFB000),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Alteracoes afetam o custo unitario de todas as receitas automaticamente.',
              style: const TextStyle(
                color: Color(0xFFCCA800),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total de gastos',
                style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                '$count ${count == 1 ? 'item' : 'itens'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Color(0xFFFF6B3D),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Icon(
          Icons.receipt_long_outlined,
          color: Color(0xFF3C3C3C),
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Nenhum gasto cadastrado',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Adicione agua, energia, gas, aluguel e outros\ncustos para calcular o custo real das receitas.',
          style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 12.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        filled: true,
        fillColor: const Color(0xFF171717),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  static double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    return 'R\$ ${parts[0]},${parts[1]}';
  }
}

class _GastoCard extends StatelessWidget {
  final GastoIndireto gasto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GastoCard({
    required this.gasto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1A1A1A)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF242424)),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 17,
                    color: Color(0xFFFF6B3D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gasto.descricao,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          gasto.metodoRateio.label,
                          style: const TextStyle(
                            color: Color(0xFF7C7C7C),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(gasto.valor),
                      style: const TextStyle(
                        color: Color(0xFFFF6B3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: Color(0xFF7F7F7F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    return 'R\$ ${parts[0]},${parts[1]}';
  }
}
