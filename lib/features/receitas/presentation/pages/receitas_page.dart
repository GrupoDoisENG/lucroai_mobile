import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../insumos/domain/entities/insumo.dart';
import '../../../insumos/presentation/cubit/insumos_cubit.dart';
import '../../../insumos/presentation/cubit/insumos_state.dart';
import '../../domain/entities/receita.dart';
import '../cubit/receitas_cubit.dart';
import '../cubit/receitas_state.dart';
import '../widgets/receita_card.dart';
import '../widgets/receitas_search_bar.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ReceitasCubit>();
      if (cubit.state.status == ReceitasStatus.initial) {
        cubit.loadReceitas();
      }

      final insumosCubit = context.read<InsumosCubit>();
      if (insumosCubit.state.status == InsumosStatus.initial) {
        insumosCubit.loadInsumos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFormDialog({Receita? receita}) async {
    final nomeController = TextEditingController(text: receita?.nome ?? '');
    final rendimentoController = TextEditingController(
      text: receita?.rendimento.toString() ?? '',
    );
    final custoProducaoController = TextEditingController(
      text: receita?.custoProducao.toString() ?? '',
    );
    final custoUnitarioController = TextEditingController(
      text: receita?.custoUnitario.toString() ?? '',
    );
    final margemLucroController = TextEditingController(
      text: receita == null ? '' : (receita.margemLucro * 100).toString(),
    );
    final precoSugeridoController = TextEditingController(
      text: receita?.precoSugerido.toString() ?? '',
    );

    InsumoUnidadeMedida unidadeRendimento =
        receita?.unidadeRendimento ?? InsumoUnidadeMedida.unidades;
    final ingredientes =
        receita?.itens
            .map(
              (item) => _ReceitaItemDraft(
                insumoId: item.insumoId,
                quantidade: item.quantidade,
              ),
            )
            .toList() ??
        <_ReceitaItemDraft>[];
    final formKey = GlobalKey<FormState>();
    final receitasCubit = context.read<ReceitasCubit>();
    final insumosCubit = context.read<InsumosCubit>();

    void atualizarCustos(List<Insumo> insumos) {
      final custoProducao = ingredientes.fold<double>(0, (sum, item) {
        final insumo = _findInsumo(insumos, item.insumoId);
        return sum + item.custoCalculado(insumo);
      });
      final rendimento = _parseDouble(rendimentoController.text) ?? 0;
      final margemPercentual = _parseDouble(margemLucroController.text) ?? 0;
      final custoUnitario = rendimento > 0 ? custoProducao / rendimento : 0.0;
      final precoSugerido = custoUnitario * (1 + (margemPercentual / 100));

      custoProducaoController.text = _formatDecimal(custoProducao);
      custoUnitarioController.text = _formatDecimal(custoUnitario);
      precoSugeridoController.text = _formatDecimal(precoSugerido);
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: receitasCubit),
            BlocProvider.value(value: insumosCubit),
          ],
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final insumosState = context.watch<InsumosCubit>().state;
              final insumos = insumosState.insumos;
              atualizarCustos(insumos);

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
                            receita == null ? 'Nova receita' : 'Editar receita',
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
                                  controller: rendimentoController,
                                  label: 'Rendimento',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged: (_) {
                                    setModalState(() {
                                      atualizarCustos(insumos);
                                    });
                                  },
                                  validator: (value) => _validatePositiveNumber(
                                    value,
                                    'Obrigatorio',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdown<InsumoUnidadeMedida>(
                                  label: 'Unidade',
                                  value: unidadeRendimento,
                                  items: InsumoUnidadeMedida.values,
                                  itemLabel: (item) => item.label,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setModalState(() {
                                        unidadeRendimento = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildIngredientesSection(
                            insumos: insumos,
                            ingredientes: ingredientes,
                            onChanged: () {
                              setModalState(() {
                                atualizarCustos(insumos);
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInput(
                                  controller: custoProducaoController,
                                  label: 'Custo producao',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  readOnly: true,
                                  validator: (value) =>
                                      _validateNonNegativeNumber(
                                        value,
                                        'Obrigatorio',
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInput(
                                  controller: custoUnitarioController,
                                  label: 'Custo unitario',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  readOnly: true,
                                  validator: (value) =>
                                      _validateNonNegativeNumber(
                                        value,
                                        'Obrigatorio',
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInput(
                                  controller: margemLucroController,
                                  label: 'Margem lucro (%)',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged: (_) {
                                    setModalState(() {
                                      atualizarCustos(insumos);
                                    });
                                  },
                                  validator: (value) =>
                                      _validateNonNegativeNumber(
                                        value,
                                        'Obrigatorio',
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInput(
                                  controller: precoSugeridoController,
                                  label: 'Preco sugerido',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  readOnly: true,
                                  validator: (value) =>
                                      _validateNonNegativeNumber(
                                        value,
                                        'Obrigatorio',
                                      ),
                                ),
                              ),
                            ],
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

                                    if (ingredientes.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Color(0xFF1B1B1B),
                                          content: Text(
                                            'Adicione pelo menos um ingrediente.',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final navigator = Navigator.of(
                                      dialogContext,
                                    );
                                    final cubit = context.read<ReceitasCubit>();
                                    final nome = nomeController.text.trim();
                                    final rendimento =
                                        _parseDouble(
                                          rendimentoController.text,
                                        ) ??
                                        0;
                                    final custoProducao =
                                        _parseDouble(
                                          custoProducaoController.text,
                                        ) ??
                                        0;
                                    final custoUnitario =
                                        _parseDouble(
                                          custoUnitarioController.text,
                                        ) ??
                                        0;
                                    final margemLucro =
                                        (_parseDouble(
                                              margemLucroController.text,
                                            ) ??
                                            0) /
                                        100;
                                    final precoSugerido =
                                        _parseDouble(
                                          precoSugeridoController.text,
                                        ) ??
                                        0;
                                    final itens = ingredientes.map((item) {
                                      final insumo = _findInsumo(
                                        insumos,
                                        item.insumoId,
                                      );
                                      return ReceitaItem(
                                        insumoId: item.insumoId,
                                        quantidade: item.quantidade,
                                        custoCalculado: item.custoCalculado(
                                          insumo,
                                        ),
                                      );
                                    }).toList();

                                    if (receita == null) {
                                      await cubit.createReceita(
                                        empresaId:
                                            AuthSession.empresaId ??
                                            receita?.empresaId ??
                                            1,
                                        nome: nome,
                                        rendimento: rendimento,
                                        unidadeRendimento: unidadeRendimento,
                                        custoProducao: custoProducao,
                                        custoUnitario: custoUnitario,
                                        margemLucro: margemLucro,
                                        precoSugerido: precoSugerido,
                                        itens: itens,
                                      );
                                    } else {
                                      await cubit.updateReceita(
                                        id: receita.id,
                                        nome: nome,
                                        rendimento: rendimento,
                                        unidadeRendimento: unidadeRendimento,
                                        custoProducao: custoProducao,
                                        custoUnitario: custoUnitario,
                                        margemLucro: margemLucro,
                                        precoSugerido: precoSugerido,
                                        itens: itens,
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
                                    receita == null ? 'Salvar' : 'Atualizar',
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
          ),
        );
      },
    );

    nomeController.dispose();
    rendimentoController.dispose();
    custoProducaoController.dispose();
    custoUnitarioController.dispose();
    margemLucroController.dispose();
    precoSugeridoController.dispose();
  }

  Future<void> _confirmDelete(Receita receita) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Excluir receita',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja excluir "${receita.nome}"?',
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
      await context.read<ReceitasCubit>().deleteReceita(receita.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: BlocConsumer<ReceitasCubit, ReceitasState>(
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
              onRefresh: () => context.read<ReceitasCubit>().loadReceitas(
                search: state.search,
                showLoader: false,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Text(
                    'Receitas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gerencie rendimento, custos, margem e preco sugerido',
                    style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  ReceitasSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<ReceitasCubit>().onSearchChanged(value);
                    },
                    onAdd: () => _openFormDialog(),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == ReceitasStatus.loading &&
                      state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  ] else if (state.status == ReceitasStatus.error &&
                      state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nao foi possivel carregar as receitas.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else if (state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nenhuma receita encontrada.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else ...[
                    ...state.receitas.map(
                      (receita) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReceitaCard(
                          receita: receita,
                          onTap: () => _openFormDialog(receita: receita),
                          onDelete: () => _confirmDelete(receita),
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

  Widget _buildIngredientesSection({
    required List<Insumo> insumos,
    required List<_ReceitaItemDraft> ingredientes,
    required VoidCallback onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF272727)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ingredientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: insumos.isEmpty
                    ? null
                    : () {
                        ingredientes.add(
                          _ReceitaItemDraft(
                            insumoId: insumos.first.id,
                            quantidade: 1,
                          ),
                        );
                        onChanged();
                      },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B3D),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (insumos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Cadastre insumos antes de montar a receita.',
                style: TextStyle(color: Color(0xFF858585), fontSize: 12),
              ),
            )
          else if (ingredientes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Adicione os insumos usados nesta receita.',
                style: TextStyle(color: Color(0xFF858585), fontSize: 12),
              ),
            )
          else
            ...ingredientes.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final selected =
                  _findInsumo(insumos, item.insumoId) ?? insumos.first;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<int>(
                        initialValue: selected.id,
                        dropdownColor: const Color(0xFF171717),
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: const Color(0xFFFF6B3D),
                        decoration: _inputDecoration('Insumo'),
                        items: insumos
                            .map(
                              (insumo) => DropdownMenuItem<int>(
                                value: insumo.id,
                                child: Text(
                                  insumo.nome,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          item.insumoId = value;
                          onChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        key: ValueKey('ingrediente-${index}-${item.insumoId}'),
                        initialValue: _formatDecimal(item.quantidade),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Qtd'),
                        onChanged: (value) {
                          item.quantidade = _parseDouble(value) ?? 0;
                          onChanged();
                        },
                        validator: (value) {
                          final quantidade = _parseDouble(value ?? '');
                          if (quantidade == null || quantidade <= 0) {
                            return 'Obrigatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remover ingrediente',
                      onPressed: () {
                        ingredientes.removeAt(index);
                        onChanged();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF858585),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
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

  String? _validatePositiveNumber(String? value, String message) {
    final parsed = _parseDouble(value ?? '');
    if (parsed == null || parsed <= 0) return message;
    return null;
  }

  String? _validateNonNegativeNumber(String? value, String message) {
    final parsed = _parseDouble(value ?? '');
    if (parsed == null || parsed < 0) return message;
    return null;
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  static Insumo? _findInsumo(List<Insumo> insumos, int id) {
    for (final insumo in insumos) {
      if (insumo.id == id) return insumo;
    }
    return null;
  }

  static String _formatDecimal(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.endsWith('.00') ? value.toStringAsFixed(0) : fixed;
  }
}

class _ReceitaItemDraft {
  int insumoId;
  double quantidade;

  _ReceitaItemDraft({required this.insumoId, required this.quantidade});

  double custoCalculado(Insumo? insumo) {
    return quantidade * (insumo?.custoUnitario ?? 0);
  }
}
