import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/insumo.dart';
import '../../domain/services/insumo_custo_calculator.dart';
import '../cubit/insumos_cubit.dart';
import '../cubit/insumos_state.dart';
import '../widgets/insumo_card.dart';
import '../widgets/insumos_search_bar.dart';

class InsumosPage extends StatefulWidget {
  const InsumosPage({super.key});

  @override
  State<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends State<InsumosPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<InsumosCubit>();
      if (cubit.state.status == InsumosStatus.initial) {
        cubit.loadInsumos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFormDialog({Insumo? insumo}) async {
    final cubit = context.read<InsumosCubit>();
    final nomeController = TextEditingController(text: insumo?.nome ?? '');
    final quantidadeController = TextEditingController(
      text: insumo?.quantidade.toString() ?? '',
    );
    final valorPagoController = TextEditingController(
      text: insumo?.valorPago.toString() ?? '',
    );

    InsumoUnidadeMedida unidade = insumo?.unidade ?? InsumoUnidadeMedida.gramas;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final quantidade = _parseDouble(quantidadeController.text) ?? 0;
            final valorPago = _parseDouble(valorPagoController.text) ?? 0;
            final custoUnitario = InsumoCustoCalculator.calcularCustoUnitario(
              valorPago: valorPago,
              quantidade: quantidade,
            );

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
                          insumo == null ? 'Novo insumo' : 'Editar insumo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInput(
                          controller: nomeController,
                          label: 'Nome',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(
                                controller: quantidadeController,
                                label: 'Quantidade',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setModalState(() {}),
                                validator: (value) {
                                  final quantidade = _parseDouble(value ?? '');
                                  if (quantidade == null || quantidade < 0) {
                                    return 'Obrigatorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdown<InsumoUnidadeMedida>(
                                label: 'Unidade',
                                value: unidade,
                                items: InsumoUnidadeMedida.values,
                                itemLabel: (item) => item.label,
                                onChanged: (value) {
                                  if (value != null) {
                                    setModalState(() {
                                      unidade = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          controller: valorPagoController,
                          label: 'Valor pago',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setModalState(() {}),
                          validator: (value) {
                            final valorPago = _parseDouble(value ?? '');
                            if (valorPago == null || valorPago < 0) {
                              return 'Obrigatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171717),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF272727)),
                          ),
                          child: Text(
                            'Custo unitario: ${_formatUnitPrice(custoUnitario, unidade.label)}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B3D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
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

                                  final navigator = Navigator.of(dialogContext);
                                  final nome = nomeController.text.trim();
                                  final quantidade =
                                      _parseDouble(quantidadeController.text) ??
                                      0;
                                  final valorPago =
                                      _parseDouble(valorPagoController.text) ??
                                      0;

                                  if (insumo == null) {
                                    await cubit.createInsumo(
                                      nome: nome,
                                      quantidade: quantidade,
                                      unidade: unidade,
                                      valorPago: valorPago,
                                    );
                                  } else {
                                    await cubit.updateInsumo(
                                      id: insumo.id,
                                      nome: nome,
                                      quantidade: quantidade,
                                      unidade: unidade,
                                      valorPago: valorPago,
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
                                  insumo == null ? 'Salvar' : 'Atualizar',
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

    nomeController.dispose();
    quantidadeController.dispose();
    valorPagoController.dispose();
  }

  Future<void> _confirmDelete(Insumo insumo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Excluir insumo',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja excluir "${insumo.nome}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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
      await context.read<InsumosCubit>().deleteInsumo(insumo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: BlocConsumer<InsumosCubit, InsumosState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
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
              onRefresh: () => context.read<InsumosCubit>().loadInsumos(
                search: state.search,
                showLoader: false,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Text(
                    'Insumos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gerencie quantidade, valor pago e custo unitario',
                    style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  InsumosSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<InsumosCubit>().onSearchChanged(value);
                    },
                    onAdd: () => _openFormDialog(),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == InsumosStatus.loading &&
                      state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  ] else if (state.status == InsumosStatus.error &&
                      state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nao foi possivel carregar os insumos.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else if (state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nenhum insumo encontrado.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else ...[
                    ...state.insumos.map(
                      (insumo) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InsumoCard(
                          insumo: insumo,
                          onTap: () => _openFormDialog(insumo: insumo),
                          onDelete: () => _confirmDelete(insumo),
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
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
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
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF171717),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFFFF6B3D),
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
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
    );
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  static String _formatUnitPrice(double value, String unidade) {
    return 'R\$ ${_formatNumber(value, decimals: 4)}/$unidade';
  }

  static String _formatNumber(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts[0];
    var decimal = parts.length > 1 ? parts[1] : '';

    if (decimals > 2) {
      decimal = decimal.replaceFirst(RegExp(r'0+$'), '');
      if (decimal.isEmpty) {
        decimal = '0';
      }
    }

    return decimal.isEmpty ? integer : '$integer,$decimal';
  }
}
